import 'package:flutter/material.dart';
import 'package:greyfundr/components/custom_circular_progress_indicator.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/core/models/transaction_model.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<WalletProvider>(context, listen: false).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = Provider.of<WalletProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: "Transaction History"),
      body: ResponsiveState(
        state: walletProvider.transactionState,
        busyWidget: Center(
          child: const CustomCircularProgressIndicator(
            // radius: 30,
            strokeWidth: 5,
          ),
        ),
        noDataAvailableWidget: buildEmptyState(),
        successWidget: RefreshIndicator(
          onRefresh: () => walletProvider.fetchTransactions(),
          color: Colors.black,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: walletProvider.transactionModel?.data?.length ?? 0,
            separatorBuilder: (context, index) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Divider(color: Color(0xFFEEEEEE), thickness: 1),
            ),
            itemBuilder: (context, index) {
              final tx = walletProvider.transactionModel?.data?[index];
              return buildTransactionItem(tx!);
            },
          ),
        ),
      ),
    );
  }
}

Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          "No Transactions Yet",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Your recent transactions will appear here.",
          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
        ),
      ],
    ),
  );
}

Widget buildTransactionItem(Datum tx) {
  final isCredit = tx.direction == 'credit';
  final dateString = tx.createdAt != null
      ? DateFormat('MMM dd, yyyy • h:mm a').format(tx.createdAt!)
      : "Unknown Date";
  final description = tx.description ?? "Transaction";
  final status = tx.status ?? "pending";

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 48,
          width: 48,
          decoration: BoxDecoration(
            color: isCredit ? Colors.green[50] : Colors.red[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? Colors.green[700] : Colors.red[700],
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateString,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${isCredit ? '+' : '-'}${convertStringToCurrency("${tx.amount}")}",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isCredit ? Colors.green[700] : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            _buildStatusBadge(status),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStatusBadge(String status) {
  Color bgColor;
  Color textColor;

  switch (status.toLowerCase()) {
    case 'successful':
    case 'success':
      bgColor = Colors.green[50]!;
      textColor = Colors.green[700]!;
      break;
    case 'pending':
      bgColor = Colors.orange[50]!;
      textColor = Colors.orange[800]!;
      break;
    case 'failed':
      bgColor = Colors.red[50]!;
      textColor = Colors.red[700]!;
      break;
    default:
      bgColor = Colors.grey[100]!;
      textColor = Colors.grey[700]!;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.5,
      ),
    ),
  );
}

String _formatAmount(String amountStr, String currency) {
  try {
    final amount = double.parse(amountStr);
    final value = amount / 100;
    final formatter = NumberFormat.currency(
      symbol: currency == 'NGN' ? '₦' : currency,
      decimalDigits: 2,
    );
    return formatter.format(value);
  } catch (_) {
    return "$currency $amountStr";
  }
}
