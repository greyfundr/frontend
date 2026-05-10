import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/models/split_bill_details_model.dart';
import 'package:greyfundr/features/bill/bill_payment_method_screen.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

void showSortBillBottomSheet({
  required BuildContext context,
  required String billId,
  required String participantId,
  required double amountOwed,
  required double amountRemaining,
  required double minPaymentAmount,
  required bool allowPartialPayment,
  String? billTitle,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SortBillBottomSheet(
      billId: billId,
      participantId: participantId,
      amountOwed: amountOwed,
      amountRemaining: amountRemaining,
      minPaymentAmount: minPaymentAmount,
      allowPartialPayment: allowPartialPayment,
      billTitle: billTitle,
    ),
  );
}

class SortBillBottomSheet extends StatefulWidget {
  final String billId;
  final String participantId;
  final double amountOwed;
  final double amountRemaining;
  final double minPaymentAmount;
  final bool allowPartialPayment;
  final String? billTitle;

  const SortBillBottomSheet({
    super.key,
    required this.billId,
    required this.participantId,
    required this.amountOwed,
    required this.amountRemaining,
    required this.minPaymentAmount,
    required this.allowPartialPayment,
    this.billTitle,
  });

  @override
  State<SortBillBottomSheet> createState() => _SortBillBottomSheetState();
}

class _SortBillBottomSheetState extends State<SortBillBottomSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<NewSplitBillProvider>(
        context,
        listen: false,
      );
      provider.initSortBillForm(
        amountOwed: widget.amountOwed,
        amountRemaining: widget.amountRemaining,
        minPaymentAmount: widget.minPaymentAmount,
        allowPartialPayment: widget.allowPartialPayment,
      );
      if (provider.splitBillDetails?.data?.id != widget.billId) {
        provider.getSplitBillDetails(splitBillId: widget.billId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context);
    final amountError = provider.sortBillAmountError();
    final canContinue = amountError == null;
    final ceiling = provider.sortBillCeiling;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Gap(20),
              Text("Sort your share", style: txStyle18Bold),
              const Gap(6),
              Text(
                widget.billTitle != null && widget.billTitle!.isNotEmpty
                    ? 'Pay your portion of "${widget.billTitle}"'
                    : 'Pay your portion of this bill',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Gap(20),
              _buildBillProgress(provider),
              const Gap(20),
              Text(
                "Amount to pay",
                style: txStyle13.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(8),
              CustomTextField(
                controller: provider.sortBillAmountController,
                prefix: '₦',
                hintText: '0',
                textInputType: TextInputType.number,
                readOnly:
                    !widget.allowPartialPayment || provider.sortBillHasBehalfOf,
                formatters: MoneyInputFormatter(),
              ),
              if (widget.allowPartialPayment) ...[
                const Gap(6),
                Text(
                  widget.amountRemaining > 0
                      ? 'Max: ${convertStringToCurrency(ceiling.toStringAsFixed(0))}'
                      : 'Min: ${convertStringToCurrency(widget.minPaymentAmount.toStringAsFixed(0))} • Max: ${convertStringToCurrency(ceiling.toStringAsFixed(0))}',
                  style: TextStyle(
                    fontSize: 11,
                    color: amountError != null
                        ? Colors.red
                        : Colors.grey[600],
                  ),
                ),
              ],
              if (amountError != null && widget.allowPartialPayment) ...[
                const Gap(6),
                Text(
                  amountError,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                ),
              ],
              const Gap(20),
              _BehalfOfSection(
                provider: provider,
                billId: widget.billId,
                myParticipantId: widget.participantId,
              ),
              const Gap(20),
              Text(
                "Add a note (optional)",
                style: txStyle13.copyWith(fontWeight: FontWeight.w600),
              ),
              const Gap(8),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: provider.sortBillCommentController.text.trim().isEmpty
                    ? _buildAddNoteButton()
                    : _buildSavedNote(provider),
              ),
              const Gap(24),
              CustomButton(
                onTap: () {
                  if (!canContinue) return;
                  final amount = provider.sortBillAmount;
                  final comment = provider.sortBillCommentController.text
                      .trim();
                  final behalfOfId = provider.sortBillBehalfOfParticipantId;
                  Get.back();
                  Get.to(
                    BillPaymentMethodScreen(
                      participantId: widget.participantId,
                      billID: widget.billId,
                      amount: amount,
                      comment: comment.isEmpty ? null : comment,
                      onBehalfOfParticipantId: behalfOfId.isEmpty
                          ? null
                          : behalfOfId,
                    ),
                    transition: Transition.rightToLeft,
                  );
                },
                enabled: canContinue,
                label: "Continue to payment",
                backgroundColor: appPrimaryColor,
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillProgress(NewSplitBillProvider provider) {
    final data = provider.splitBillDetails?.data;
    final total = (data?.totalAmount ?? 0).toDouble();
    final collected = (data?.totalCollected ?? 0).toDouble();
    final pending = (total - collected).clamp(0.0, double.infinity);
    final ratio = total > 0 ? (collected / total).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appPrimaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appPrimaryColor.withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bill progress",
                style: txStyle13.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                "${(ratio * 100).toStringAsFixed(0)}%",
                style: txStyle13.copyWith(
                  fontWeight: FontWeight.w700,
                  color: appPrimaryColor,
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: ratio,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryColor),
            ),
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Collected",
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                  const Gap(2),
                  Text(
                    convertStringToCurrency(collected.toStringAsFixed(0)),
                    style: txStyle13.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Pending",
                    style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                  ),
                  const Gap(2),
                  Text(
                    convertStringToCurrency(pending.toStringAsFixed(0)),
                    style: txStyle13.copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddNoteButton() {
    return GestureDetector(
      onTap: _openNoteEditor,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.add_circle_rounded, color: appPrimaryColor),
            const Gap(12),
            const Text(
              "Add a note",
              style: TextStyle(
                color: appPrimaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedNote(NewSplitBillProvider provider) {
    return GestureDetector(
      onTap: _openNoteEditor,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: appPrimaryColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: appPrimaryColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.sticky_note_2_outlined, color: appPrimaryColor),
            const Gap(12),
            Expanded(
              child: Text(
                provider.sortBillCommentController.text,
                style: const TextStyle(
                  color: appPrimaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                provider.sortBillCommentController.clear();
                setState(() {});
              },
              child: const Icon(Icons.close, color: Colors.grey, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  void _openNoteEditor() {
    final provider = Provider.of<NewSplitBillProvider>(context, listen: false);
    final ctrl = TextEditingController(
      text: provider.sortBillCommentController.text,
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const Gap(20),
              Text("Add a note", style: txStyle18Bold),
              const Gap(6),
              Text(
                "Anything you'd like to share about this payment?",
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
              const Gap(16),
              CustomTextField(
                controller: ctrl,
                hintText: "e.g. covering my share for last week",
                maxLines: 5,
                autoFocus: true,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.newline,
              ),
              const Gap(20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetCtx),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text("Cancel"),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: CustomButton(
                      onTap: () {
                        provider.sortBillCommentController.text =
                            ctrl.text.trim();
                        Navigator.pop(sheetCtx);
                        setState(() {});
                      },
                      label: "Save",
                      backgroundColor: appPrimaryColor,
                    ),
                  ),
                ],
              ),
              const Gap(12),
            ],
          ),
        ),
      ),
    );
  }
}

class _BehalfOfSection extends StatelessWidget {
  final NewSplitBillProvider provider;
  final String billId;
  final String myParticipantId;

  const _BehalfOfSection({
    required this.provider,
    required this.billId,
    required this.myParticipantId,
  });

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _displayName(Participant p) {
    final first = p.user?.firstName?.trim() ?? '';
    final last = p.user?.lastName?.trim() ?? '';
    final combined = '$first $last'.trim();
    if (combined.isNotEmpty) return combined;
    final guest = p.guestName?.toString().trim() ?? '';
    if (guest.isNotEmpty) return guest;
    return p.user?.username ?? 'Participant';
  }

  List<Participant> _eligibleParticipants() {
    final all = provider.splitBillDetails?.data?.participants ?? const [];
    return all.where((p) {
      if (p.id == null || p.id == myParticipantId) return false;
      if ((p.status ?? '').toLowerCase() == 'paid') return false;
      final remaining = _toDouble(p.amountRemaining);
      final owed = _toDouble(p.amountOwed);
      return (remaining > 0) || (owed > 0);
    }).toList();
  }

  void _openPicker(BuildContext context) {
    final eligible = _eligibleParticipants();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => _BehalfOfPickerSheet(
        participants: eligible,
        myParticipantId: myParticipantId,
        onSelected: (p) {
          final remaining = _toDouble(p.amountRemaining);
          final owed = _toDouble(p.amountOwed);
          final amount = remaining > 0 ? remaining : owed;
          provider.setSortBillBehalfOfParticipant(
            participantId: p.id ?? '',
            name: _displayName(p),
            amount: amount,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasBehalf = provider.sortBillHasBehalfOf;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Paying for someone?",
          style: txStyle13.copyWith(fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        if (hasBehalf)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: appPrimaryColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: appPrimaryColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.person, color: appPrimaryColor),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Covering ${provider.sortBillBehalfOfName}",
                        style: txStyle13.copyWith(
                          color: appPrimaryColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Gap(2),
                      Text(
                        "+${convertStringToCurrency(provider.sortBillBehalfOfAmount.toStringAsFixed(0))} added to your amount",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: provider.clearSortBillBehalfOf,
                  child: const Icon(Icons.close, color: Colors.grey, size: 18),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => _openPicker(context),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: appPrimaryColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_add_alt_1, color: appPrimaryColor),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      "Cover another participant's share",
                      style: TextStyle(
                        color: appPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _BehalfOfPickerSheet extends StatelessWidget {
  final List<Participant> participants;
  final String myParticipantId;
  final void Function(Participant) onSelected;

  const _BehalfOfPickerSheet({
    required this.participants,
    required this.myParticipantId,
    required this.onSelected,
  });

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _displayName(Participant p) {
    final first = p.user?.firstName?.trim() ?? '';
    final last = p.user?.lastName?.trim() ?? '';
    final combined = '$first $last'.trim();
    if (combined.isNotEmpty) return combined;
    final guest = p.guestName?.toString().trim() ?? '';
    if (guest.isNotEmpty) return guest;
    return p.user?.username ?? 'Participant';
  }

  String _initials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      height: mediaQuery.size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const Gap(12),
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const Gap(16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Cover whose share?", style: txStyle16Bold),
                const Gap(4),
                Text(
                  "Their amount will be added to yours",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          const Gap(12),
          Expanded(
            child: participants.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 42,
                            color: Colors.grey[400],
                          ),
                          const Gap(10),
                          Text(
                            "No one else to cover",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Gap(4),
                          Text(
                            "Everyone has either paid or there's no other participant",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    itemCount: participants.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xffEDEFF3)),
                    itemBuilder: (context, index) {
                      final p = participants[index];
                      final remaining = _toDouble(p.amountRemaining);
                      final owed = _toDouble(p.amountOwed);
                      final cover = remaining > 0 ? remaining : owed;
                      final name = _displayName(p);
                      return InkWell(
                        onTap: () {
                          onSelected(p);
                          Get.back();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: appPrimaryColor.withValues(
                                  alpha: 0.1,
                                ),
                                child: Text(
                                  _initials(name),
                                  style: txStyle13.copyWith(
                                    color: appPrimaryColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Gap(12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Gap(2),
                                    Text(
                                      remaining > 0
                                          ? '${convertStringToCurrency(remaining.toStringAsFixed(0))} remaining'
                                          : '${convertStringToCurrency(owed.toStringAsFixed(0))} share',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(8),
                              Text(
                                '+${convertStringToCurrency(cover.toStringAsFixed(0))}',
                                style: txStyle13.copyWith(
                                  color: appPrimaryColor,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
