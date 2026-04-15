// import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:greyfundr/components/custom_network_image%20copy.dart';
import 'package:greyfundr/core/models/single_split_split_bill_model.dart';
import 'package:greyfundr/features/splitbill/splitbill_provider.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:greyfundr/core/api/auth_api/auth_api.dart';
import 'package:greyfundr/core/api/auth_api/auth_api_impl.dart';

import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';

import 'package:greyfundr/features/bill/bill__outlet_screen.dart';

class SplitBillSummaryScreen extends StatefulWidget {
  final String splitBillId;

  const SplitBillSummaryScreen({super.key, required this.splitBillId});

  @override
  State<SplitBillSummaryScreen> createState() => _SplitBillSummaryScreenState();
}

class _SplitBillSummaryScreenState extends State<SplitBillSummaryScreen>
    with SingleTickerProviderStateMixin {
  late RefreshController _refreshController;
  late TabController _tabController;

  final AuthApi _authApi = AuthApiImpl();

  final SplitBillApi _splitBillApi = SplitBillApiImpl();

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController(initialRefresh: false);
    _tabController = TabController(length: 4, vsync: this);
    Future.delayed(Duration.zero, () {
      final splitBillProv = Provider.of<SplitBillProvider>(
        context,
        listen: false,
      );
      splitBillProv.getSplitBillDetails(splitBillId: widget.splitBillId);
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final splitBillProvider = Provider.of<SplitBillProvider>(context);
    var splitBillDetils = splitBillProvider.splitBillDetails;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (ctx) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D7377),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF0D7377),
                              width: 0.6,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          // Navigator.of(ctx).pop();
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (_) => EditSplitBill(initialBill: bill)),
                          // ).then((result) {
                          //   if (!mounted) return;
                          //   if (result == true) {
                          //     setState(() {});
                          //     return;
                          //   }
                          //   if (result is Map<String, dynamic>) {
                          //     setState(() {});
                          //   }
                          // });
                        },
                        child: const Text(
                          'EDIT SPLIT BILL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D7377),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                              color: Color(0xFF0D7377),
                              width: 0.6,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (cctx) {
                              final TextEditingController reasonCtrl =
                                  TextEditingController();
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: MediaQuery.of(cctx).viewInsets.bottom,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Reason for Cancellation',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        'Description',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      TextField(
                                        controller: reasonCtrl,
                                        maxLines: 4,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText:
                                              'Enter reason for cancelling this split bill',
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(cctx).pop(),
                                            child: const Text('Close'),
                                          ),
                                          const SizedBox(width: 8),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF0D7377,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                side: const BorderSide(
                                                  color: Color(0xFF0D7377),
                                                  width: 0.6,
                                                ),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 14,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () async {
                                              // final reason = reasonCtrl.text
                                              //     .trim();
                                              // if (reason.isEmpty) {
                                              //   CustomMessageModal.show(
                                              //     context: context,
                                              //     message:
                                              //         'Please provide a reason',
                                              //     isSuccess: false,
                                              //   );
                                              //   return;
                                              // }
                                              // Navigator.of(cctx).pop();
                                              // final ok = await _splitBillApi
                                              //     .cancelSplitBill(
                                              //       splitBillId: bill.id,
                                              //       reason: reason,
                                              //     );
                                              // if (ok) {
                                              //   CustomMessageModal.show(
                                              //     context: context,
                                              //     message:
                                              //         'Split bill cancelled',
                                              //     isSuccess: true,
                                              //   );
                                              //   Navigator.of(
                                              //     context,
                                              //   ).pushAndRemoveUntil(
                                              //     MaterialPageRoute(
                                              //       builder: (_) =>
                                              //           const BillScreen(),
                                              //     ),
                                              //     (route) => false,
                                              //   );
                                              // } else {
                                              //   CustomMessageModal.show(
                                              //     context: context,
                                              //     message:
                                              //         'Failed to cancel split bill',
                                              //     isSuccess: false,
                                              //   );
                                              // }
                                            },
                                            child: const Text(
                                              'CONTINUE',
                                              style: TextStyle(
                                                color: Colors.white,
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
                            },
                          );
                        },
                        child: const Text(
                          'CANCEL SPLIT BILL',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        },
        backgroundColor: const Color(0xFF0D7377),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF0D7377), width: 0.6),
        ),
        label: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            "MANAGE SPLIT BILL",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () async {
          // await _fetchSplitBill();
          // if (mounted) {
          //   _refreshController.refreshCompleted();
          // }
        },
        header: const WaterDropHeader(
          complete: Icon(Icons.done, color: Color(0xFF0D7377)),
          failed: Icon(Icons.error, color: Colors.red),
        ),
        child: CustomScrollView(
          slivers: [
            // Hero Header
            SliverAppBar(
              expandedHeight: 196, // reduced by 30% (280 * 0.7)
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: IconButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const BillOutletScreen()),
                    (route) => false,
                  ),
                  icon: Image.asset(
                    'assets/images/arrow_back.png',
                    width: 32,
                    height: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomNetworkImageSqr(
                      imageUrl: splitBillDetils?.data?.imageUrl ?? "",
                      height: double.infinity,
                      width: double.infinity,
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.black54, Colors.transparent],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content
            SliverToBoxAdapter(child: _buildContent(splitBillDetils!)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(SingleSplitBillModel bill) {
    final progress = ((bill.data?.totalAmount ?? 0) > 0
        ? (bill.data?.totalCollected ?? 0) / (bill.data?.totalAmount ?? 0) * 100
        : 0);

    return Column(
      children: [
        // Progress Card
        Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEF),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
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
                      "₦${convertStringToCurrency("${bill.data?.totalCollected}")} raised",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D7377),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: double.tryParse(progress.toString()),
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF0D7377),
                    ),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // formatted with thousands separators
                      "of ${convertStringToCurrency("${bill.data?.totalAmount}")}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      "${bill.data?.participants?.where((p) => p.status == "paid").length} of ${bill.data?.totalParticipants} paid",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // TabBar
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF0D7377),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF0D7377),
            tabs: const [
              Tab(text: "About"),
              Tab(text: "Financing"),
              Tab(text: "Participants"),
              Tab(text: "Comments"),
            ],
          ),
        ),

        // TabBarView
        SizedBox(
          height: 350,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(bill),
              _buildFinancingTab(bill),
              _buildParticipantsTab(bill.data!.participants!),
              const Center(child: Text("No comments yet")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab(SingleSplitBillModel bill) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bill.data?.title ?? "title",
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            bill.data?.description ?? "description",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoRow("Split Method", bill.data?.splitMethod ?? "---"),
          _buildInfoRow(
            "Due Date",
            _formatDate(bill.data?.dueDate ?? DateTime.now()),
          ),
          _buildInfoRow("Status", "${bill.data?.status}".toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildFinancingTab(SingleSplitBillModel bill) {
    final hasImage =
        bill.data?.imageUrl != null &&
        (bill.data?.imageUrl!.trim().isNotEmpty ?? false);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Split Bill Receipt",
            style: const TextStyle(
              fontSize: 18,
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          if (hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: CustomNetworkImageSqr(
                imageUrl: "${bill.data?.imageUrl}",
                height: 320,
                width: double.infinity,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Bill / Receipt",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFinanceRow(
                    "Total Amount",
                    "₦${bill.data?.totalAmount?.toStringAsFixed(0)}",
                    isBold: true,
                  ),
                  const Divider(height: 32),
                  _buildFinanceRow(
                    "Number of Participants",
                    "${bill.data?.totalParticipants}",
                  ),
                  const Divider(height: 32),
                  _buildFinanceRow(
                    "Amount per Person",
                    "₦${((bill.data?.totalAmount ?? 0) / (bill.data?.totalParticipants ?? 0)).toStringAsFixed(0)}",
                  ),
                  const Divider(height: 32),
                  _buildFinanceRow(
                    "Split Method",
                    bill.data?.splitMethod ?? "---",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Upload the bill/receipt to show detailed breakdown",
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFEF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Funding Progress",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "₦${convertStringToCurrency("${bill.data?.totalCollected}")} raised",
                      style: const TextStyle(fontSize: 15),
                    ),
                    Text(
                      "${((bill.data?.totalAmount ?? 0) > 0 ? (bill.data?.totalCollected ?? 0) / (bill.data?.totalAmount ?? 0) * 100 : 0).toStringAsFixed(0)}%",
                      style: const TextStyle(
                        color: Color(0xFF0D7377),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: ((bill.data?.totalAmount ?? 0) > 0
                      ? (bill.data?.totalCollected ?? 0) /
                            (bill.data?.totalAmount ?? 0) *
                            100
                      : 0),
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0D7377),
                  ),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: isBold ? const Color(0xFF0D7377) : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildParticipantsTab(List<Participant> participants) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final p = participants[index];
        final progress = (p.amountOwed ?? 0) > 0
            ? (p.amountPaid ?? 0) / (p.amountOwed ?? 0)
            : 0.0;
        final bool isPaid = p.status != "unpaid";

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: const Color(0xFF0D7377),
                    child: Text(
                      p.guestName != null && p.guestName!.trim().isNotEmpty
                          ? p.guestName!.trim()[0].toUpperCase()
                          : p.user != null &&
                                p.user!.firstName!.trim().isNotEmpty
                          ? p.user!.firstName!.trim()[0].toUpperCase()
                          : p.guestPhone != null &&
                                p.guestPhone!.trim().isNotEmpty
                          ? p.guestPhone!.replaceAll(RegExp(r'[^0-9]'), '')[0]
                          : 'G',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.user?.firstName ?? "name",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (p.guestPhone != null && p.guestPhone!.isNotEmpty)
                          Text(
                            p.guestPhone!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isPaid
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isPaid ? "PAID" : "UNPAID",
                      style: TextStyle(
                        color: isPaid
                            ? Colors.green.shade800
                            : Colors.orange.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    convertStringToCurrency("${p.amountPaid}"),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    " of ₦${convertStringToCurrency("${p.amountOwed}")}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0D7377),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF0D7377),
                  ),
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0D7377),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}

class InvertedCurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, 20);

    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 1);

    var secondControlPoint = Offset(3 * size.width / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
