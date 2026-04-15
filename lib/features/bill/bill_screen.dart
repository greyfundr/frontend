import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_network_image copy.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/my_split_bill_model.dart' as m_bill;
import 'package:greyfundr/core/models/split_bill_invite_model.dart' as i_bill;
import 'package:greyfundr/features/bill/bill_payment_method_screen.dart';
import 'package:greyfundr/features/bill/split_bill_details_screen.dart';
import 'package:greyfundr/features/new_split_bill/create_split_bill_screen.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  String selectedTab = 'Bill Invites';

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

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [_buildTabItem('Bill Invites'), _buildTabItem('My Bills')],
      ),
    );
  }

  Widget _buildTabItem(String title) {
    bool isSelected = selectedTab == title;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = title;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF007A74) : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInviteCard(i_bill.Invite invite) {
    final bill = invite.bill;
    if (bill == null) return const SizedBox();

    final paidFormatted = formatter.format(invite.amountOwed ?? 0);
    final totalFormatted = formatter.format(bill.totalAmount ?? 0);

    final daysLeft = bill.dueDate?.difference(DateTime.now()).inDays;
    final timeLeft = (daysLeft ?? 0) > 0
        ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left"
        : "Overdue";

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
                borderRadius: BorderRadius.circular(12),
                child: CustomNetworkImageSqr(
                  imageUrl: bill.imageUrl ?? "",
                  height: 60,
                  width: 60,
                ),
              ),
              const SizedBox(width: 16),
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "From: @${invite.createdBy?.username ?? 'Unknown'}",
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0ED),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeLeft,
                  style: const TextStyle(
                    color: Color(0xFFFF6B35),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Share",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₦$paidFormatted",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF007A74),
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Total Bill",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "₦$totalFormatted",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () async {
                    final provider = Provider.of<NewSplitBillProvider>(
                      context,
                      listen: false,
                    );
                    final billId = bill.id?.toString() ?? '';
                    final success = await provider.declineSplitBillInvite(
                      billId,
                    );
                    if (success && mounted) {
                      showSuccessToast('Bill declined');
                    } else if (mounted) {
                      showErrorToast('Failed to decline bill');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Decline"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    final provider = Provider.of<NewSplitBillProvider>(
                      context,
                      listen: false,
                    );
                    final billId = bill.id?.toString() ?? '';
                    final success = await provider.acceptSplitBillInvite(
                      billId,
                    );
                    if (success && mounted) {
                      showSuccessToast('Bill accepted');
                    } else if (mounted) {
                      showErrorToast('Failed to accept bill');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A74),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Accept & Pay"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMyBillCard(m_bill.Bill bill) {
    final progress = (bill.totalAmount ?? 1) > 0
        ? (bill.totalCollected ?? 0) / (bill.totalAmount ?? 1)
        : 0.0;

    final daysLeft = bill.dueDate?.difference(DateTime.now()).inDays;
    final timeLeft = (daysLeft ?? 0) > 0
        ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left"
        : "Overdue";

    final totalFormatted = formatter.format(bill.totalAmount ?? 0);
    final collectedFormatted = formatter.format(bill.totalCollected ?? 0);
    final remainingFormatted = formatter.format(bill.remainingAmount ?? 0);

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    bill.title ?? "Untitled Bill",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F8F8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    timeLeft,
                    style: const TextStyle(
                      color: Color(0xFF007A74),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress.clamp(0.0, 1.0),
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF007A74),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${(progress * 100).toInt()}% collected",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF007A74),
                  ),
                ),
                Text(
                  "₦$remainingFormatted remaining",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem("Collected", "₦$collectedFormatted"),
                _buildStatItem("Total Amount", "₦$totalFormatted"),
                _buildStatItem(
                  "Participants",
                  "${bill.totalParticipants ?? 0}",
                ),
              ],
            ),
            if (!isCreator) ...[
              const SizedBox(height: 20),
              CustomButton(
                onTap: () {
                  if (hasPaid) return;
                  Get.to(
                    BillPaymentMethodScreen(
                      participantId: "${bill.myShare?.participantId}",
                      billID: "${bill.id}",
                      minPaymentAmount: (bill.minPaymentAmount ?? 0).toDouble(),
                      amount:
                        (bill.myShare?.amountRemaining != null && double.tryParse((bill.myShare?.amountRemaining ?? 0).toString())! > 0)
                            ? double.tryParse((bill.myShare?.amountRemaining ?? 0).toString())!
                            : (double.tryParse(
                                bill.myShare?.amountOwed.toString() ?? "0",
                              ) ??
                              0),
                              payingRemainingAmount: (bill.myShare?.amountRemaining != null && double.tryParse((bill.myShare?.amountRemaining ?? 0).toString())! > 0) ? true : false,
                    ),
                  );
                  // TODO: trigger pay
                },
                height: 48,
                label: hasPaid ? 'Paid Successfully' : 'Pay Bill',
                enabled: true, // keep it true so it's not 0.4 opacity
                backgroundColor: hasPaid
                    ? Colors.green.shade600
                    : const Color(0xFF007A74),
                borderColor: hasPaid
                    ? Colors.green.shade600
                    : const Color(0xFF007A74),
                icon: hasPaid
                    ? const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 20,
                      )
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final splitBillProvider = Provider.of<NewSplitBillProvider>(context);
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              splitBillProvider.getMySplitBills();
              splitBillProvider.getSplitBillInvites();
            },
            color: const Color(0xFF007A74),
            child: selectedTab == 'Bill Invites'
                ? ResponsiveState(
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
                      itemCount:
                          splitBillProvider.splitBillInvites.invites?.length,
                      itemBuilder: (context, index) {
                        var invite = splitBillProvider.splitBillInvites.invites
                            ?.elementAt(index);
                        return _buildInviteCard(invite!);
                      },
                    ),
                  )
                : ResponsiveState(
                    state: splitBillProvider.mySplitBillState,
                    noDataAvailableWidget: UiNoDataAvailableWidget(
                      height: SizeConfig.heightOf(40),
                      message: "Yet to create a split bill",
                      subtitle: "Be Frugal with money",
                      buttonText: "Create split",
                      onTap: () {
                        Get.to(CreateSplitBillScreen(), transition: Transition.rightToLeft);
                      },
                    ),

                    busyWidget: UiBusyWidget(),
                    successWidget: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: splitBillProvider.mySplitBill.bills?.length,
                      itemBuilder: (context, index) {
                        var bill = splitBillProvider.mySplitBill.bills
                            ?.elementAt(index);
                        return _buildMyBillCard(bill!);
                      },
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
