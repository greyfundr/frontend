import 'package:flutter/material.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/features/bill/bill-stack/pay_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/transfer_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/split_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/request_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/scan_bill.dart';

class FeatureIcons extends StatelessWidget {
  const FeatureIcons({Key? key}) : super(key: key);

  Widget _featureIcon(String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: txStyle12.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _featureIcon("Pay Bill", Icons.receipt, Colors.amber, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const PayBillScreen()));
          }),
          _featureIcon("Transfer Bill", Icons.swap_horiz, Colors.pink, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferBill()));
          }),
          _featureIcon("Split Bill", Icons.call_split, Colors.green, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SplittingBill()));
          }),
          _featureIcon("Request Bill", Icons.request_page, Colors.orange, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const RequestBillScreen()));
          }),
          _featureIcon("Scan Bill", Icons.qr_code_scanner, Colors.blue, () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SizedBox()));
          }),
        ],
      ),
    );
  }
}
