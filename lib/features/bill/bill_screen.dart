import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';
import 'package:greyfundr/core/models/split_bill_response_model.dart';
import 'package:greyfundr/features/bill/bill_summary.dart';
import 'package:greyfundr/features/bill/sort_bill_modal.dart';
import 'package:intl/intl.dart';

class BillScreen extends StatefulWidget {
  const BillScreen({super.key});

  @override
  State<BillScreen> createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  String selectedTab = 'Bill';
  List<SplitBillDatum> _splitBills = [];
  bool _isLoading = false;
  String? _errorMessage;
  final SplitBillApi _splitBillApi = SplitBillApiImpl();
  String _historySubTab = 'Completed';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _fetchSplitBills();
  }

  @override
  void dispose() {
    // _tabController.dispose();
    // _scrollController.removeListener(_scrollListener);
    // _scrollController.dispose();
    // donorController.dispose();
    super.dispose();
  }

  Future<void> _fetchSplitBills() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch all bills (global) instead of only the current user's participant bills
      final bills = await _splitBillApi.getCurrentUserSplitBill();

      if (mounted) {
        setState(() {
          _splitBills = bills.data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Failed to load bills";
          _isLoading = false;
        });
      }
    }
  }

  final formatter = NumberFormat('#,##0.00');

  Widget _buildBillCard({
    required SplitBillDatum bill,
    required String title,
    required String timeLeft,
    required String amountPaid,
    required String totalAmount,
    required double progress,
    required String remainingAmount,
    required String splits,
    required String champions,
    required String backers,
    required String progressPercent,
  }) {
    return InkWell(
      onTap: () {
        Get.to(BillSummaryScreen(bill: bill));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            timeLeft,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => SortBillModal.show(context, bill),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Sort Bill",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "$amountPaid paid of $totalAmount",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            Text(
              "$remainingAmount remaining",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF007A74),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Text(
                        progressPercent,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      splits,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.emoji_events_outlined,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      champions,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.favorite_outline,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      backers,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        final paid = (index % 2 == 0) ? 200.0 : 0.0;
        final total = 500.0;
        final progress = total > 0 ? (paid / total) : 0.0;
        return _buildSimpleRequestCard(index, paid, total, progress);
      },
    );
  }

  Widget _buildSimpleRequestCard(
    int index,
    double paid,
    double total,
    double progress,
  ) {
    final paidFormatted = formatter.format(paid);
    final totalFormatted = formatter.format(total);
    final remaining = formatter.format(total - paid);
    return _buildSimpleCard(
      title: 'Request #${index + 1}',
      subtitle: 'Someone requested you to pay this',
      amountPaid: '₦$paidFormatted',
      totalAmount: '₦$totalFormatted',
      progress: progress,
      remaining: '₦$remaining',
      onTap: () {},
    );
  }

  Widget _buildSimpleCard({
    required String title,
    required String subtitle,
    required String amountPaid,
    required String totalAmount,
    required double progress,
    required String remaining,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

                ElevatedButton(
                  // onPressed: () => SortBillModal.show(
                  //   context,
                  //   widgetKeyForBillPlaceholder(),
                  // ),
                  onPressed: () => log("Sort Bill: ::::::"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    "Sort Bill",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              "$amountPaid paid of $totalAmount",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),
            Text(
              "$remaining remaining",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF007A74),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleCompletedCard(
    int index,
    double paid,
    double total,
    double progress,
  ) {
    final paidFormatted = formatter.format(paid);
    final totalFormatted = formatter.format(total);
    final remaining = formatter.format(total - paid);
    return _buildSimpleCard(
      title: 'Completed #${index + 1}',
      subtitle: 'This request has been completed',
      amountPaid: '₦$paidFormatted',
      totalAmount: '₦$totalFormatted',
      progress: progress,
      remaining: '₦$remaining',
      onTap: () {},
    );
  }

  Widget _buildSimpleCancelledCard(
    int index,
    double paid,
    double total,
    double progress,
  ) {
    final paidFormatted = formatter.format(paid);
    final totalFormatted = formatter.format(total);
    final remaining = formatter.format(total - paid);
    return _buildSimpleCard(
      title: 'Cancelled #${index + 1}',
      subtitle: 'This request has been cancelled',
      amountPaid: '₦$paidFormatted',
      totalAmount: '₦$totalFormatted',
      progress: progress,
      remaining: '₦$remaining',
      onTap: () {},
    );
  }

  Widget _buildHistoryView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _historySubTab = 'Completed'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _historySubTab == 'Completed'
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Completed',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _historySubTab == 'Completed'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _historySubTab = 'Cancelled'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _historySubTab == 'Cancelled'
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Cancelled',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: _historySubTab == 'Cancelled'
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _historySubTab == 'Completed'
              ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 2,
                  itemBuilder: (context, index) {
                    final paid = 500.0;
                    final total = 500.0;
                    final progress = 1.0;
                    return _buildSimpleCompletedCard(
                      index,
                      paid,
                      total,
                      progress,
                    );
                  },
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 1,
                  itemBuilder: (context, index) {
                    final paid = 0.0;
                    final total = 400.0;
                    final progress = 0.0;
                    return _buildSimpleCancelledCard(
                      index,
                      paid,
                      total,
                      progress,
                    );
                  },
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: selectedTab == 'Bill'
              ? RefreshIndicator(
                  onRefresh: _fetchSplitBills,
                  color: const Color(0xFF007A74),
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _splitBills.isEmpty
                      ? const Center(
                          child: Text(
                            "No split bills found",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _splitBills.length,
                          itemBuilder: (context, index) {
                            final bill = _splitBills[index];
                            final progress = bill.totalAmount > 0
                                ? bill.totalCollected / bill.totalAmount
                                : 0.0;

                            final daysLeft = bill.dueDate
                                ?.difference(DateTime.now())
                                .inDays;
                            final timeLeft = (daysLeft ?? 0) > 0
                                ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left"
                                : "Overdue";

                            final paidFormatted = formatter.format(
                              bill.totalCollected,
                            );
                            final totalFormatted = formatter.format(
                              bill.totalAmount,
                            );
                            final remaining =
                                bill.totalAmount - bill.totalCollected;
                            final remainingFormatted = formatter.format(
                              remaining,
                            );

                            final championsCount = bill.participants
                                ?.where((p) => p.status == "paid")
                                .length;
                            final backersCount = bill.participants
                                ?.where((p) => p.amountPaid > 0)
                                .length;

                            return _buildBillCard(
                              bill: bill,
                              title: bill.title ?? "title goes here",
                              timeLeft: timeLeft,
                              amountPaid: paidFormatted,
                              totalAmount: totalFormatted,
                              progress: progress,
                              remainingAmount: remainingFormatted,
                              splits:
                                  "${bill.totalParticipants} Split${bill.totalParticipants == 1 ? '' : 's'}",
                              champions:
                                  "$championsCount Champion${championsCount == 1 ? '' : 's'}",
                              backers:
                                  "$backersCount Backer${backersCount == 1 ? '' : 's'}",
                              progressPercent: "${(progress * 100).toInt()}%",
                            );
                          },
                        ),
                )
              : selectedTab == 'Request'
              ? _buildRequestList()
              : _buildHistoryView(),
        ),
      ],
    );
  }
}
