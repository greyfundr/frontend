import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/api/campaign_api/campaign_api.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/custom_message_modal.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'campaignprogress.dart'; // your existing progress widget
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class DonationBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? campaign; // optional, used for display only
  final VoidCallback? onDonationSuccess;

  const DonationBottomSheet({
    super.key,
    this.campaign,
    this.onDonationSuccess,
  });

  @override
  State<DonationBottomSheet> createState() => _DonationBottomSheetState();
}

class _DonationBottomSheetState extends State<DonationBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _username = '';
  String _comments = '';
  bool _hasComment = false;

  String _displayName = '';
  bool _isAnonymous = false;
  String? _externalName;
  String? _externalPhone;
  String? _currentUserId;

  bool _hasBehalfOf = false;
  String? _behalfDisplay = '';

  bool _amountSufficient = false;
  bool _isProcessing = false;
  bool _didNotifySuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      // Default display name to signed-in user's full name
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final user = userProvider.userProfileModel;
        if (user != null) {
          // capture current user id for donation attribution/onBehalfOf
          _currentUserId = user.id;
          final first = (user.firstName ?? '');
          final last = (user.lastName ?? '');
          final full = ('$first $last').trim();
          if (full.isNotEmpty) {
            setState(() {
              _displayName = full;
              if (_username.isEmpty) _username = full;
            });
          }
        }
      } catch (_) {}
    });

    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onAmountChanged() {
    final clean = _amountController.text.replaceAll(',', '');
    final value = double.tryParse(clean) ?? 0.0;
    setState(() => _amountSufficient = value >= 500);
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    return NumberFormat("#,##0", "en_US").format(int.parse(digits));
  }

  int _calculateDaysLeft() {
    final endDateStr = widget.campaign?['end_date']?.toString();
    if (endDateStr == null || endDateStr.isEmpty) return 0;
    try {
      final end = DateTime.parse(endDateStr).copyWith(hour: 23, minute: 59, second: 59);
      final now = DateTime.now();
      if (now.isAfter(end)) return 0;
      return end.difference(now).inDays;
    } catch (_) {
      return 0;
    }
  }

  // ────────────────────────────────────────────────
  // Nickname / Anonymous
  // ────────────────────────────────────────────────
  void _showNicknameChooser() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text("How would you like to appear?", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              ListTile(
                leading: const Icon(Icons.person_outline_rounded, color: Colors.teal),
                title: const Text("Use Nickname"),
                subtitle: const Text("Show a custom name"),
                onTap: () {
                  Navigator.pop(context);
                  _showNicknameInput();
                },
              ),
              ListTile(
                leading: const Icon(Icons.visibility_off_rounded, color: Colors.teal),
                title: const Text("Be Anonymous"),
                subtitle: const Text("Your name will be hidden"),
                onTap: () {
                  Navigator.pop(context);
                  _setRandomAnonymousName();
                },
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _setRandomAnonymousName() {
    final random = Random();
    final number = random.nextInt(9000) + 1000;
    setState(() {
      _displayName = "Anonymous$number";
      // Do not set _username for anonymous; send no username so API marks anonymous
      _username = '';
      _isAnonymous = true;
    });
  }

  void _showNicknameInput() {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Choose your display name", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text("This is how you'll appear", style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),
            TextField(
              controller: controller,
              autofocus: true,
              maxLength: 30,
              decoration: InputDecoration(
                hintText: "e.g. JoyTheHelper",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
  Navigator.pop(context);
},
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final firstName = controller.text.trim();
                    if (firstName.isNotEmpty) {
                      setState(() {
                        _username = firstName;
                        _displayName = firstName;
                        _isAnonymous = false;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // On behalf of (simplified version)
  // ────────────────────────────────────────────────
  void _openBehalfOfChooser() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 20, bottom: 8),
                child: Text("Donate on behalf of", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
              
              ListTile(
                leading: const Icon(Icons.person_add_alt_1, color: Colors.teal),
                title: const Text("Add someone not on Greyfundr"),
                subtitle: const Text("Enter name and phone"),
                onTap: () {
                  Navigator.pop(context);
                  _openNonUserInput();
                },
              ),

              
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  void _openNonUserInput() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add non-user", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: InputDecoration(
                labelText: "Full name",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: "Phone number",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
  Navigator.pop(context);
},
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    if (name.isNotEmpty && phone.isNotEmpty) {
                      setState(() {
                        _hasBehalfOf = true;
                        _behalfDisplay = "$name • $phone";
                        _externalName = name;
                        _externalPhone = phone;
                      });
                      Navigator.pop(context);
                    } else {
                      CustomMessageModal.show(
                        context: context,
                        message: "Fill both name and phone",
                        isSuccess: false,
                      );
                    }
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Comment
  // ────────────────────────────────────────────────
  void _openCommentEditor() {
    final controller = TextEditingController(text: _comments);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          left: 24,
          right: 24,
          top: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Add your comment", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 5,
              minLines: 3,
              autofocus: true,
              decoration: InputDecoration(
                hintText: "Your thoughts, encouragement...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
  Navigator.pop(context);
},
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final text = controller.text.trim();
                    setState(() {
                      _comments = text;
                      _hasComment = text.isNotEmpty;
                    });
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Confirm Dialog
  // ────────────────────────────────────────────────
  Future<bool> _showConfirmDonationDialog() async {
    final clean = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(clean) ?? 0.0;

    final displayName = _displayName.isNotEmpty ? _displayName : "a generous supporter";
    final campaignTitle = widget.campaign?['title']?.toString().trim() ?? "this campaign";

    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 5,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Confirm Donation", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        Text("You are about to donate", style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                        const SizedBox(height: 12),
                        Text(
                          "₦${_formatNumber(amount.toStringAsFixed(0))}",
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF007A74)),
                        ),
                        const SizedBox(height: 16),
                        RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey[800], fontSize: 15),
                            children: [
                              const TextSpan(text: "You are donating as "),
                              TextSpan(text: displayName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              const TextSpan(text: ", to the "),
                              TextSpan(text: "$campaignTitle ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
                              const TextSpan(text: "campaign.\nYour donation will go a long way ❤️"),
                            ],
                          ),
                        ),
                        if (_username.isNotEmpty || _hasBehalfOf || _hasComment) ...[
                          const Divider(height: 32),
                          if (_username.isNotEmpty) Text("As: $_username"),
                          if (_hasBehalfOf) Text("On behalf of: $_behalfDisplay"),
                          if (_hasComment) Text("Comment: $_comments"),
                        ],
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context, false),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.red[700]!),
                                  foregroundColor: Colors.red[700],
                                ),
                                child: const Text("CANCEL"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007A74)),
                                child: const Text("YES, DONATE", style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  // ────────────────────────────────────────────────
  // Main Donate Action
  // ────────────────────────────────────────────────
  Future<void> _onContinue() async {
    if (_amountController.text.trim().isEmpty) {
      CustomMessageModal.show(context: context, message: "Enter an amount", isSuccess: false);
      return;
    }

    final clean = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(clean) ?? 0.0;

    if (amount < 500) {
      CustomMessageModal.show(context: context, message: "Minimum ₦500", isSuccess: false);
      return;
    }

    final confirmed = await _showConfirmDonationDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final campaignId = widget.campaign?['id']?.toString();
      if (campaignId == null) {
        throw Exception("Campaign ID is missing.");
      }

      // If user cleared the default display name, require them to choose nickname or anonymous
      if ((_displayName.isEmpty || _username.isEmpty) && !_isAnonymous) {
        // force nickname/anonymous chooser
        CustomMessageModal.show(context: context, message: "Choose a nickname or anonymous", isSuccess: false);
        _showNicknameChooser();
        return;
      }

      final payload = {
        'amount': amount.toInt(),
        // legacy keys removed; use createDonation helper instead
        if (_comments.isNotEmpty) 'comment': _comments,
        // 'onBehalfOf' logic can be added here if needed
      };

      // Determine creator id from campaign map
      String? creatorId;
      final c = widget.campaign ?? {};
      creatorId = c['creator_id']?.toString() ?? c['creatorId']?.toString() ?? c['user_id']?.toString() ?? c['userId']?.toString() ?? c['created_by']?.toString();

      // Prepare createDonation args
      final int intAmount = amount.toInt();
      final String callerUserId = _currentUserId ?? '';
      final String creator = creatorId ?? '';

      final bool success = await locator<CampaignApi>().createDonation(
        userId: callerUserId,
        creatorId: creator,
        campaignId: campaignId,
        amount: intAmount,
        nickname: _username.isNotEmpty ? _username : null,
        comments: _comments.isNotEmpty ? _comments : null,
        behalfUserId: (_hasBehalfOf && _externalName == null) ? callerUserId : null,
        externalName: _externalName,
        externalContact: _externalPhone,
      );

      if (!success) throw Exception('Donation API failed');

      // Show success
      if (mounted) {
        Navigator.pop(context); // Close the donation sheet

        // notify-once helper
        void notifyOnce() {
          if (_didNotifySuccess) return;
          _didNotifySuccess = true;
          try {
            widget.onDonationSuccess?.call();
          } catch (_) {}
        }

        showDialog(
          context: context,
          builder: (_) => PaymentSuccessScreen(amount: clean, onGoBack: notifyOnce),
        );

        // Auto-dismiss success dialog after 3s and notify caller to refresh
        Future.delayed(const Duration(seconds: 3), () {
          if (!mounted) return;
          notifyOnce();
          Navigator.of(context, rootNavigator: true).maybePop();
        });
      }

    } catch (e) {
      CustomMessageModal.show(
        context: context,
        message: "Donation failed: ${e.toString()}",
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Helper calculation for consistent value
    final double rawCurrent = double.tryParse((widget.campaign?['current_amount'] ?? widget.campaign?['currentAmount'])?.toString() ?? '0') ?? 0.0;
    final double adjustedCurrent = rawCurrent * 100;
    final double target = double.tryParse(widget.campaign?['target']?.toString() ?? widget.campaign?['goal_amount']?.toString() ?? '1') ?? 1.0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: SvgPicture.asset("assets/svgs/sheet_drag.svg")),
              Gap(20),
              Text("Creator's Goal", style: txStyle18Bold),
              Gap(8),
              CampaignProgressShowcase(
                currentAmount: adjustedCurrent.toString(),
                goalAmount: widget.campaign?['target']?.toString() ?? '0',
                percentage: (adjustedCurrent / target).clamp(0.0, 1.0),
                daysLeft: _calculateDaysLeft(),
                donors: (widget.campaign?['donors'] ?? 0).toString(),
                champions: (widget.campaign?['champions'] ?? 0).toString(),
              ),
              Gap(16),
              Text("You are supporting ${widget.campaign?['title'] ?? 'this campaign'}", style: TextStyle(color: Colors.grey, fontSize: 14),),
              Gap(24),
              CustomTextField(
                hintText: "₦0.00",
                textInputType: TextInputType.number,
                autoFocus: true,
                formatters: MoneyInputFormatter(),
                controller: _amountController,
                onChanged: (value) {
                  setState(() {});
                },
              ),
              Gap(16),
              Text("Minimum donation: ₦500", style: TextStyle(color: Colors.grey, fontSize: 14),),
              Gap(24),

              // Nickname / Anonymous
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _displayName.isEmpty ? _buildAddNicknameButton() : _buildSelectedDisplayName(),
              ),
              Gap(16),

              // On behalf of
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBehalfOfButtonOrView(),
              ),
              Gap(16),

              // Comment
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: !_hasComment ? _buildAddCommentButton() : _buildSavedCommentView(),
              ),
              Gap(32),

              CustomButton(
                enabled: _amountSufficient && !_isProcessing,
                onTap: _onContinue,
                label: "Continue",
                backgroundColor: appPrimaryColor,
              ),
              Gap(40),
            ],
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Helper Widgets (same as before)
  // ────────────────────────────────────────────────
  Widget _buildAddNicknameButton() {
    final enabled = _amountSufficient;
    return GestureDetector(
      onTap: enabled ? _showNicknameChooser : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.teal.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_rounded, color: enabled ? Colors.teal : Colors.grey),
            Gap(12),
            Text(
              "Nickname or Anonymous",
              style: TextStyle(color: enabled ? Colors.teal : Colors.grey, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDisplayName() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_isAnonymous ? Icons.visibility_off : Icons.person, color: Colors.teal),
          Gap(12),
          Expanded(child: Text(_displayName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal))),
          GestureDetector(
            onTap: () => setState(() {
              _displayName = '';
              _username = '';
              _isAnonymous = false;
            }),
            child: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBehalfOfButtonOrView() {
    if (_hasBehalfOf) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.person_add, color: Colors.teal),
            Gap(12),
            Expanded(child: Text(_behalfDisplay ?? '', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal))),
            GestureDetector(
              onTap: () => setState(() {
                _hasBehalfOf = false;
                _behalfDisplay = '';
              }),
              child: const Icon(Icons.close, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final enabled = _amountSufficient;
    return GestureDetector(
      onTap: enabled ? _openBehalfOfChooser : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.teal.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person_add, color: enabled ? Colors.teal : Colors.grey),
            Gap(12),
            Text("On behalf of someone?", style: TextStyle(color: enabled ? Colors.teal : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCommentButton() {
    final enabled = _amountSufficient;
    return GestureDetector(
      onTap: enabled ? _openCommentEditor : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: enabled ? Colors.teal.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.comment_rounded, color: enabled ? Colors.teal : Colors.grey),
            Gap(12),
            Text("Add a comment", style: TextStyle(color: enabled ? Colors.teal : Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedCommentView() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.teal.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(_comments, style: const TextStyle(color: Colors.teal))),
          GestureDetector(
            onTap: () => setState(() {
              _comments = '';
              _hasComment = false;
            }),
            child: const Icon(Icons.close, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Payment Success Screen (same as your working file)
// ────────────────────────────────────────────────
class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  final VoidCallback? onGoBack;

  const PaymentSuccessScreen({super.key, required this.amount, this.onGoBack});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            "assets/lottie/Success.json",
            height: 150,
            width: 150,
            repeat: false,
          ),
          Gap(20),
          Text("Payment Successful", style: txStyle30SemiBold),
          Gap(10),
          Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                text: "You have successfully donated ",
                style: txStyle14.copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: convertStringToCurrency(amount),
                    style: txStyle14.copyWith(
                      color: appPrimaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: " to the campaign",
                    style: txStyle14.copyWith(color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
          Gap(20),
          CustomButton(
            onTap: () {
              try {
                onGoBack?.call();
              } catch (_) {}
              Navigator.of(context).pop();
            },
            label: "Go Back",
          ),
        ],
      ),
      ),
    );
  }
}