import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_circular_progress_indicator.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/core/models/transaction_model.dart';
import 'package:share_plus/share_plus.dart';

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
          child: const CustomCircularProgressIndicator(strokeWidth: 5),
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
              return InkWell(
                onTap: () => _showTransactionDetailsSheet(context, tx!),
                borderRadius: BorderRadius.circular(12),
                child: buildTransactionItem(tx!),
              );
            },
          ),
        ),
      ),
    );
  }
}

void _showTransactionDetailsSheet(BuildContext context, Datum tx) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TransactionDetailsSheet(tx: tx),
  );
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
  final s = _statusStyle(status);
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: s.bg,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      status.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: s.fg,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _StatusStyle {
  final Color bg;
  final Color fg;
  final IconData icon;
  const _StatusStyle(this.bg, this.fg, this.icon);
}

_StatusStyle _statusStyle(String status) {
  switch (status.toLowerCase()) {
    case 'successful':
    case 'completed':
      return _StatusStyle(
          Colors.green[50]!, Colors.green[700]!, Icons.check_circle_rounded);
    case 'pending':
      return _StatusStyle(
          Colors.orange[50]!, Colors.orange[800]!, Icons.access_time_rounded);
    case 'failed':
      return _StatusStyle(
          Colors.red[50]!, Colors.red[700]!, Icons.cancel_rounded);
    default:
      return _StatusStyle(
          Colors.grey[100]!, Colors.grey[700]!, Icons.info_outline_rounded);
  }
}

// ─────────────────────────────────────────────────────────────────────
// Details bottom sheet
// ─────────────────────────────────────────────────────────────────────
class _TransactionDetailsSheet extends StatefulWidget {
  final Datum tx;
  const _TransactionDetailsSheet({required this.tx});

  @override
  State<_TransactionDetailsSheet> createState() =>
      _TransactionDetailsSheetState();
}

class _TransactionDetailsSheetState extends State<_TransactionDetailsSheet> {
  final GlobalKey _receiptKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final tx = widget.tx;
    final isCredit = tx.direction == 'credit';
    final status = tx.status ?? 'pending';
    final s = _statusStyle(status);
    final dateString = tx.createdAt != null
        ? DateFormat('MMM dd, yyyy • h:mm a').format(tx.createdAt!)
        : '—';
    final amountText =
        "${isCredit ? '+' : '-'}${convertStringToCurrency("${tx.amount}")}";

    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              const Gap(10),
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    children: [
                      RepaintBoundary(
                        key: _receiptKey,
                        child: Container(
                          color: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 8),
                          child: Column(
                            children: [
                              // Status icon
                              Container(
                                width: 84,
                                height: 84,
                                decoration: BoxDecoration(
                                  color: s.bg,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(s.icon, color: s.fg, size: 44),
                              ),
                              const Gap(16),
                              Text(
                                amountText,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w800,
                                  color: isCredit
                                      ? Colors.green[700]
                                      : Colors.black87,
                                ),
                              ),
                              const Gap(6),
                              Text(
                                tx.description ?? 'Transaction',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Gap(8),
                              _buildStatusBadge(status),
                              const Gap(24),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xffF7F8FA),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    _DetailRow(
                                      label: 'Type',
                                      value: (tx.type ?? '').isNotEmpty
                                          ? tx.type!.toUpperCase()
                                          : '—',
                                    ),
                                    _DetailRow(
                                      label: 'Direction',
                                      value: isCredit ? 'Credit' : 'Debit',
                                    ),
                                    _DetailRow(
                                      label: 'Currency',
                                      value: tx.currency ?? '—',
                                    ),
                                    _DetailRow(
                                      label: 'Date',
                                      value: dateString,
                                    ),
                                    _DetailRow(
                                      label: 'Reference',
                                      value: tx.reference ?? '—',
                                      copyable: true,
                                    ),
                                    if ((tx.gatewayReference ?? '').isNotEmpty)
                                      _DetailRow(
                                        label: 'Gateway Ref',
                                        value: tx.gatewayReference!,
                                        copyable: true,
                                      ),
                                    _DetailRow(
                                      label: 'Transaction ID',
                                      value: tx.id ?? '—',
                                      copyable: true,
                                      isLast: true,
                                    ),
                                  ],
                                ),
                              ),
                              const Gap(16),
                              Text(
                                'GreyFundr Receipt',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Gap(20),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () => _shareReceipt(_receiptKey),
                          icon: const Icon(Icons.download_rounded,
                              color: Colors.white, size: 20),
                          label: const Text(
                            'Download Receipt',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: appPrimaryColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const Gap(8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool copyable;
  final bool isLast;
  const _DetailRow({
    required this.label,
    required this.value,
    this.copyable = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (copyable && value != '—') ...[
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Icon(Icons.copy_rounded,
                            size: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!isLast)
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Divider(height: 1, color: Color(0xFFEEEEEE)),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────
// Share helpers (capture RepaintBoundary → PNG → share_plus)
// ─────────────────────────────────────────────────────────────────────
Future<Uint8List> _captureImage(GlobalKey globalKey) async {
  final boundary = globalKey.currentContext!.findRenderObject()
      as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<void> _shareReceipt(GlobalKey globalKey) async {
  try {
    EasyLoading.show();
    final imageBytes = await _captureImage(globalKey);

    final tempDir = await getTemporaryDirectory();
    final imagePath =
        '${tempDir.path}/greyfundr_receipt_${DateTime.now().millisecondsSinceEpoch}.png';
    await File(imagePath).writeAsBytes(imageBytes);
    EasyLoading.dismiss();

    await SharePlus.instance.share(
      ShareParams(
        sharePositionOrigin: Rect.fromLTWH(
          0,
          0,
          MediaQuery.of(Get.context!).size.width,
          MediaQuery.of(Get.context!).size.height / 2,
        ),
        text: 'Here is your transaction receipt',
        files: [XFile(imagePath)],
      ),
    );
  } catch (_) {
    EasyLoading.dismiss();
  }
}
