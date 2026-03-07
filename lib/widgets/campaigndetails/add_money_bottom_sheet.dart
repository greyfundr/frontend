import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math';

import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/services/locator.dart';
import 'package:greyfundr/shared/custom_message_modal.dart';

class AddMoneyBottomSheet extends StatefulWidget {
  final String userId;
  final String creatorId;
  final String campaignId;
  final Map<String, dynamic>? campaign;
  final VoidCallback? onDonationSuccess;

  const AddMoneyBottomSheet({
    super.key,
    required this.userId,
    required this.creatorId,
    required this.campaignId,
    this.campaign,
    this.onDonationSuccess,
  });

  @override
  State<AddMoneyBottomSheet> createState() => _AddMoneyBottomSheetState();
}

class _AddMoneyBottomSheetState extends State<AddMoneyBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _nickname = '';
  String _comments = '';
  bool _hasComment = false;

  String _displayName = '';
  bool _isAnonymous = false;

  bool _hasBehalfOf = false;
  String? _taggedUserId; // ← Changed to String (IDs should be strings)
  String? _externalName;
  String? _externalContact;
  String _behalfDisplay = '';

  String? _realUserName;

  bool _amountSufficient = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });

    _amountController.addListener(_onAmountChanged);
    _loadUserName();
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
    final value = int.tryParse(clean) ?? 0;
    final shouldEnable = value >= 500;

    if (shouldEnable != _amountSufficient) {
      setState(() => _amountSufficient = shouldEnable);
    }
  }

  String _formatNumber(String value) {
    if (value.isEmpty) return '';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return '';
    final formatter = NumberFormat("#,##0", "en_US");
    return formatter.format(int.parse(digits));
  }

  Future<void> _loadUserName() async {
    // TODO: Load real user name from auth or profile API if needed
    _realUserName = "a generous supporter";
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
                child: Text(
                  "How would you like to appear?",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
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
      _nickname = _displayName;
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    final name = controller.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _nickname = name;
                        _displayName = name;
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
  // On behalf of
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
                leading: const Icon(Icons.alternate_email, color: Colors.teal),
                title: const Text("Tag a Greyfundr user"),
                onTap: () {
                  Navigator.pop(context);
                  CustomMessageModal.show(context: context, message: "User tagging coming soon", isSuccess: false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_1, color: Colors.teal),
                title: const Text("Add someone not on Greyfundr"),
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
    final nameCtrl = TextEditingController(text: _externalName ?? '');
    final phoneCtrl = TextEditingController(text: _externalContact ?? '');

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
                  onPressed: () => Navigator.pop(context),
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
                        _taggedUserId = null;
                        _externalName = name;
                        _externalContact = phone;
                        _behalfDisplay = "$name • $phone";
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
                  onPressed: () => Navigator.pop(context),
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
  // Donation Flow
  // ────────────────────────────────────────────────

  Future<bool> _showConfirmDonationDialog() async {
    final clean = _amountController.text.replaceAll(',', '');
    final amount = int.tryParse(clean) ?? 0;

    final String displayName = _displayName.isNotEmpty
        ? _displayName
        : (_realUserName ?? "a generous supporter");

    final String campaignTitle = widget.campaign?['title']?.toString().trim() ?? "this campaign";

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
                      "₦${_formatNumber(amount.toString())}",
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
                    if (_nickname.isNotEmpty || _behalfDisplay.isNotEmpty || _comments.isNotEmpty) ...[
                      const Divider(height: 32),
                      if (_nickname.isNotEmpty) Text("As: $_nickname"),
                      if (_behalfDisplay.isNotEmpty) Text("On behalf of: $_behalfDisplay"),
                      if (_comments.isNotEmpty) Text("Comment: $_comments"),
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
    ) ?? false;
  }

  Future<void> onContinue() async {
    if (_amountController.text.trim().isEmpty) {
      CustomMessageModal.show(context: context, message: "Enter an amount", isSuccess: false);
      return;
    }

    final clean = _amountController.text.replaceAll(',', '');
    final amount = int.tryParse(clean) ?? 0;

    if (amount < 500) {
      CustomMessageModal.show(context: context, message: "Minimum ₦500", isSuccess: false);
      return;
    }

    final confirmed = await _showConfirmDonationDialog();
    if (!confirmed) return;

    setState(() => _isProcessing = true);

    try {
      final success = await locator<AuthApi>().createDonation(
        userId: widget.userId,           // String
        creatorId: widget.creatorId,     // String
        campaignId: widget.campaignId,   // String
        amount: amount,
        nickname: _nickname.trim().isNotEmpty ? _nickname.trim() : null,
        comments: _comments.trim().isNotEmpty ? _comments.trim() : null,
        behalfUserId: _taggedUserId,     // String? — update AuthApi to accept String?
        externalName: _externalName,
        externalContact: _externalContact,
      );

      if (success) {
        if (widget.onDonationSuccess != null) widget.onDonationSuccess!();
        Navigator.pop(context);
        CustomMessageModal.show(context: context, message: "Donation successful! 🎉", isSuccess: true);
      } else {
        CustomMessageModal.show(context: context, message: "Donation failed", isSuccess: false);
      }
    } catch (e) {
      CustomMessageModal.show(context: context, message: "Error: $e", isSuccess: false);
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),

            const Text("Creator's Goal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),

            const SizedBox(height: 16),

            Text("You are supporting ${widget.campaign?['title'] ?? 'this campaign'}", style: TextStyle(color: Colors.grey[700])),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _amountController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Enter amount (₦)",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((old, newVal) {
                          if (newVal.text.isEmpty) return newVal;
                          return TextEditingValue(
                            text: _formatNumber(newVal.text),
                            selection: TextSelection.collapsed(offset: _formatNumber(newVal.text).length),
                          );
                        }),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      CustomMessageModal.show(
                        context: context,
                        message: "Minimum donation is ₦500",
                        isSuccess: false,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12),
                      child: Icon(Icons.info_outline_rounded, color: Colors.teal.withOpacity(0.8)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _displayName.isEmpty ? _buildAddNicknameButton() : _buildSelectedDisplayName(),
            ),

            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildBehalfOfButtonOrView(),
            ),

            const SizedBox(height: 16),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: !_hasComment ? _buildAddCommentButton() : _buildSavedCommentView(),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : onContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007A74),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isProcessing
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Text("Continue", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

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
            const SizedBox(width: 12),
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
          const SizedBox(width: 12),
          Expanded(child: Text(_displayName, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal))),
          GestureDetector(
            onTap: () => setState(() {
              _displayName = '';
              _nickname = '';
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
            const SizedBox(width: 12),
            Expanded(child: Text(_behalfDisplay, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.teal))),
            GestureDetector(
              onTap: () => setState(() {
                _hasBehalfOf = false;
                _behalfDisplay = '';
                _taggedUserId = null;
                _externalName = null;
                _externalContact = null;
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
            const SizedBox(width: 12),
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
            const SizedBox(width: 12),
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