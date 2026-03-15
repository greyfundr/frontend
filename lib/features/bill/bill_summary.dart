// A screen that shows the full split bill summary for a provided `SplitBill`.
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:greyfundr/core/models/split_bill_model.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
// import './edit_split_bill.dart';
import 'package:greyfundr/features/splitbill/edit_split_bill.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/bill/sort_bill_modal.dart';

class BillSummaryScreen extends StatefulWidget {
  final SplitBill bill;

  const BillSummaryScreen({super.key, required this.bill});

  @override
  State<BillSummaryScreen> createState() => _BillSummaryScreenState();
}

class _BillSummaryScreenState extends State<BillSummaryScreen>
    with SingleTickerProviderStateMixin {
  late RefreshController _refreshController;
  late TabController _tabController;
  late SplitBill _bill;

  @override
  void initState() {
    super.initState();
    // Make a local mutable copy of the bill so we can update UI after edits
    _bill = widget.bill;
    _refreshController = RefreshController(initialRefresh: false);
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bill = _bill;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Builder(
        builder: (ctx) {
          final userProvider = Provider.of<UserProvider>(ctx, listen: false);
          final currentUserId = userProvider.userProfileModel?.id ?? '';

          final isCreator = currentUserId.isNotEmpty && currentUserId == bill.creatorId;

          if (isCreator) {
            return FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditSplitBill(initialBill: _bill),
                  ),
                ).then((result) {
                  // The editor now returns either `true` or the updated bill `data` map.
                  if (!mounted) return;
                  if (result == true) {
                    setState(() {});
                    return;
                  }

                  if (result is Map<String, dynamic>) {
                    try {
                      final updated = SplitBill.fromJson(result);
                      setState(() => _bill = updated);
                    } catch (_) {
                      setState(() {});
                    }
                  }
                });
              },
              backgroundColor: const Color(0xFF0D7377),
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                "MANAGE SPLIT BILL",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              ),
            );
          }

          return FloatingActionButton.extended(
            onPressed: () => SortBillModal.show(context, bill),
            backgroundColor: const Color(0xFF0D7377),
            icon: const Icon(Icons.sort, color: Colors.white),
            label: const Text(
              "SORT BILL",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: IconButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const BillScreen()),
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
                  if (bill.imageUrl != null && bill.imageUrl!.isNotEmpty)
                    Image.network(
                      bill.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/bill_summary_header.png',
                          fit: BoxFit.cover,
                        );
                      },
                    )
                  else
                    Container(color: Colors.grey[300]),
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

          SliverToBoxAdapter(
            child: _buildContent(bill),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(SplitBill bill) {
    final progress = bill.amount > 0 ? bill.amountRaised / bill.amount : 0.0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bill.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                _formatDate(bill.dueDate),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
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
                      "₦${bill.amountRaised.toStringAsFixed(2)} raised",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "of ₦${bill.amount.toStringAsFixed(2)}",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      "${bill.participants.where((p) => p.paid).length} of ${bill.totalParticipants} paid",
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Container(
          color: Colors.white,
          child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8.0),
              indicatorPadding: EdgeInsets.zero,
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

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildAboutTab(bill),
              _buildFinancingTab(bill),
              _buildParticipantsTab(bill.participants),
              const Center(child: Text("No comment so far")),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTab(SplitBill bill) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bill.title,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            bill.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.6),
          ),
          const SizedBox(height: 24),
          _buildInfoRow("Split Method", bill.splitMethod),
          _buildInfoRow("Due Date", _formatDate(bill.dueDate)),
          _buildInfoRow("Status", bill.status.toUpperCase()),
        ],
      ),
    );
  }

  Widget _buildFinancingTab(SplitBill bill) {
    final hasImage = bill.imageUrl != null && bill.imageUrl!.trim().isNotEmpty;

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
              child: Image.network(
                bill.imageUrl!,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 320,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 320,
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 320,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 80, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Bill / Receipt",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[700]),
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
                  _buildFinanceRow("Total Amount", "₦${bill.amount.toStringAsFixed(0)}", isBold: true),
                  const Divider(height: 32),
                  _buildFinanceRow("Number of Participants", "${bill.totalParticipants}"),
                  const Divider(height: 32),
                  _buildFinanceRow("Amount per Person", "₦${(bill.amount / bill.totalParticipants).toStringAsFixed(0)}"),
                  if (bill.splitMethod.isNotEmpty) ...[
                    const Divider(height: 32),
                    _buildFinanceRow("Split Method", bill.splitMethod),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Upload the bill/receipt to show detailed breakdown",
              style: TextStyle(color: Colors.grey[600], fontSize: 14, fontStyle: FontStyle.italic),
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
                Text("Funding Progress", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₦${bill.amountRaised.toStringAsFixed(0)} raised", style: const TextStyle(fontSize: 15)),
                    Text(
                      "${(bill.amount > 0 ? bill.amountRaised / bill.amount * 100 : 0).toStringAsFixed(0)}%",
                      style: const TextStyle(color: Color(0xFF0D7377), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: bill.amount > 0 ? bill.amountRaised / bill.amount : 0,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
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
        final progress = p.amountOwed > 0 ? p.amountPaid / p.amountOwed : 0.0;

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
                          : p.user != null && p.user!.firstName.trim().isNotEmpty
                              ? p.user!.firstName.trim()[0].toUpperCase()
                              : p.guestPhone != null && p.guestPhone!.trim().isNotEmpty
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
                          p.displayName,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                        if (p.guestPhone != null && p.guestPhone!.isNotEmpty)
                          Text(
                            p.guestPhone!,
                            style: TextStyle(color: Colors.grey[600], fontSize: 13),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.paid ? Colors.green.shade100 : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      p.paid ? "PAID" : "UNPAID",
                      style: TextStyle(
                        color: p.paid ? Colors.green.shade800 : Colors.orange.shade800,
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
                    "₦${p.amountPaid.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    " of ₦${p.amountOwed.toStringAsFixed(0)}",
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    "${(progress * 100).toStringAsFixed(0)}%",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D7377), fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D7377)),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF0D7377)),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}
