import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/custom_message_modal.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:intl/intl.dart';

import 'campaignprogress.dart'; // your existing progress widget
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

class DonationBottomSheet extends StatefulWidget {
  final Map<String, dynamic>? campaign; // optional, used for display only

  const DonationBottomSheet({
    super.key,
    this.campaign,
  });

  @override
  State<DonationBottomSheet> createState() => _DonationBottomSheetState();
}

class _DonationBottomSheetState extends State<DonationBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _nickname = '';
  String _comments = '';
  bool _hasComment = false;

  String _displayName = '';
  bool _isAnonymous = false;

  bool _hasBehalfOf = false;
  String? _behalfDisplay = '';

  bool _amountSufficient = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
                  onPressed: () {
  Navigator.pop(context);
},
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
                        if (_nickname.isNotEmpty || _hasBehalfOf || _hasComment) ...[
                          const Divider(height: 32),
                          if (_nickname.isNotEmpty) Text("As: $_nickname"),
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
      final walletProvider = Provider.of<WalletProvider>(context, listen: false);
      final res = await walletProvider.initiateWalletFunding(amount: clean);

      if (res.isNotEmpty) {
        if (mounted) Navigator.pop(context);
        showCustomBottomSheet(
          PaystackUrlSheet(
            url: res,
            onSuccess: () {
              Get.to(
                () => PaymentSuccessScreen(amount: clean),
                transition: Transition.rightToLeft,
              );
              walletProvider.fetchUserWallet();
            },
          ),
          context,
        );
      } else {
        CustomMessageModal.show(context: context, message: "Failed to initiate donation", isSuccess: false);
      }
    } catch (e) {
      CustomMessageModal.show(context: context, message: "Error: $e", isSuccess: false);
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
            Center(child: SvgPicture.asset("assets/svgs/sheet_drag.svg")),
            Gap(20),
            Text("Creator's Goal", style: txStyle18Bold),
            Gap(8),
            CampaignProgressShowcase(
              currentAmount: widget.campaign?['current_amount']?.toString() ?? '0',
              goalAmount: widget.campaign?['goal_amount']?.toString() ?? '0',
              percentage: widget.campaign != null
                  ? (double.tryParse(widget.campaign!['current_amount']?.toString() ?? '0') ?? 0) /
                      (double.tryParse(widget.campaign!['goal_amount']?.toString() ?? '1') ?? 1)
                  : 0.0,
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
// Paystack Payment Sheet (same as your working AddMoneySheet)
// ────────────────────────────────────────────────
class PaystackUrlSheet extends StatefulWidget {
  final String url;
  final VoidCallback? onSuccess;
  final VoidCallback? onError;

  const PaystackUrlSheet({
    super.key,
    required this.url,
    this.onSuccess,
    this.onError,
  });

  @override
  State<PaystackUrlSheet> createState() => _PaystackUrlSheetState();
}

class _PaystackUrlSheetState extends State<PaystackUrlSheet> {
  late WebViewController _webViewController;
  bool pageIniting = false;

  @override
  void initState() {
    super.initState();
    initializeWebViewController(widget.url);
  }

  @override
  void didUpdateWidget(covariant PaystackUrlSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _webViewController.loadRequest(Uri.parse(widget.url));
    }
  }

  void initializeWebViewController(String url) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() => pageIniting = progress != 100);
          },
          onPageStarted: handleTransactionCheck,
          onPageFinished: handleTransactionCheck,
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  void handleTransactionCheck(String url) {
    if (url.contains("paystack/success")) {
      Get.close(1);
      widget.onSuccess?.call();
    } else if (url.contains("paystack/cancel")) {
      Get.close(1);
      widget.onError?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return pageIniting
        ? SizedBox(
            height: SizeConfig.heightOf(90),
            child: Center(
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: appPrimaryColor.withOpacity(.5),
                  valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryColor),
                ),
              ),
            ),
          )
        : SizedBox(
            height: SizeConfig.heightOf(90),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.widthOf(2),
                    vertical: 20,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Fund wallet", style: txStyle20Bold),
                      IconButton(
                        onPressed: () => Get.close(1),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                Expanded(child: WebViewWidget(controller: _webViewController)),
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

  const PaymentSuccessScreen({super.key, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
            onTap: () => Get.close(1),
            label: "Go Back",
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
    );
  }
}