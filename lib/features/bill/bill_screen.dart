import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_network_image copy.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/my_split_bill_model.dart' as m_bill;
import 'package:greyfundr/core/models/split_bill_invite_model.dart' as i_bill;
import 'package:greyfundr/features/bill/sort_bill_bottom_sheet.dart';
import 'package:greyfundr/features/bill/split_bill_details_screen.dart';
import 'package:greyfundr/features/new_split_bill/create_split_bill_screen.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  String selectedTab = 'Bill';
  String historySubTab = 'Unsettled';

  final ScrollController _scrollController = ScrollController();
  final formatter = NumberFormat('#,##0.00');
  NewSplitBillProvider? newSplitBillProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newSplitBillProvider = Provider.of<NewSplitBillProvider>(
        context,
        listen: false,
      );
      newSplitBillProvider?.getMySplitBills();
      newSplitBillProvider?.getSplitBillInvites();
    });
  }

  bool _isBillPaid(m_bill.Bill bill) =>
      bill.myShare?.status?.toLowerCase() == 'paid';

  bool _isBillFullySettled(m_bill.Bill bill) {
    final total = bill.totalParticipants ?? 0;
    final paid = bill.totalPaidParticipants ?? 0;
    if (total > 0 && paid >= total) return true;
    final totalAmount = (bill.totalAmount ?? 0).toDouble();
    final collected = (bill.totalCollected ?? 0).toDouble();
    return totalAmount > 0 && collected >= totalAmount;
  }

  List<m_bill.Bill> _activeBills(NewSplitBillProvider provider) =>
      (provider.mySplitBill.bills ?? []).where((b) => !_isBillPaid(b)).toList();

  List<m_bill.Bill> _historyBills(NewSplitBillProvider provider) =>
      (provider.mySplitBill.bills ?? []).where(_isBillPaid).toList();

  List<m_bill.Bill> _unsettledHistoryBills(NewSplitBillProvider provider) =>
      _historyBills(provider).where((b) => !_isBillFullySettled(b)).toList();

  List<m_bill.Bill> _settledHistoryBills(NewSplitBillProvider provider) =>
      _historyBills(provider).where(_isBillFullySettled).toList();

  Widget _buildTabBar(NewSplitBillProvider provider) {
    final requestCount = provider.splitBillInvites.invites?.length ?? 0;
    final billCount = _activeBills(provider).length;
    final historyCount = _historyBills(provider).length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _buildTabItem('Request', requestCount),
          _buildTabItem('Bill', billCount),
          _buildTabItem('History', historyCount),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int count) {
    final bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.black87 : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (count > 0)
                Container(
                  constraints: const BoxConstraints(minWidth: 22),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B5C),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCard(i_bill.Invite invite) {
    final bill = invite.bill;
    if (bill == null) return const SizedBox();

    final shareFormatted = formatter.format(invite.amountOwed ?? 0);
    final totalFormatted = formatter.format(bill.totalAmount ?? 0);

    final daysLeft = bill.dueDate?.difference(DateTime.now()).inDays;
    final timeLeft = (daysLeft ?? 0) > 0
        ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left"
        : "Overdue";

    final provider = Provider.of<NewSplitBillProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CustomNetworkImageSqr(
                  imageUrl: bill.imageUrl ?? "",
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                  padding: 0,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bill.title ?? "Untitled Bill",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                "From: ${invite.createdBy?.username ?? 'Unknown'}",
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                              if ((bill.description ?? '').isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Text(
                                  bill.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Split Bill',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFE4DB),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                timeLeft,
                                style: const TextStyle(
                                  color: appSecondaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // suggested comment area 1
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Total",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₦$totalFormatted",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Your Share",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₦$shareFormatted",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: appPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              showCustomBottomSheet(
                ShowAddCommentSheet(invite: invite),
                context,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F7),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 14,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Add comment",
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    _showInviteActionConfirmation(
                      title: 'Decline this bill?',
                      message:
                          'You\'re about to decline "${bill.title ?? 'this bill'}" for ₦$shareFormatted. ${invite.createdBy?.username ?? 'The sender'} will be notified.',
                      confirmLabel: 'Decline',
                      confirmColor: appSecondaryColor,
                      onConfirm: () async {
                        final billId = bill.id?.toString() ?? '';
                        final success = await provider.declineSplitBillInvite(
                          billId,
                        );
                        if (!mounted) return;
                        if (success) {
                          showSuccessToast('Bill declined');
                        } else {
                          showErrorToast('Failed to decline bill');
                        }
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: appSecondaryColor,
                    side: const BorderSide(
                      color: appSecondaryColor,
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Decline",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _showInviteActionConfirmation(
                      title: 'Accept this bill?',
                      message:
                          'You\'ll owe ₦$shareFormatted for "${bill.title ?? 'this bill'}". You can pay your share anytime before the due date.',
                      confirmLabel: 'Accept',
                      confirmColor: appPrimaryColor,
                      onConfirm: () async {
                        final billId = bill.id?.toString() ?? '';
                        final success = await provider.acceptSplitBillInvite(
                          billId,
                        );
                        if (!mounted) return;
                        if (success) {
                          showSuccessToast('Bill accepted');
                        } else {
                          showErrorToast('Failed to accept bill');
                        }
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showInviteActionConfirmation({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required Future<void> Function() onConfirm,
  }) async {
    await showCustomBottomSheet(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bottom_sheet_cureve_right.png"),
          Container(
            width: double.infinity,
            color: const Color(0xffF1F1F7),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Get.back(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black87,
                              side: BorderSide(
                                color: Colors.grey[400]!,
                                width: 1.2,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Cancel",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Get.back();
                              await onConfirm();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: confirmColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              confirmLabel,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      context,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildMyBillCard(m_bill.Bill bill) {
    final totalAmount = (bill.totalAmount ?? 0).toDouble();
    final totalCollected = (bill.totalCollected ?? 0).toDouble();
    final remaining = (bill.remainingAmount ?? 0).toDouble();
    final progress = totalAmount > 0 ? totalCollected / totalAmount : 0.0;

    final daysLeft = bill.dueDate?.difference(DateTime.now()).inDays;
    final timeLeft = (daysLeft ?? 0) > 0
        ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left"
        : "Overdue";

    final totalFormatted = formatter.format(totalAmount);
    final collectedFormatted = formatter.format(totalCollected);
    final remainingFormatted = formatter.format(remaining);

    final currentUserId = UserLocalStorageService().getUserData()?.id;
    final isCreator = bill.createdBy?.id == currentUserId;
    final hasPaid =
        bill.myShare != null && bill.myShare!.status?.toLowerCase() == 'paid';

    return InkWell(
      onTap: () {
        final billId = bill.id?.toString() ?? '';
        if (billId.isNotEmpty) {
          Get.to(SplitBillDetailsScreen(billId: billId));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: image + title/from/desc + time pill
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomNetworkImageSqr(
                    imageUrl: bill.imageUrl ?? "",
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    padding: 0,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              bill.title ?? "Untitled Bill",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE4DB),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              timeLeft,
                              style: const TextStyle(
                                color: appSecondaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "From: ${bill.createdBy?.name ?? bill.createdBy?.username ?? 'Unknown'}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      if ((bill.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          bill.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress.clamp(0.0, 1.0),
                backgroundColor: appPrimaryColor.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  appPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Stats grid (3 columns)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatBlock(
                    heading: "${(progress * 100).toInt()}% Collected",
                    label: "Collected",
                    value: "₦$collectedFormatted",
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    heading: "₦$remainingFormatted remaining",
                    label: "Total Amount",
                    value: "₦$totalFormatted",
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    heading: "Participant ${bill.totalParticipants ?? 0}",
                    label: "Paid Participant",
                    value: "${bill.totalPaidParticipants ?? 0}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Sort Bill button
            CustomButton(
              onTap: () {
                if (hasPaid) return;

                final amountRemaining =
                    double.tryParse(
                      (bill.myShare?.amountRemaining ?? 0).toString(),
                    ) ??
                    0;
                final amountOwed =
                    double.tryParse(
                      bill.myShare?.amountOwed.toString() ?? "0",
                    ) ??
                    0;

                showSortBillBottomSheet(
                  context: context,
                  billId: "${bill.id}",
                  participantId: "${bill.myShare?.participantId}",
                  amountOwed: amountOwed,
                  amountRemaining: amountRemaining,
                  minPaymentAmount: (bill.minPaymentAmount ?? 0).toDouble(),
                  allowPartialPayment: bill.allowPartialPayment ?? false,
                  billTitle: bill.title,
                );
              },
              height: 45,
              label: hasPaid ? 'Paid Successfully' : 'Sort Bill',
              enabled: true,
              backgroundColor: hasPaid
                  ? Colors.green.shade600
                  : appPrimaryColor,
              borderColor: hasPaid ? Colors.green.shade600 : appPrimaryColor,
              icon: hasPaid
                  ? const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBlock({
    required String heading,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 12),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildRequestTab(NewSplitBillProvider splitBillProvider) {
    return ResponsiveState(
      state: splitBillProvider.splitBillInvitesState,
      busyWidget: UiBusyWidget(),
      noDataAvailableWidget: UiNoDataAvailableWidget(
        height: SizeConfig.heightOf(40),
        message: "No Invites yet",
        subtitle:
            "Once added to a bill, you can accept or decline it from here",
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      successWidget: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: splitBillProvider.splitBillInvites.invites?.length,
        itemBuilder: (context, index) {
          var invite = splitBillProvider.splitBillInvites.invites?.elementAt(
            index,
          );
          return _buildInviteCard(invite!);
        },
      ),
    );
  }

  Widget _buildBillsTab(
    NewSplitBillProvider splitBillProvider,
    List<m_bill.Bill> bills, {
    required String emptyMessage,
    required String emptySubtitle,
    bool showCreateCta = false,
  }) {
    if (splitBillProvider.mySplitBillState == ViewState.Success &&
        bills.isEmpty) {
      return UiNoDataAvailableWidget(
        height: SizeConfig.heightOf(40),
        message: emptyMessage,
        subtitle: emptySubtitle,
        buttonText: showCreateCta ? "Create split" : "",
        onTap: showCreateCta
            ? () {
                Get.to(
                  CreateSplitBillScreen(),
                  transition: Transition.rightToLeft,
                );
              }
            : null,
      );
    }

    return ResponsiveState(
      state: splitBillProvider.mySplitBillState,
      noDataAvailableWidget: UiNoDataAvailableWidget(
        height: SizeConfig.heightOf(40),
        message: emptyMessage,
        subtitle: emptySubtitle,
        buttonText: showCreateCta ? "Create split" : "",
        onTap: showCreateCta
            ? () {
                Get.to(
                  CreateSplitBillScreen(),
                  transition: Transition.rightToLeft,
                );
              }
            : null,
      ),
      busyWidget: UiBusyWidget(),
      successWidget: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: bills.length,
        itemBuilder: (context, index) {
          return _buildMyBillCard(bills[index]);
        },
      ),
    );
  }

  Widget _buildHistorySubTabs() {
    Widget tab(String title) {
      final bool isSelected = historySubTab == title;
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() => historySubTab = title);
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 24, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.black87 : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 2,
                width: 48,
                color: isSelected ? appSecondaryColor : Colors.transparent,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(children: [tab('Unsettled'), tab('Settled')]),
    );
  }

  Widget _buildHistoryTab(NewSplitBillProvider splitBillProvider) {
    final bills = historySubTab == 'Settled'
        ? _settledHistoryBills(splitBillProvider)
        : _unsettledHistoryBills(splitBillProvider);

    final emptyMessage = historySubTab == 'Settled'
        ? "No fully settled bills yet"
        : "No unsettled bills";
    final emptySubtitle = historySubTab == 'Settled'
        ? "Bills where everyone has paid will appear here"
        : "Bills you've paid but others haven't fully settled will appear here";

    return Column(
      children: [
        _buildHistorySubTabs(),
        Expanded(
          child: Builder(
            builder: (context) {
              if (splitBillProvider.mySplitBillState == ViewState.Busy) {
                return UiBusyWidget();
              }
              if (bills.isEmpty) {
                return UiNoDataAvailableWidget(
                  height: SizeConfig.heightOf(40),
                  message: emptyMessage,
                  subtitle: emptySubtitle,
                  buttonText: "",
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: bills.length,
                itemBuilder: (context, index) {
                  final bill = bills[index];
                  return historySubTab == 'Settled'
                      ? _buildSettledHistoryCard(bill)
                      : _buildUnsettledHistoryCard(bill);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUnsettledHistoryCard(m_bill.Bill bill) {
    final totalAmount = (bill.totalAmount ?? 0).toDouble();
    final totalCollected = (bill.totalCollected ?? 0).toDouble();
    final progress = totalAmount > 0 ? totalCollected / totalAmount : 0.0;
    final totalParticipants = bill.totalParticipants ?? 0;
    final paidParticipants = bill.totalPaidParticipants ?? 0;

    return InkWell(
      onTap: () {
        final billId = bill.id?.toString() ?? '';
        if (billId.isNotEmpty) {
          Get.to(SplitBillDetailsScreen(billId: billId));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CustomNetworkImageSqr(
                    imageUrl: bill.imageUrl ?? "",
                    height: 64,
                    width: 64,
                    fit: BoxFit.cover,
                    padding: 0,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              bill.title ?? "Untitled Bill",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB9ECD4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Paid',
                              style: TextStyle(
                                color: Color(0xFF0B7A4B),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "From: ${bill.createdBy?.name ?? bill.createdBy?.username ?? 'Unknown'}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      if ((bill.description ?? '').isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          bill.description!,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: progress.clamp(0.0, 1.0),
                backgroundColor: appPrimaryColor.withValues(alpha: 0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  appPrimaryColor,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildStatBlock(
                    heading: "${(progress * 100).toInt()}% Collected",
                    label: "Paid Participant",
                    value: "$paidParticipants/$totalParticipants",
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    heading: "Collected",
                    label: "",
                    value: "₦${formatter.format(totalCollected)}",
                  ),
                ),
                Expanded(
                  child: _buildStatBlock(
                    heading: "Total Amount",
                    label: "",
                    value: "₦${formatter.format(totalAmount)}",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: appSecondaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: appSecondaryColor.withValues(alpha: 0.3),
                      width: 3,
                    ),
                  ),
                ).paddingOnly(bottom: 3),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    "Unsettled: One or two people have yet to pay their quota",
                    style: TextStyle(
                      color: appSecondaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettledHistoryCard(m_bill.Bill bill) {
    return InkWell(
      onTap: () {
        final billId = bill.id?.toString() ?? '';
        if (billId.isNotEmpty) {
          Get.to(SplitBillDetailsScreen(billId: billId));
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomNetworkImageSqr(
                imageUrl: bill.imageUrl ?? "",
                height: 64,
                width: 64,
                fit: BoxFit.cover,
                padding: 0,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          bill.title ?? "Untitled Bill",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB9ECD4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Settled',
                          style: TextStyle(
                            color: Color(0xFF0B7A4B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "From: ${bill.createdBy?.name ?? bill.createdBy?.username ?? 'Unknown'}",
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                  if ((bill.description ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      bill.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final splitBillProvider = Provider.of<NewSplitBillProvider>(context);

    Widget body;
    switch (selectedTab) {
      case 'Request':
        body = _buildRequestTab(splitBillProvider);
        break;
      case 'History':
        body = _buildHistoryTab(splitBillProvider);
        break;
      case 'Bill':
      default:
        body = _buildBillsTab(
          splitBillProvider,
          _activeBills(splitBillProvider),
          emptyMessage: "Yet to create a split bill",
          emptySubtitle: "Be Frugal with money",
          showCreateCta: true,
        );
    }

    return Column(
      children: [
        _buildTabBar(splitBillProvider),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              splitBillProvider.getMySplitBills();
              splitBillProvider.getSplitBillInvites();
            },
            color: const Color(0xFF007A74),
            child: body,
          ),
        ),
      ],
    );
  }
}

class ShowAddCommentSheet extends StatefulWidget {
  final i_bill.Invite invite;
  const ShowAddCommentSheet({super.key, required this.invite});

  @override
  State<ShowAddCommentSheet> createState() => _ShowAddCommentSheetState();
}

class _ShowAddCommentSheetState extends State<ShowAddCommentSheet> {
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final billId = widget.invite.bill?.id?.toString() ?? '';
    final creatorName = widget.invite.createdBy?.username ?? 'the creator';
    final provider = Provider.of<NewSplitBillProvider>(context);

    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bottom_sheet_cureve_right.png"),
          Container(
            width: double.infinity,
            color: const Color(0xffF1F1F7),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            "Send a message",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Raise a concern with $creatorName before accepting this bill.",
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: messageController,
                      hintText: "Type your message...",
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.newline,
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      enabled: messageController.text.trim().isNotEmpty,
                      onTap: () async {
                        final content = messageController.text.trim();
                        if (content.isEmpty) return;
                        Get.back();
                        final success = await provider.sendSplitBillQuery(
                          billId: billId,
                          content: content,
                        );
                        if (!mounted) return;
                        if (success) {
                          showSuccessToast('Message sent');
                        } else {
                          showErrorToast('Failed to send message');
                        }
                      },
                      label: "Send",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
