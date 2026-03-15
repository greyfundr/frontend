import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart';
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart';
import 'package:greyfundr/core/models/split_bill_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:greyfundr/features/shared/notification.dart';
import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/features/profile/profile_screen.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/services/custom_alert.dart';
import 'package:greyfundr/shared/utils.dart';

class PayBillsScreen extends StatefulWidget {
  const PayBillsScreen({super.key});

  @override
  State<PayBillsScreen> createState() => _PayBillsScreenState();
}

class _PayBillsScreenState extends State<PayBillsScreen> {
  final SplitBillApi _splitBillApi = SplitBillApiImpl();
  final ScrollController _scrollController = ScrollController();

  List<SplitBill> _splitBills = [];
  bool _isLoading = false;
  String? _errorMessage;

  final Set<String> _selectedIds = {}; // selected bill ids

  final formatter = NumberFormat('#,##0.00');

  @override
  void initState() {
    super.initState();
    _fetchSplitBills();
  }

  Future<void> _fetchSplitBills() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bills = await _splitBillApi.getAllSplitBills();
      if (mounted) {
        setState(() {
          _splitBills = bills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load bills';
          _isLoading = false;
        });
      }
    }
  }

  double get _selectedTotal {
    double total = 0;
    for (var b in _splitBills) {
      if (_selectedIds.contains(b.id)) total += (b.amount ?? 0.0);
    }
    return total;
  }

  int get _selectedCount => _selectedIds.length;

  Widget _buildLeftList() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_splitBills.isEmpty) return const Center(child: Text('No split bills found'));

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      itemCount: _splitBills.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final bill = _splitBills[index];
        final selected = _selectedIds.contains(bill.id);
        return InkWell(
          onTap: () {
            setState(() {
              if (selected) _selectedIds.remove(bill.id); else _selectedIds.add(bill.id);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 6, offset: Offset(0,2))],
            ),
            child: Row(
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (_) {
                    setState(() {
                      if (selected) _selectedIds.remove(bill.id); else _selectedIds.add(bill.id);
                    });
                  },
                ),
                const SizedBox(width: 8),
                CustomNetworkImage(imageUrl: bill.imageUrl ?? '', radius: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text('₦${formatter.format(bill.amount ?? 0.0)}', style: const TextStyle(color: Colors.green)),
                      const SizedBox(height: 4),
                      Text(DateFormat.yMMMd().format(bill.dueDate), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayCardForBill(SplitBill bill) {
    final paidFormatted = formatter.format(bill.amountRaised);
    final totalFormatted = formatter.format(bill.amount);
    final daysLeft = bill.dueDate.difference(DateTime.now()).inDays;
    final timeLeft = daysLeft > 0 ? '$daysLeft Day${daysLeft == 1 ? '' : 's'} left' : 'Overdue';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.grey, blurRadius: 8, offset: Offset(0,4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomNetworkImage(imageUrl: bill.imageUrl ?? '', radius: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(bill.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('₦${formatter.format(bill.amount ?? 0.0)}', style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text(timeLeft, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  // single bill quick-pay (placeholder)
                  showCustomBottomSheet(AddMoneySheet(), context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF007A74)),
                child: const Text('Pay'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    final selected = _splitBills.where((b) => _selectedIds.contains(b.id)).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: selected.isEmpty
                ? Center(child: Text('No bills selected', style: txStyle12wt.copyWith(color: Colors.grey)))
                : ListView.builder(
                    itemCount: selected.length,
                    itemBuilder: (_, i) => _buildPayCardForBill(selected[i]),
                  ),
          ),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Selected: $_selectedCount', style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('Total: ₦${formatter.format(_selectedTotal)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedCount == 0 ? null : () {
                // placeholder pay action
                showCustomBottomSheet(AddMoneySheet(), context);
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B35)),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Pay Selected', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final userProfile = userProvider.userProfileModel;

    final bool noAncestorNav = context.findAncestorWidgetOfExactType<BottomNavigationBar>() == null;
    if (noAncestorNav && userProvider.selectedIndex != 1) userProvider.updateSelectedIndex(1);
    userProvider.setSuppressAppNav(noAncestorNav);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pay Bills', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const NotificationScreen());
            },
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // optional header similar to BillScreen condensed
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: const Color(0xFF007A74),
              child: Row(
                children: [
                  CustomOnTap(
                    onTap: () { Get.to(() => const SettingsScreen()); },
                    child: Row(children: [CustomNetworkImage(imageUrl: 'imageUrl', radius: 24), const SizedBox(width: 8),]),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('${userProfile?.firstName ?? ''} ${userProfile?.lastName ?? ''}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  IconButton(
                    onPressed: () { showCustomBottomSheet(AddMoneySheet(), context); },
                    icon: const Icon(Icons.add, color: Colors.white),
                  ),
                ],
              ),
            ),

            // main two-column area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(flex: 5, child: _buildLeftList()),
                    const SizedBox(width: 12),
                    Container(width: 360, child: _buildRightPanel()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
