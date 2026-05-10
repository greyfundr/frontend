import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_circular_progress_indicator.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/models/all_campaign_response_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/charity/charity_payment_method_screen.dart';
import 'package:greyfundr/features/charity/charity_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/custom_message_modal.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'campaignprogress.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ────────────────────────────────────────────────
// Shared sheet chrome
// ────────────────────────────────────────────────
Widget _dragHandle() => Container(
      width: 44,
      height: 5,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );

BoxDecoration _sheetDecoration() => const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    );

class DonationBottomSheet extends StatefulWidget {
  final CampaignDatum? campaign;

  const DonationBottomSheet({super.key, this.campaign});

  @override
  State<DonationBottomSheet> createState() => _DonationBottomSheetState();
}

class _DonationBottomSheetState extends State<DonationBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _amountSufficient = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.userProfileModel;

      final fullName =
          "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim();

      Provider.of<CharityProvider>(context, listen: false)
          .initDonationForm(currentUserFullName: fullName);
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
    final endDateStr = widget.campaign?.endDate?.toString();
    if (endDateStr == null || endDateStr.isEmpty) return 0;
    try {
      final end = DateTime.parse(endDateStr)
          .copyWith(hour: 23, minute: 59, second: 59);
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
    final provider = Provider.of<CharityProvider>(context, listen: false);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: _sheetDecoration(),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("How would you like to appear?",
                      style: txStyle16Bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Donors will see this name on the campaign.",
                    style: txStyle12.copyWith(color: greyTextColor),
                  ),
                ),
              ),
              const Gap(8),
              _OptionTile(
                icon: Icons.person_outline_rounded,
                title: "Use a Nickname",
                subtitle: "Show a custom name on this donation",
                onTap: () {
                  Navigator.pop(context);
                  _showNicknameInput();
                },
              ),
              _OptionTile(
                icon: Icons.visibility_off_rounded,
                title: "Be Anonymous",
                subtitle: "Hide your identity from the public",
                onTap: () {
                  Navigator.pop(context);
                  provider.setAnonymousDisplayName();
                },
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  void _showNicknameInput() {
    final provider = Provider.of<CharityProvider>(context, listen: false);
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: _sheetDecoration(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 20,
              right: 20,
              top: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _dragHandle()),
                const Gap(8),
                Text("Choose your display name", style: txStyle18Bold),
                const Gap(4),
                Text("This is how you'll appear on the campaign.",
                    style: txStyle13.copyWith(color: greyTextColor)),
                const Gap(20),
                CustomTextField(
                  controller: controller,
                  autoFocus: true,
                  hintText: "e.g. JoyTheHelper",
                  maxLength: 30,
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () => Navigator.pop(context),
                        label: "Cancel",
                        backgroundColor: Colors.white,
                        color: Colors.red.shade400,
                        borderColor: Colors.red.shade200,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          final firstName = controller.text.trim();
                          if (firstName.isNotEmpty) {
                            provider.setNickname(firstName);
                            Navigator.pop(context);
                          }
                        },
                        label: "Save",
                      ),
                    ),
                  ],
                ),
                const Gap(16),
              ],
            ),
          ),
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
        decoration: _sheetDecoration(),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text("Donate on behalf of", style: txStyle16Bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Dedicate this donation to someone special.",
                    style: txStyle12.copyWith(color: greyTextColor),
                  ),
                ),
              ),
              const Gap(8),
              _OptionTile(
                icon: Icons.alternate_email_rounded,
                title: "Tag a Greyfundr user",
                subtitle: "Search by username or full name",
                onTap: () {
                  Navigator.pop(context);
                  _openTagUserInput();
                },
              ),
              _OptionTile(
                icon: Icons.person_add_alt_1_rounded,
                title: "Add someone not on Greyfundr",
                subtitle: "Enter their name and phone",
                onTap: () {
                  Navigator.pop(context);
                  _openNonUserInput();
                },
              ),
              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }

  void _openNonUserInput() {
    final provider = Provider.of<CharityProvider>(context, listen: false);
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: _sheetDecoration(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 20,
              right: 20,
              top: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _dragHandle()),
                const Gap(8),
                Text("Add a non-user", style: txStyle18Bold),
                const Gap(4),
                Text("Dedicate this donation to someone outside Greyfundr.",
                    style: txStyle13.copyWith(color: greyTextColor)),
                const Gap(20),
                CustomTextField(
                  controller: nameCtrl,
                  autoFocus: true,
                  labelText: "Full name",
                  hintText: "e.g. Mary Daniels",
                ),
                const Gap(12),
                CustomTextField(
                  controller: phoneCtrl,
                  textInputType: TextInputType.phone,
                  labelText: "Phone number",
                  hintText: "+234…",
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () => Navigator.pop(context),
                        label: "Cancel",
                        backgroundColor: Colors.white,
                        color: Colors.red.shade400,
                        borderColor: Colors.red.shade200,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          final name = nameCtrl.text.trim();
                          final phone = phoneCtrl.text.trim();
                          if (name.isNotEmpty && phone.isNotEmpty) {
                            provider.setExternalBehalfOf(
                                name: name, phone: phone);
                            Navigator.pop(context);
                          } else {
                            CustomMessageModal.show(
                              context: context,
                              message: "Fill both name and phone",
                              isSuccess: false,
                            );
                          }
                        },
                        label: "Save",
                      ),
                    ),
                  ],
                ),
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openTagUserInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _TagUserSheet(
        provider: Provider.of<CharityProvider>(context, listen: false),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Comment
  // ────────────────────────────────────────────────
  void _openCommentEditor() {
    final provider = Provider.of<CharityProvider>(context, listen: false);
    final controller = TextEditingController(text: provider.donationComments);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: _sheetDecoration(),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 20,
              right: 20,
              top: 0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: _dragHandle()),
                const Gap(8),
                Text("Add your comment", style: txStyle18Bold),
                const Gap(4),
                Text("Leave a kind word for the campaign creator.",
                    style: txStyle13.copyWith(color: greyTextColor)),
                const Gap(20),
                CustomTextField(
                  controller: controller,
                  autoFocus: true,
                  hintText: "Your thoughts, encouragement…",
                  maxLines: 5,
                ),
                const Gap(20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        onTap: () => Navigator.pop(context),
                        label: "Cancel",
                        backgroundColor: Colors.white,
                        color: Colors.red.shade400,
                        borderColor: Colors.red.shade200,
                      ),
                    ),
                    const Gap(12),
                    Expanded(
                      child: CustomButton(
                        onTap: () {
                          provider.setComment(controller.text);
                          Navigator.pop(context);
                        },
                        label: "Save",
                      ),
                    ),
                  ],
                ),
                const Gap(16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ────────────────────────────────────────────────
  // Confirm Dialog
  // ────────────────────────────────────────────────
  Future<bool> _showConfirmDonationDialog() async {
    final provider = Provider.of<CharityProvider>(context, listen: false);
    final clean = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(clean) ?? 0.0;

    final displayName = provider.donationDisplayName.isNotEmpty
        ? provider.donationDisplayName
        : "a generous supporter";
    final campaignTitle =
        widget.campaign?.title?.toString().trim() ?? "this campaign";

    return await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => Container(
            decoration: _sheetDecoration(),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dragHandle(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Confirm donation", style: txStyle20Bold),
                        const Gap(16),
                        Text("You are about to donate",
                            style: txStyle13.copyWith(color: greyTextColor)),
                        const Gap(6),
                        Text(
                          "₦${_formatNumber(amount.toStringAsFixed(0))}",
                          style: txStyle32Bold.copyWith(
                              color: appPrimaryColor),
                        ),
                        const Gap(12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: appPrimaryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: txStyle13.copyWith(
                                  color: Colors.black87, height: 1.4),
                              children: [
                                const TextSpan(text: "You're donating as "),
                                TextSpan(
                                  text: displayName,
                                  style: txStyle13.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(text: ", to the "),
                                TextSpan(
                                  text: "$campaignTitle ",
                                  style: txStyle13.copyWith(
                                      fontWeight: FontWeight.w700),
                                ),
                                const TextSpan(
                                    text:
                                        "campaign. Your donation will go a long way ❤️"),
                              ],
                            ),
                          ),
                        ),
                        if (provider.donationUsername.isNotEmpty ||
                            provider.donationHasBehalfOf ||
                            provider.donationHasComment) ...[
                          const Gap(16),
                          if (provider.donationUsername.isNotEmpty)
                            _SummaryRow(
                                icon: Icons.person_outline,
                                label: "As",
                                value: provider.donationUsername),
                          if (provider.donationHasBehalfOf)
                            _SummaryRow(
                                icon: Icons.favorite_border,
                                label: "On behalf of",
                                value: provider.donationBehalfDisplay),
                          if (provider.donationHasComment)
                            _SummaryRow(
                                icon: Icons.chat_bubble_outline,
                                label: "Comment",
                                value: provider.donationComments),
                        ],
                        const Gap(24),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                onTap: () => Navigator.pop(context, false),
                                label: "Cancel",
                                backgroundColor: Colors.white,
                                color: Colors.red.shade400,
                                borderColor: Colors.red.shade200,
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: CustomButton(
                                onTap: () => Navigator.pop(context, true),
                                label: "Yes, Donate",
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
    final provider = Provider.of<CharityProvider>(context, listen: false);

    if (_amountController.text.trim().isEmpty) {
      CustomMessageModal.show(
          context: context, message: "Enter an amount", isSuccess: false);
      return;
    }

    final clean = _amountController.text.replaceAll(',', '');
    final amount = double.tryParse(clean) ?? 0.0;

    if (amount < 500) {
      CustomMessageModal.show(
          context: context, message: "Minimum ₦500", isSuccess: false);
      return;
    }

    if ((provider.donationDisplayName.isEmpty ||
            provider.donationUsername.isEmpty) &&
        !provider.donationIsAnonymous) {
      CustomMessageModal.show(
          context: context,
          message: "Choose a nickname or anonymous",
          isSuccess: false);
      _showNicknameChooser();
      return;
    }

    final confirmed = await _showConfirmDonationDialog();
    if (!confirmed) return;

    if (widget.campaign == null) {
      CustomMessageModal.show(
          context: context,
          message: "Campaign is missing.",
          isSuccess: false);
      return;
    }

    if (!mounted) return;
    Navigator.pop(context); // close donation sheet

    Get.to(
      () => CharityPaymentMethodScreen(
        campaign: widget.campaign!,
        amount: amount,
      ),
      transition: Transition.rightToLeft,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CharityProvider>(context);
    final double target =
        double.tryParse(widget.campaign?.target?.toString() ?? '0') ?? 0.0;

    return Container(
      decoration: _sheetDecoration(),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: SvgPicture.asset("assets/svgs/sheet_drag.svg")),
              const Gap(20),
              Text("Creator's Goal", style: txStyle18Bold),
              const Gap(8),
              CampaignProgressShowcase(
                currentAmount:
                    widget.campaign?.currentAmount?.toString() ?? '0',
                goalAmount: widget.campaign?.target.toString() ?? '0',
                percentage: target > 0
                    ? ((widget.campaign?.currentAmount ?? 0) / target)
                        .clamp(0.0, 1.0)
                    : 0.0,
                daysLeft: _calculateDaysLeft(),
                donors: "",
                champions: "",
              ),
              const Gap(16),
              Text(
                "You are supporting ${widget.campaign?.title ?? 'this campaign'}",
                style: txStyle13.copyWith(color: greyTextColor),
              ),
              const Gap(20),
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
              const Gap(8),
              Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14, color: greyTextColor),
                  const Gap(6),
                  Text(
                    "Minimum donation: ₦500",
                    style: txStyle12.copyWith(color: greyTextColor),
                  ),
                ],
              ),
              const Gap(20),

              // Nickname / Anonymous
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: provider.donationDisplayName.isEmpty
                    ? _AddOptionCard(
                        key: const ValueKey('nickname-add'),
                        icon: Icons.badge_outlined,
                        label: "Nickname or Anonymous",
                        enabled: _amountSufficient,
                        onTap: _showNicknameChooser,
                      )
                    : _SelectedOptionCard(
                        key: const ValueKey('nickname-selected'),
                        icon: provider.donationIsAnonymous
                            ? Icons.visibility_off
                            : Icons.person,
                        label: provider.donationDisplayName,
                        onClear: provider.clearDisplayName,
                      ),
              ),
              const Gap(12),

              // On behalf of
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: provider.donationHasBehalfOf
                    ? _SelectedOptionCard(
                        key: const ValueKey('behalf-selected'),
                        icon: Icons.favorite_border,
                        label: provider.donationBehalfDisplay,
                        onClear: provider.clearBehalfOf,
                      )
                    : _AddOptionCard(
                        key: const ValueKey('behalf-add'),
                        icon: Icons.person_add_alt_1_rounded,
                        label: "On behalf of someone?",
                        enabled: _amountSufficient,
                        onTap: _openBehalfOfChooser,
                      ),
              ),
              const Gap(12),

              // Comment
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: !provider.donationHasComment
                    ? _AddOptionCard(
                        key: const ValueKey('comment-add'),
                        icon: Icons.chat_bubble_outline_rounded,
                        label: "Add a comment",
                        enabled: _amountSufficient,
                        onTap: _openCommentEditor,
                      )
                    : _SelectedOptionCard(
                        key: const ValueKey('comment-selected'),
                        icon: Icons.chat_bubble_outline_rounded,
                        label: provider.donationComments,
                        onClear: provider.clearComment,
                      ),
              ),
              const Gap(28),

              CustomButton(
                enabled: _amountSufficient && !provider.donationIsProcessing,
                onTap: _onContinue,
                label: "Continue",
                backgroundColor: appPrimaryColor,
              ),
              const Gap(32),
            ],
          ),
        ),
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Reusable bits
// ────────────────────────────────────────────────
class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: appPrimaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: appPrimaryColor, size: 22),
            ),
            const Gap(12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: txStyle14SemiBold),
                  const Gap(2),
                  Text(subtitle,
                      style: txStyle12.copyWith(color: greyTextColor)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

class _AddOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _AddOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? appPrimaryColor : Colors.grey.shade500;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: enabled
              ? appPrimaryColor.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: enabled
                ? appPrimaryColor.withOpacity(0.18)
                : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded, color: color, size: 20),
            const Gap(10),
            Icon(icon, color: color, size: 18),
            const Gap(10),
            Expanded(
              child: Text(
                label,
                style: txStyle14SemiBold.copyWith(color: color),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

class _SelectedOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onClear;

  const _SelectedOptionCard({
    super.key,
    required this.icon,
    required this.label,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appPrimaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appPrimaryColor.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: appPrimaryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: appPrimaryColor, size: 18),
          ),
          const Gap(10),
          Expanded(
            child: Text(
              label,
              style: txStyle14SemiBold.copyWith(color: appPrimaryColor),
            ),
          ),
          InkWell(
            onTap: onClear,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close_rounded,
                  color: Colors.grey.shade500, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: greyTextColor),
          const Gap(8),
          Text("$label: ",
              style: txStyle13.copyWith(
                  color: greyTextColor, fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value,
                style: txStyle13.copyWith(
                    color: Colors.black87, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────
// Tag-user search sheet (uses ResponsiveStateFunction)
// ────────────────────────────────────────────────
class _TagUserSheet extends StatefulWidget {
  final CharityProvider provider;

  const _TagUserSheet({required this.provider});

  @override
  State<_TagUserSheet> createState() => _TagUserSheetState();
}

class _TagUserSheetState extends State<_TagUserSheet> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  ViewState _state = ViewState.WaitingForInput;
  List<Map<String, dynamic>> _results = const [];
  Map<String, dynamic>? _selected;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    final cleaned = value.replaceAll('@', '').trim();
    if (cleaned.length < 2) {
      setState(() {
        _state = ViewState.WaitingForInput;
        _results = const [];
        _selected = null;
      });
      return;
    }
    setState(() => _state = ViewState.Busy);
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final users = await widget.provider.searchUsersForBehalfOf(value);
        if (!mounted) return;
        setState(() {
          _results = users;
          _state = users.isEmpty
              ? ViewState.NoDataAvailable
              : ViewState.DataFetched;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _state = ViewState.Error);
      }
    });
  }

  void _save() {
    if (_selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select a user from the suggestions"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final id = _selected!['id']?.toString() ?? '';
    final username = (_selected!['username'] ?? '').toString();
    if (id.isEmpty || username.isEmpty) return;
    widget.provider.setTaggedBehalfOfUser(userId: id, username: username);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _sheetDecoration(),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            left: 20,
            right: 20,
            top: 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _dragHandle()),
              const Gap(8),
              Text("Tag a Greyfundr user", style: txStyle18Bold),
              const Gap(4),
              Text(
                "Search by username (e.g. @bella) or full name.",
                style: txStyle13.copyWith(color: greyTextColor),
              ),
              const Gap(16),
              CustomSearchField(
                textEditingController: _controller,
                hintText: "@username or name",
                onChange: _onChanged,
              ),
              const Gap(12),
              ConstrainedBox(
                constraints: const BoxConstraints(
                    minHeight: 140, maxHeight: 340),
                child: ResponsiveStateFunction(
                  state: _state,
                  onIdle: () => _hint(
                      Icons.search, "Start typing to find someone"),
                  onWaitingForInput: () => _hint(
                      Icons.keyboard_alt_outlined,
                      "Type at least 2 characters"),
                  onBusy: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: CustomCircularProgressIndicator(
                        strokeWidth: 3,
                        color: appPrimaryColor,
                      ),
                    ),
                  ),
                  onNoDataAvailable: () => _hint(
                      Icons.person_search_outlined,
                      "No users found. Try a different search."),
                  onError: () => _hint(Icons.cloud_off_rounded,
                      "Couldn't search right now. Try again."),
                  onDataFetched: _userList,
                ),
              ),
              const Gap(12),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      onTap: () => Navigator.pop(context),
                      label: "Cancel",
                      backgroundColor: Colors.white,
                      color: Colors.red.shade400,
                      borderColor: Colors.red.shade200,
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: CustomButton(
                      enabled: _selected != null,
                      onTap: _save,
                      label: "Save",
                    ),
                  ),
                ],
              ),
              const Gap(8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _hint(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade400, size: 32),
            const Gap(8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: txStyle13.copyWith(color: greyTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _userList() {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (_, i) {
        final user = _results[i];
        final id = user['id']?.toString() ?? '';
        final username = (user['username'] ?? '').toString();
        final name = (user['name'] ?? '').toString();
        final avatar = (user['profile_pic'] ?? '').toString();
        final isSelected =
            _selected != null && _selected!['id']?.toString() == id;

        return InkWell(
          onTap: () => setState(() => _selected = user),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? appPrimaryColor.withOpacity(0.06)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomNetworkImage(
                  imageUrl: avatar,
                  radius: 42,
                  borderRadius: 21,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("@$username", style: txStyle14SemiBold),
                      if (name.isNotEmpty) ...[
                        const Gap(2),
                        Text(
                          name,
                          style:
                              txStyle12.copyWith(color: greyTextColor),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  color: isSelected
                      ? appPrimaryColor
                      : Colors.grey.shade300,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ────────────────────────────────────────────────
// Payment Success Screen
// ────────────────────────────────────────────────
class PaymentSuccessScreen extends StatelessWidget {
  final String amount;
  final VoidCallback? onGoBack;

  const PaymentSuccessScreen(
      {super.key, required this.amount, this.onGoBack});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              "assets/lottie/Success.json",
              height: 150,
              width: 150,
              repeat: false,
            ),
            Gap(20),
            Text("Payment Successful",
                style: txStyle30SemiBold, textAlign: TextAlign.center),
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
