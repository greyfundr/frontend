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

import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/services/custom_alert.dart';

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

  String currentAmount = '0';
  double percentage = 0.0;
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
        _goalController.text = _formatNumber(
          campaignData['goal_amount']?.toString() ?? '0',
        );

        currentAmount = campaignData['current_amount']?.toString() ?? '0';
        donorCount = campaignData['donors'] ?? 0;
        championCount = campaignData['champions'] ?? 0;

        final goalValue =
            double.tryParse(_goalController.text.replaceAll(',', '')) ?? 1.0;
        final raised = double.tryParse(currentAmount) ?? 0.0;
        percentage = goalValue > 0 ? (raised / goalValue).clamp(0.0, 1.0) : 0.0;

        // Images
        campaignImages = [];
        final rawImages = campaignData['images'] ?? campaignData['image'] ?? '';
        List<String> urls = [];
        if (rawImages is List) {
          urls = rawImages
              .cast<String>()
              .map((e) => e.replaceAll('\\', '/'))
              .toList();
        } else if (rawImages is String && rawImages.isNotEmpty) {
          try {
            final parsed = jsonDecode(rawImages);
            if (parsed is List)
              urls = parsed
                  .cast<String>()
                  .map((e) => e.replaceAll('\\', '/'))
                  .toList();
          } catch (_) {
            urls = rawImages
                .split(',')
                .map((e) => e.trim().replaceAll('\\', '/'))
                .toList();
          }
        }
        if (urls.isEmpty && campaignData['image'] != null) {
          urls.add(campaignData['image'].toString().replaceAll('\\', '/'));
        }

        campaignImages = urls
            .map((url) => {'id': const Uuid().v4(), 'url': url, 'file': null})
            .toList();

        // Expenses
        expenses.clear();
        _expenseNameControllers.clear();
        _expenseCostControllers.clear();
        if (campaignData['budget'] != null &&
            campaignData['budget'].toString().isNotEmpty) {
          try {
            final List<dynamic> raw = jsonDecode(campaignData['budget']);
            expenses = raw.cast<Map<String, dynamic>>();
            for (final exp in expenses) {
              _expenseNameControllers.add(
                TextEditingController(text: exp['name'] ?? ''),
              );
              _expenseCostControllers.add(
                TextEditingController(
                  text: _formatNumber(exp['cost']?.toString() ?? '0'),
                ),
              );
            }
          } catch (e) {
            debugPrint('Budget parse error: $e');
          }
        }

        startDate = campaignData['start_date'] != null
            ? DateTime.tryParse(campaignData['start_date'])
            : null;
        endDate = campaignData['end_date'] != null
            ? DateTime.tryParse(campaignData['end_date'])
            : null;

        manualOffers = (campaignData['moffer'] is List
            ? List<Map<String, dynamic>>.from(campaignData['moffer'])
            : []);
        autoOffers = (campaignData['aoffer'] is List
            ? List<Map<String, dynamic>>.from(campaignData['aoffer'])
            : []);

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

      setState(() {
        campaignImages.add({'id': tempId, 'url': '', 'file': compressedFile});
      });

      _uploadImage(compressedFile, tempId);
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
      List<Map<String, dynamic>> url = await locator<CampaignApi>().uploadImage(
        [file],
      );
      if (url.isNotEmpty) {
        setState(() {
          final index = campaignImages.indexWhere((img) => img['id'] == tempId);
          if (index != -1) campaignImages[index]['url'] = url[0]['imageUrl'];
        });
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
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
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
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final newGoalClean = goalCtrl.text.trim().replaceAll(
                      ',',
                      '',
                    );
                    if (newGoalClean.isNotEmpty &&
                        double.tryParse(newGoalClean) != null) {
                      setState(() {
                        _goalController.text = _formatNumber(newGoalClean);
                        final g = double.tryParse(newGoalClean) ?? 1.0;
                        final r = double.tryParse(currentAmount) ?? 0.0;
                        percentage = g > 0 ? (r / g).clamp(0.0, 1.0) : 0.0;
                      });
                    }
                    Navigator.pop(ctx);
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
    final conditionCtrl = TextEditingController();
    final rewardCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isManual ? "Add Manual Offer" : "Add Automatic Offer",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: conditionCtrl,
              decoration: InputDecoration(
                labelText: "Condition (e.g., Donate ₦5000+)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: rewardCtrl,
              decoration: InputDecoration(
                labelText: "Reward (e.g., Custom Badge)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final cond = conditionCtrl.text.trim();
                    final rew = rewardCtrl.text.trim();
                    if (cond.isNotEmpty && rew.isNotEmpty) {
                      setState(() {
                        if (isManual) {
                          manualOffers.add({'condition': cond, 'reward': rew});
                        } else {
                          autoOffers.add({'condition': cond, 'reward': rew});
                        }
                      });
                      Navigator.pop(ctx);
                    } else {
                      CustomMessageModal.show(
                        context: ctx,
                        message: "Both condition and reward are required",
                        isSuccess: false,
                      );
                    }
                  },
                  child: const Text("Add Offer"),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ).whenComplete(() {
      conditionCtrl.dispose();
      rewardCtrl.dispose();
    });
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
      // Upload pending images
      for (var img in campaignImages) {
        if (img['file'] != null && (img['url'] == null || img['url'].isEmpty)) {
          final url = await locator<CampaignApi>().uploadImage(img['file']);
          if (url != null) img['url'] = url;
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

      final payload = {
        "title": _titleController.text.trim(),
        "description": _descriptionController.text.trim(),
        "goal_amount":
            int.tryParse(_goalController.text.replaceAll(',', '')) ?? 0,
        "budget": jsonEncode(updatedExpenses),
        "moffer": manualOffers,
        "aoffer": autoOffers,
        "images": campaignImages
            .map((img) => img['url'])
            .where((url) => url.isNotEmpty)
            .toList(),
        if (startDate != null) "start_date": startDate!.toIso8601String(),
        if (endDate != null) "end_date": endDate!.toIso8601String(),
      };

      await locator<CampaignApi>().updateCampaign(widget.campaignId, payload);

      CustomMessageModal.show(
        context: context,
        message: "Campaign updated successfully",
        isSuccess: true,
      );
      Navigator.pop(context, true);
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
        title: const Text("Manage Campaign"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save_rounded),
              onPressed: _saveCampaign,
              tooltip: "Save changes",
            ),
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        header: const WaterDropHeader(),
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section with multi-upload, reorder, preview & remove
              SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    if (campaignImages.isNotEmpty)
                      ReorderableListView(
                        scrollDirection: Axis.horizontal,
                        onReorder: (oldIndex, newIndex) {
                          setState(() {
                            if (newIndex > oldIndex) newIndex--;
                            final item = campaignImages.removeAt(oldIndex);
                            campaignImages.insert(newIndex, item);
                            _currentImageIndex = newIndex;
                          });
                        },
                        children: campaignImages.asMap().entries.map((entry) {
                          final index = entry.key;
                          final img = entry.value;
                          return GestureDetector(
                            key: ValueKey(img['id']),
                            onTap: () => _showImagePreview(index),
                            onLongPress: () => _removeImage(index),
                            child: Container(
                              width: 300,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _currentImageIndex == index
                                      ? Colors.teal
                                      : Colors.grey,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: img['file'] != null
                                    ? Image.file(img['file'], fit: BoxFit.cover)
                                    : Image.network(
                                        img['url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.broken_image),
                                      ),
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    else
                      const Center(
                        child: Text(
                          "No images yet",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: FloatingActionButton(
                        mini: true,
                        onPressed: _pickImages,
                        child: const Icon(Icons.add_photo_alternate),
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
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Campaign title",
                  ),
                  maxLines: 2,
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
                          "₦${_formatNumber(currentAmount)} raised of ₦${_goalController.text}",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showEditGoalBottomSheet,
                          child: const Icon(
                            Icons.edit,
                            size: 18,
                            color: Colors.teal,
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
                              _getDaysLeftText(),
                              style: TextStyle(
                                color:
                                    endDate != null &&
                                        DateTime.now().isAfter(endDate!)
                                    ? Colors.red
                                    : Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildTabContent(),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _saveCampaign,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.verified_rounded),
        label: const Text("DONE"),
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
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  expenses.add({'name': '', 'cost': 0, 'file': null});
                  _expenseNameControllers.add(TextEditingController());
                  _expenseCostControllers.add(TextEditingController());
                });
              },
              icon: const Icon(Icons.add_circle_outline, size: 20),
              label: const Text("Add expense item"),
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
