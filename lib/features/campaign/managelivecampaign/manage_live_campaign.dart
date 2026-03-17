import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:convert';

import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/widgets/campaignforyou/offers_bottom_sheet.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/services/custom_alert.dart';
import 'package:greyfundr/features/charity/campaigndetails.dart';

class ManageLiveCampaign extends StatefulWidget {
  final String campaignId;
  final Map<String, dynamic>? initialCampaign;

  const ManageLiveCampaign({
    super.key,
    required this.campaignId,
    this.initialCampaign,
  });

  @override
  State<ManageLiveCampaign> createState() => _ManageLiveCampaignState();
}

class _ManageLiveCampaignState extends State<ManageLiveCampaign> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _goalController;

  List<Map<String, dynamic>> expenses = [];
  final List<TextEditingController> _expenseNameControllers = [];
  final List<TextEditingController> _expenseCostControllers = [];

  List<Map<String, dynamic>> manualOffers = [];
  List<Map<String, dynamic>> autoOffers = [];

  // Images: {id: String, url: String, file: File?}
  List<Map<String, dynamic>> campaignImages = [];
  int _currentImageIndex = 0;
  late PageController _pageController;
  final ScrollController _tabScrollController = ScrollController();

  String currentAmount = '0';
  double percentage = 0.0;
  int _goalAmount = 0;
  int donorCount = 0;
  int championCount = 0;

  DateTime? startDate;
  DateTime? endDate;

  bool _isSaving = false;
  bool _isLoading = true;
  String? _errorMessage;

  int _selectedTabIndex = 0;
  final List<String> _mainTabs = ["ABOUT", "FINANCING", "OFFERS"];

  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    _goalController = TextEditingController();

    _loadCampaign(); // Handles all initialization + fresh data fetch
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    for (var c in _expenseNameControllers) c.dispose();
    for (var c in _expenseCostControllers) c.dispose();
    _pageController.dispose();
    _tabScrollController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await _loadCampaign();
    _refreshController.refreshCompleted();
  }

  Future<void> _loadCampaign() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final payload = await locator<CampaignApi>().getCampaignDetails(
        widget.campaignId,
      );
      final campaignData = payload['campaigns'] ?? payload;

      setState(() {
        _titleController.text = campaignData['title'] ?? '';
        _descriptionController.text = campaignData['description'] ?? '';

        // Robustly read goal amount from possible keys and store as integer
        final dynamic rawGoal = campaignData['goal_amount'] ??
            campaignData['goal'] ??
            campaignData['goalAmount'] ??
            campaignData['target'] ??
            '0';
        _goalAmount = int.tryParse(rawGoal?.toString().replaceAll(',', '') ?? '') ?? 0;
        _goalController.text = _formatNumber(_goalAmount.toString());

        currentAmount = campaignData['current_amount']?.toString() ?? '0';
        donorCount = campaignData['donors'] ?? 0;
        championCount = campaignData['champions'] ?? 0;

        final goalValue = _goalAmount > 0 ? _goalAmount.toDouble() : 1.0;
        final raised = double.tryParse(currentAmount) ?? 0.0;
        percentage = goalValue > 0 ? (raised / goalValue).clamp(0.0, 1.0) : 0.0;

        // Images
        campaignImages = [];
        final rawImages = campaignData['images'] ?? campaignData['image'] ?? '';
        List<String> urls = [];
        if (rawImages is List) {
          // Handle list of strings or list of image objects
          if (rawImages.isNotEmpty && rawImages.first is Map) {
            urls = rawImages
                .whereType<Map<String, dynamic>>()
                .map((m) => (m['imageUrl'] ?? m['image'] ?? '').toString())
                .where((s) => s.isNotEmpty)
                .map((s) => s.replaceAll('\\', '/'))
                .toList();
          } else {
            urls = rawImages.cast<String>().map((e) => e.replaceAll('\\', '/')).toList();
          }
        } else if (rawImages is String && rawImages.isNotEmpty) {
          try {
            final parsed = jsonDecode(rawImages);
            if (parsed is List) {
              if (parsed.isNotEmpty && parsed.first is Map) {
                urls = parsed
                    .whereType<Map<String, dynamic>>()
                    .map((m) => (m['imageUrl'] ?? m['image'] ?? '').toString())
                    .where((s) => s.isNotEmpty)
                    .map((s) => s.replaceAll('\\', '/'))
                    .toList();
              } else {
                urls = parsed.cast<String>().map((e) => e.replaceAll('\\', '/')).toList();
              }
            }
          } catch (_) {
            urls = rawImages.split(',').map((e) => e.trim().replaceAll('\\', '/')).toList();
          }
        }
        if (urls.isEmpty && campaignData['image'] != null) {
          urls.add(campaignData['image'].toString().replaceAll('\\', '/'));
        }

        campaignImages = urls
          .map((url) => {
              'id': const Uuid().v4(),
              'url': url,
              'file': null,
              // default providerId empty; will be filled after upload when available
              'providerId': '',
            })
          .toList();

        // Expenses — robustly handle String, List or Map payloads
        expenses.clear();
        _expenseNameControllers.clear();
        _expenseCostControllers.clear();
        final dynamic rawBudgetField = campaignData['budget'];
        try {
          if (rawBudgetField is String && rawBudgetField.isNotEmpty) {
            final parsed = jsonDecode(rawBudgetField);
            if (parsed is List) {
              expenses = parsed.cast<Map<String, dynamic>>();
            } else if (parsed is Map) {
              expenses = [Map<String, dynamic>.from(parsed)];
            }
          } else if (rawBudgetField is List) {
            expenses = rawBudgetField.cast<Map<String, dynamic>>();
          } else if (rawBudgetField is Map) {
            expenses = [Map<String, dynamic>.from(rawBudgetField)];
          }

          for (final exp in expenses) {
            _expenseNameControllers.add(TextEditingController(text: exp['item']?.toString() ?? exp['name']?.toString() ?? ''));
            _expenseCostControllers.add(TextEditingController(text: _formatNumber(exp['cost']?.toString() ?? '0')));
          }
        } catch (e) {
          debugPrint('Budget parse error: $e');
        }

        startDate = campaignData['start_date'] != null
            ? DateTime.tryParse(campaignData['start_date'])
            : null;
        endDate = campaignData['end_date'] != null
            ? DateTime.tryParse(campaignData['end_date'])
            : null;

        // Offers: accept either `offers` array or `moffer`/`aoffer` keys
        List<dynamic> rawOffers = [];
        final dynamic offersField = campaignData['offers'] ?? campaignData['offer'] ?? null;
        if (offersField != null) {
          try {
            if (offersField is String && offersField.isNotEmpty) {
              final parsed = jsonDecode(offersField);
              if (parsed is List) rawOffers = parsed;
            } else if (offersField is List) {
              rawOffers = offersField.cast<dynamic>();
            }
          } catch (_) {
            rawOffers = [];
          }
        }

        if (rawOffers.isEmpty) {
          if (campaignData['moffer'] is List) rawOffers.addAll(campaignData['moffer']);
          if (campaignData['aoffer'] is List) rawOffers.addAll(campaignData['aoffer']);
        }

        manualOffers = rawOffers
            .where((o) => o is Map && (o['type']?.toString().toLowerCase() ?? '') == 'manual')
            .map((o) => Map<String, dynamic>.from(o as Map))
            .toList();

        autoOffers = rawOffers
            .where((o) => o is Map && (o['type']?.toString().toLowerCase() ?? '') == 'auto')
            .map((o) => Map<String, dynamic>.from(o as Map))
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      CustomMessageModal.show(
        context: context,
        message: "Failed to load campaign: $e",
        isSuccess: false,
      );
    }
  }

  String _formatNumber(String? value) {
    final num = double.tryParse(value ?? '0') ?? 0;
    return NumberFormat("#,##0", "en_US").format(num);
  }

  String _getDaysLeftText() {
    if (endDate == null) return "No end date set";
    final now = DateTime.now();
    final end = DateTime(
      endDate!.year,
      endDate!.month,
      endDate!.day,
      23,
      59,
      59,
    );
    if (now.isAfter(end)) return "Campaign ended";
    final days = end.difference(now).inDays;
    return "$days day${days == 1 ? '' : 's'} left";
  }

  Future<void> _pickEndDate() async {
    final initial = endDate ?? DateTime.now().add(const Duration(days: 30));
    final first = startDate ?? DateTime(2020);

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: DateTime(2035),
      helpText: "Campaign End Date",
      confirmText: "Save",
      fieldLabelText: "End Date",
    );

    if (pickedEnd == null) return;

    setState(() {
      endDate = pickedEnd;
      final goalValue = _goalAmount > 0 ? _goalAmount.toDouble() : 1.0;
      final raised = double.tryParse(currentAmount) ?? 0.0;
      percentage = goalValue > 0 ? (raised / goalValue).clamp(0.0, 1.0) : 0.0;
    });
  }

  Future<void> _pickCampaignDates() async {
    final initialStart = startDate ?? DateTime.now();
    final initialEnd = endDate ?? initialStart.add(const Duration(days: 30));

    final pickedStart = await showDatePicker(
      context: context,
      initialDate: initialStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      helpText: "Campaign Start Date",
      confirmText: "Next",
      fieldLabelText: "Start Date",
    );

    if (pickedStart == null) return;

    final pickedEnd = await showDatePicker(
      context: context,
      initialDate: initialEnd.isAfter(pickedStart)
          ? initialEnd
          : pickedStart.add(const Duration(days: 30)),
      firstDate: pickedStart,
      lastDate: DateTime(2035),
      helpText: "Campaign End Date",
      confirmText: "Save",
      fieldLabelText: "End Date",
    );

    if (pickedEnd == null) return;

    setState(() {
      startDate = pickedStart;
      endDate = pickedEnd;
    });
  }

  Future<void> _pickImages() async {
    final List<XFile>? picked = await _picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;

    for (final xfile in picked) {
      final originalFile = File(xfile.path);
      final compressedFile = await _compressImage(originalFile);
      if (compressedFile == null) continue;

      final tempId = const Uuid().v4();

      final newList = List<Map<String, dynamic>>.from(campaignImages);
      newList.add({'id': tempId, 'url': '', 'file': compressedFile});
      setState(() {
        campaignImages = newList;
      });

      await _uploadImage(compressedFile, tempId);
    }
  }

  Future<void> _showImageManagerSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text("Manage Images", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: campaignImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    if (index == campaignImages.length) {
                      return GestureDetector(
                        onTap: () => _showImageSourceChoice(),
                        child: Container(
                          width: 120,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(child: Icon(Icons.add_a_photo, color: Colors.teal, size: 34)),
                        ),
                      );
                    }

                    final img = campaignImages[index];
                    final ImageProvider provider = img['file'] != null
                        ? FileImage(img['file'] as File)
                        : NetworkImage((img['url'] ?? '') as String);

                    return Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            final id = img['id'] as String;
                            _showImageOptions(id);
                          },
                          child: Container(
                            width: 120,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(image: provider, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (index >= 0 && index < campaignImages.length) {
                                  campaignImages.removeAt(index);
                                }
                              });
                              CustomMessageModal.show(context: context, message: "Image removed", isSuccess: true);
                            },
                            child: Container(
                              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                              child: const Icon(Icons.close, color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(ctx).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _showImageSourceChoice();
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Image'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showImageOptions(String id) {
    final idx = campaignImages.indexWhere((e) => e['id'] == id);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Replace from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showImageSourceChoice(replaceId: id, useCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Replace using camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _showImageSourceChoice(replaceId: id, useCamera: true);
              },
            ),
            if (idx != -1)
              ListTile(
                leading: const Icon(Icons.visibility),
                title: const Text('Preview'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _showImagePreview(idx);
                },
              ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showImageSourceChoice({String? replaceId, bool? useCamera}) async {
    // If useCamera is provided, skip the choice sheet and directly pick
    if (useCamera != null) {
      if (useCamera) {
        await _pickSingleImageFromCamera(replaceId);
      } else {
        await _pickSingleImageFromGallery(replaceId);
      }
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickSingleImageFromGallery(replaceId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Use camera'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickSingleImageFromCamera(replaceId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleImageFromGallery(String? replaceId) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final originalFile = File(picked.path);
    final compressedFile = await _compressImage(originalFile);
    if (compressedFile == null) return;

    if (replaceId != null) {
      final index = campaignImages.indexWhere((e) => e['id'] == replaceId);
      if (index != -1) {
        setState(() {
          campaignImages[index]['file'] = compressedFile;
          campaignImages[index]['url'] = '';
          campaignImages[index]['providerId'] = '';
        });
        await _uploadImage(compressedFile, replaceId);
      }
    } else {
      if (campaignImages.length >= 5) {
        CustomMessageModal.show(context: context, message: 'Maximum of 5 images allowed', isSuccess: false);
        return;
      }
      final tempId = const Uuid().v4();
      final newList = List<Map<String, dynamic>>.from(campaignImages);
      newList.add({'id': tempId, 'url': '', 'file': compressedFile, 'providerId': ''});
      setState(() {
        campaignImages = newList;
      });
      await _uploadImage(compressedFile, tempId);
    }
  }

  Future<void> _pickSingleImageFromCamera(String? replaceId) async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    final originalFile = File(picked.path);
    final compressedFile = await _compressImage(originalFile);
    if (compressedFile == null) return;

    if (replaceId != null) {
      final index = campaignImages.indexWhere((e) => e['id'] == replaceId);
      if (index != -1) {
        setState(() {
          campaignImages[index]['file'] = compressedFile;
          campaignImages[index]['url'] = '';
          campaignImages[index]['providerId'] = '';
        });
        await _uploadImage(compressedFile, replaceId);
      }
    } else {
      if (campaignImages.length >= 5) {
        CustomMessageModal.show(context: context, message: 'Maximum of 5 images allowed', isSuccess: false);
        return;
      }
      final tempId = const Uuid().v4();
      final newList = List<Map<String, dynamic>>.from(campaignImages);
      newList.add({'id': tempId, 'url': '', 'file': compressedFile, 'providerId': ''});
      setState(() {
        campaignImages = newList;
      });
      await _uploadImage(compressedFile, tempId);
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final result = await FlutterImageCompress.compressAndGetFile(
        file.path,
        file.path + '_compressed.jpg',
        quality: 85,
        minWidth: 1024,
        minHeight: 1024,
        rotate: 0,
      );
      return result != null ? File(result.path) : file;
    } catch (e) {
      debugPrint('Compression failed: $e');
      return file;
    }
  }

  Future<void> _uploadImage(File file, String tempId) async {
    try {
      dynamic resp;
      try {
        // Upload expects a list of files; always pass as a list
        resp = await locator<CampaignApi>().uploadImage([file]);
      } catch (e) {
        resp = null;
      }

      String imageUrl = '';
      String providerId = '';

      if (resp == null) {
        // no-op
      } else if (resp is String) {
        imageUrl = resp;
      } else if (resp is Map) {
        imageUrl = (resp['imageUrl'] ?? resp['image'] ?? '').toString();
        providerId = resp['providerId']?.toString() ?? '';
      } else if (resp is List && resp.isNotEmpty) {
        final first = resp.first;
        if (first is String) {
          imageUrl = first;
        } else if (first is Map) {
          imageUrl = (first['imageUrl'] ?? first['image'] ?? '').toString();
          providerId = first['providerId']?.toString() ?? '';
        }
      }

      setState(() {
        final index = campaignImages.indexWhere((img) => img['id'] == tempId);
        if (index != -1) {
          if (imageUrl.isNotEmpty) {
            campaignImages[index]['url'] = imageUrl;
            // Clear local file after successful upload
            campaignImages[index]['file'] = null;
          }
          if (providerId.isNotEmpty) campaignImages[index]['providerId'] = providerId;
        }
      });
      if (imageUrl.isNotEmpty) {
        CustomMessageModal.show(context: context, message: 'Image uploaded', isSuccess: true);
        debugPrint('Uploaded image for $tempId -> $imageUrl (provider: $providerId)');
      }
    } catch (e) {
      CustomMessageModal.show(
        context: context,
        message: "Upload error: $e",
        isSuccess: false,
      );
    }
  }

  void _showImagePreview(int index) {
    final img = campaignImages[index];

    // Explicitly type as ImageProvider to fix the type error
    final ImageProvider imageProvider = img['file'] != null
        ? FileImage(img['file'] as File)
        : NetworkImage(img['url'] as String);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Image(image: imageProvider, fit: BoxFit.contain),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Image ${index + 1} of ${campaignImages.length}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove Image"),
        content: const Text("Are you sure you want to remove this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                campaignImages.removeAt(index);
                if (_currentImageIndex >= campaignImages.length) {
                  _currentImageIndex = campaignImages.isNotEmpty
                      ? campaignImages.length - 1
                      : 0;
                }
              });
              Navigator.pop(context);
              CustomMessageModal.show(
                context: context,
                message: "Image removed",
                isSuccess: true,
              );
            },
            child: const Text("Remove", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _deleteExpense(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Are you sure? This cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                expenses.removeAt(index);
                _expenseNameControllers[index].dispose();
                _expenseCostControllers[index].dispose();
                _expenseNameControllers.removeAt(index);
                _expenseCostControllers.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditGoalBottomSheet() {
    final goalCtrl = TextEditingController(
      text: _goalController.text.replaceAll(',', ''),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Edit Goal Amount",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: goalCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Goal Amount",
                prefixText: "₦ ",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(sheetCtx),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final newGoalClean = goalCtrl.text.trim().replaceAll(',', '');
                    if (newGoalClean.isNotEmpty && double.tryParse(newGoalClean) != null) {
                      final newGoal = int.tryParse(newGoalClean) ?? (double.tryParse(newGoalClean)?.toInt() ?? 0);
                      // Close the bottom sheet first, then update parent state
                      Navigator.pop(sheetCtx);
                      if (!mounted) return;
                      setState(() {
                        _goalAmount = newGoal;
                        _goalController.text = _formatNumber(newGoal.toString());
                        final g = _goalAmount > 0 ? _goalAmount.toDouble() : 1.0;
                        final r = double.tryParse(currentAmount) ?? 0.0;
                        percentage = g > 0 ? (r / g).clamp(0.0, 1.0) : 0.0;
                      });
                    } else {
                      // Just close if invalid
                      Navigator.pop(sheetCtx);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).whenComplete(() => goalCtrl.dispose());
  }

  void _showAddOfferBottomSheet(bool isManual) {
    // Use the shared offers bottom sheet from the create-campaign flow.
    showOffersBottomSheet(
      context,
      onSave: (List<Map<String, String>> auto, List<Map<String, String>> manual) {
        setState(() {
          autoOffers = auto
              .map((e) => {
                    'condition': e['condition'] ?? '',
                    'reward': e['reward'] ?? '',
                    'type': 'auto',
                  })
              .toList();

          manualOffers = manual
              .map((e) => {
                    'condition': e['condition'] ?? '',
                    'reward': e['reward'] ?? '',
                    'type': 'manual',
                  })
              .toList();
        });
      },
    );
  }

  Future<void> _saveCampaign() async {
    if (_titleController.text.trim().isEmpty) {
      CustomMessageModal.show(
        context: context,
        message: "Title is required",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Upload pending images using the shared uploader (handles various response shapes)
      for (var img in campaignImages) {
        if (img['file'] != null && (img['url'] == null || (img['url'] as String).isEmpty)) {
          final id = img['id'] as String? ?? const Uuid().v4();
          await _uploadImage(img['file'] as File, id);
        }
      }

      // Prepare expenses
      List<Map<String, dynamic>> updatedExpenses = [];
      for (int i = 0; i < expenses.length; i++) {
        updatedExpenses.add({
          'name': _expenseNameControllers[i].text.trim(),
          'cost':
              int.tryParse(
                _expenseCostControllers[i].text.replaceAll(',', ''),
              ) ??
              0,
          'file': expenses[i]['file'],
        });
      }

      // Minimal payload for update: backend accepts limited fields
      // Prepare offers payload
      final List<Map<String, dynamic>> offersPayload = [];
      for (final o in manualOffers) {
        offersPayload.add({
          'type': 'manual',
          'condition': (o['condition'] ?? o['name'] ?? '').toString(),
          'reward': (o['reward'] ?? o['description'] ?? '').toString(),
        });
      }
      for (final o in autoOffers) {
        offersPayload.add({
          'type': 'auto',
          'condition': (o['condition'] ?? o['name'] ?? '').toString(),
          'reward': (o['reward'] ?? o['description'] ?? '').toString(),
        });
      }

      final payload = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        // backend expects 'target' (not 'goal_amount') on create/update
        "target": int.tryParse(_goalController.text.replaceAll(',', '')) ?? 0,
        // images must be objects (not plain strings)
        "images": campaignImages
          .map((img) => {
              'imageUrl': (img['url'] ?? '').toString(),
              'providerId': (img['providerId'] ?? '').toString(),
            })
          .where((m) => (m['imageUrl'] as String).isNotEmpty)
          .toList(),
        if (offersPayload.isNotEmpty) 'offers': offersPayload,
        if (startDate != null) "startDate": startDate!.toIso8601String(),
        if (endDate != null) "endDate": endDate!.toIso8601String(),
      };

      await locator<CampaignApi>().updateCampaign(widget.campaignId, payload);

      CustomMessageModal.show(
        context: context,
        message: "Campaign updated successfully",
        isSuccess: true,
      );
      // Navigate explicitly to the Campaign Details page after successful update
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => CampaignDetails(id: widget.campaignId),
        ),
      );
    } catch (e) {
      CustomMessageModal.show(
        context: context,
        message: "Error saving campaign: $e",
        isSuccess: false,
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF007A74)),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Error: $_errorMessage",
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _onRefresh, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Remove page title; provide a visible circular back button
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: InkWell(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
        ),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with full-width carousel, swipe, preview & remove
              SizedBox(
                height: 250 * 0.85,
                child: Stack(
                  children: [
                    if (campaignImages.isNotEmpty)
                      PageView.builder(
                        controller: _pageController,
                        itemCount: campaignImages.length,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (context, index) {
                          final img = campaignImages[index];
                          final ImageProvider imageProvider = img['file'] != null
                              ? FileImage(img['file'] as File)
                              : (img['url'] != null && (img['url'] as String).isNotEmpty)
                                  ? NetworkImage(img['url'] as String)
                                  : const AssetImage('assets/images/placeholder.png');

                          return GestureDetector(
                            onTap: () => _showImagePreview(index),
                            onLongPress: () => _removeImage(index),
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _currentImageIndex == index ? Colors.teal : Colors.grey,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      Container(
                        alignment: Alignment.center,
                        child: const Text(
                          "No images yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),

                    // Page indicator (count)
                    if (campaignImages.isNotEmpty)
                      Positioned(
                        bottom: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${_currentImageIndex + 1}/${campaignImages.length}",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),

                    // Center-right image picker button
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16, top: 120),
                        child: FloatingActionButton(
                          heroTag: 'manage_images',
                          mini: true,
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          onPressed: _showImageManagerSheet,
                          child: const Icon(Icons.add_photo_alternate),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: TextField(
                  controller: _titleController,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Campaign title",
                  ),
                  maxLines: 1,
                ),
              ),

              // Stats card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "₦${_formatNumber(currentAmount)} raised of ₦${_formatNumber(_goalAmount.toString())}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearPercentIndicator(
                      lineHeight: 10,
                      percent: percentage,
                      progressColor: Colors.teal,
                      backgroundColor: Colors.grey.shade200,
                      barRadius: const Radius.circular(10),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 18,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "$donorCount Donor${donorCount == 1 ? '' : 's'} • $championCount Champion${championCount == 1 ? '' : 's'}",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              endDate != null
                                  ? DateFormat('dd/MM/yy').format(endDate!)
                                  : 'Not set',
                              style: TextStyle(
                                color: endDate != null && DateTime.now().isAfter(endDate!)
                                    ? Colors.red
                                    : Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                              onPressed: _pickEndDate,
                              tooltip: 'Change end date',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Tabs
              SizedBox(
                height: 36,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_mainTabs.length, (index) {
                      final isSelected = _selectedTabIndex == index;
                      final isOffersTab = _mainTabs[index] == "OFFERS";
                      return Expanded(
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedTabIndex = index),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected
                                      ? Colors.teal
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _mainTabs[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.teal
                                        : Colors.grey[700],
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                                if (isOffersTab && isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: GestureDetector(
                                      onTap: () =>
                                          _showAddOfferBottomSheet(true),
                                      child: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 350,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Scrollbar(
                  controller: _tabScrollController,
                  child: SingleChildScrollView(
                    controller: _tabScrollController,
                    child: _buildTabContent(),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveCampaign,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        icon: const Icon(Icons.verified_rounded),
        label: const Text("FINISHED EDITING"),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // ABOUT
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Description",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 12,
              minLines: 6,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: "Tell your story...",
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Start: ${startDate != null ? DateFormat('MMM dd, yyyy').format(startDate!) : 'Not set'}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickCampaignDates,
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "End: ${endDate != null ? DateFormat('MMM dd, yyyy').format(endDate!) : 'Not set'}",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _pickEndDate,
                ),
              ],
            ),
          ],
        );

      case 1: // FINANCING
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Budget Breakdown",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ...List.generate(
              expenses.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: _expenseNameControllers[i],
                        decoration: InputDecoration(
                          labelText: "Expense item",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _expenseCostControllers[i],
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Amount",
                          prefixText: "₦ ",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteExpense(i),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  expenses.add({'name': '', 'cost': 0, 'file': null});
                  _expenseNameControllers.add(TextEditingController());
                  _expenseCostControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text("Add expense item"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );

      case 2: // OFFERS
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Manual Offers",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 6),
            if (manualOffers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No manual offers added yet",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
            ...manualOffers.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    title: Text(
                      offer['condition'] ?? 'No condition',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Reward: ${offer['reward'] ?? 'No reward'}",
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () =>
                          setState(() => manualOffers.removeAt(index)),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            const Text(
              "Automatic Offers",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            const SizedBox(height: 12),
            if (autoOffers.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text(
                    "No automatic offers added yet",
                    style: TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ),
            ...autoOffers.asMap().entries.map((entry) {
              final index = entry.key;
              final offer = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    title: Text(
                      offer['condition'] ?? 'No condition',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        "Reward: ${offer['reward'] ?? 'No reward'}",
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () =>
                          setState(() => autoOffers.removeAt(index)),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 140),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class WavyBottomClipper extends CustomClipper<Path> {
  final double depth;
  const WavyBottomClipper({this.depth = 30});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - depth)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height,
        size.width * 0.5,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        0,
        size.height - depth,
      )
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


