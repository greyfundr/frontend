import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/core/models/split_bill_query_model.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class SplitNotificationPage extends StatefulWidget {
  final String billId;

  const SplitNotificationPage({super.key, required this.billId});

  @override
  State<SplitNotificationPage> createState() => _SplitNotificationPageState();
}

class _SplitNotificationPageState extends State<SplitNotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewSplitBillProvider>(
        context,
        listen: false,
      ).getSplitBillQueries(widget.billId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: appPrimaryColor,
          onRefresh: () => provider.getSplitBillQueries(widget.billId),
          child: ResponsiveState(
            state: provider.splitBillQueriesState,
            busyWidget: UiBusyWidget(),
            errorWidget: UiErrorWidget(
              onRetry: () => provider.getSplitBillQueries(widget.billId),
            ),
            noDataAvailableWidget: UiNoDataAvailableWidget(
              height: SizeConfig.heightOf(60),
              message: "No notifications yet",
              subtitle: "Updates from this bill will appear here",
            ),
            successWidget: _SplitNotificationList(
              queries: provider.splitBillQueriesData,
            ),
          ),
        ),
      ),
    );
  }
}

class _SplitNotificationList extends StatelessWidget {
  final List<SplitBillQueryDatum> queries;

  const _SplitNotificationList({required this.queries});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: queries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) =>
          _SplitNotificationTile(query: queries[index]),
    );
  }
}

class _SplitNotificationTile extends StatelessWidget {
  final SplitBillQueryDatum query;

  const _SplitNotificationTile({required this.query});

  @override
  Widget build(BuildContext context) {
    final appearance = _appearanceFor(query.actionType);
    final actorName = 'John Doe';
    final amountDelta = query.amountDifference ?? 0;
    final currency = query.metadata?.currency ?? 'NGN';
    final hasAmount = amountDelta != 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffEDEFF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appearance.color.withValues(alpha: 0.12),
            ),
            child: Icon(appearance.icon, size: 18, color: appearance.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: actorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            TextSpan(
                              text: '  •  ${appearance.label}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (query.createdAt != null)
                      Text(
                        timeAgo(query.createdAt!),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
                if ((query.description ?? '').isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    query.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                      height: 1.4,
                    ),
                  ),
                ],
                if (hasAmount) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: appearance.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${amountDelta > 0 ? '+' : ''}'
                      '${currency == 'NGN' ? '₦' : '$currency '}'
                      '${_formatAmount(amountDelta.abs())}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: appearance.color,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAmount(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buffer.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  _NotificationAppearance _appearanceFor(String? actionType) {
    final type = (actionType ?? '').toUpperCase();
    if (type.contains('PAID') || type.contains('PAYMENT')) {
      return const _NotificationAppearance(
        icon: Icons.payments_outlined,
        color: Color(0xFF0B7A4B),
        label: 'Payment',
      );
    }
    if (type.contains('ACCEPT')) {
      return const _NotificationAppearance(
        icon: Icons.check_circle_outline,
        color: appPrimaryColor,
        label: 'Accepted',
      );
    }
    if (type.contains('DECLINE') || type.contains('REJECT')) {
      return const _NotificationAppearance(
        icon: Icons.cancel_outlined,
        color: appSecondaryColor,
        label: 'Declined',
      );
    }
    if (type.contains('REMIND')) {
      return const _NotificationAppearance(
        icon: Icons.notifications_outlined,
        color: Color(0xFFD69E2E),
        label: 'Reminder',
      );
    }
    if (type.contains('QUERY') || type.contains('COMMENT')) {
      return const _NotificationAppearance(
        icon: Icons.chat_bubble_outline,
        color: Color(0xFF3182CE),
        label: 'Message',
      );
    }
    if (type.contains('UPDATE') || type.contains('EDIT')) {
      return const _NotificationAppearance(
        icon: Icons.edit_outlined,
        color: Color(0xFF805AD5),
        label: 'Updated',
      );
    }
    return const _NotificationAppearance(
      icon: Icons.history_outlined,
      color: Color(0xFF4A5568),
      label: 'Activity',
    );
  }
}

class _NotificationAppearance {
  final IconData icon;
  final Color color;
  final String label;

  const _NotificationAppearance({
    required this.icon,
    required this.color,
    required this.label,
  });
}
