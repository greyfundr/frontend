import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greyfundr/core/models/notification_model.dart' as nm;
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/bill/split_bill_details_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<UserProvider>(context, listen: false);
      await provider.fetchNotifications();
      _markPassiveNotificationsRead(provider);
    });
  }

  void _markPassiveNotificationsRead(UserProvider provider) {
    final ids = provider.notifications
        .where((n) => (n.isRead ?? false) == false && !_isActionable(n))
        .map((n) => n.id)
        .whereType<String>()
        .toList();
    if (ids.isNotEmpty) {
      provider.markNotificationsAsRead(ids: ids);
    }
  }

  bool _isActionable(nm.Notification n) {
    final billId = n.metadata?.billId;
    return billId != null && billId.isNotEmpty;
  }

  Future<void> _refresh() async {
    final provider = Provider.of<UserProvider>(context, listen: false);
    await provider.fetchNotifications();
    _markPassiveNotificationsRead(provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserProvider>(context);
    final hasUnread = provider.unreadNotificationsCount > 0;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F8FA),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 22,
          ),
          onPressed: () => Get.back(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            if (hasUnread) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: appSecondaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.unreadNotificationsCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        centerTitle: true,
        actions: [
          if (hasUnread)
            TextButton(
              onPressed: () => provider.markNotificationsAsRead(),
              child: const Text(
                'Read all',
                style: TextStyle(
                  color: appPrimaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: appPrimaryColor,
          onRefresh: _refresh,
          child: ResponsiveState(
            state: provider.notificationsState,
            busyWidget: const UiBusyWidget(),
            errorWidget: UiErrorWidget(onRetry: _refresh),
            noDataAvailableWidget: UiNoDataAvailableWidget(
              height: SizeConfig.heightOf(60),
              message: 'No notifications yet',
              subtitle: 'Updates and activities will appear here',
            ),
            successWidget: _NotificationList(
              notifications: provider.notifications,
              onTap: (n) => _openDetailsSheet(context, n),
              onDelete: (n) {
                if (n.id != null) provider.deleteNotification(n.id!);
              },
            ),
          ),
        ),
      ),
    );
  }

  void _openDetailsSheet(BuildContext context, nm.Notification n) {
    final provider = Provider.of<UserProvider>(context, listen: false);
    if (n.id != null && (n.isRead ?? false) == false) {
      provider.markNotificationsAsRead(ids: [n.id!]);
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _NotificationDetailsSheet(notification: n),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<nm.Notification> notifications;
  final void Function(nm.Notification) onTap;
  final void Function(nm.Notification) onDelete;

  const _NotificationList({
    required this.notifications,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final groups = _groupByDate(notifications);
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, sectionIndex) {
        final entry = groups.entries.elementAt(sectionIndex);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                4,
                sectionIndex == 0 ? 8 : 16,
                4,
                10,
              ),
              child: Text(
                entry.key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.4,
                ),
              ),
            ),
            ...entry.value.map(
              (n) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Dismissible(
                  key: ValueKey(n.id ?? UniqueKey().toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: appSecondaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: appSecondaryColor,
                    ),
                  ),
                  confirmDismiss: (_) async {
                    return await _confirmDelete(context) ?? false;
                  },
                  onDismissed: (_) => onDelete(n),
                  child: _NotificationTile(
                    notification: n,
                    onTap: () => onTap(n),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete notification?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: appSecondaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<nm.Notification>> _groupByDate(
    List<nm.Notification> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final groups = <String, List<nm.Notification>>{
      'TODAY': [],
      'YESTERDAY': [],
      'THIS WEEK': [],
      'EARLIER': [],
    };

    for (final n in items) {
      final created = n.createdAt;
      if (created == null) {
        groups['EARLIER']!.add(n);
        continue;
      }
      final day = DateTime(created.year, created.month, created.day);
      if (day == today) {
        groups['TODAY']!.add(n);
      } else if (day == yesterday) {
        groups['YESTERDAY']!.add(n);
      } else if (day.isAfter(weekAgo)) {
        groups['THIS WEEK']!.add(n);
      } else {
        groups['EARLIER']!.add(n);
      }
    }
    groups.removeWhere((_, v) => v.isEmpty);
    return groups;
  }
}

class _NotificationTile extends StatelessWidget {
  final nm.Notification notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final appearance = _appearanceFor(notification.type);
    final isUnread = (notification.isRead ?? false) == false;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? appPrimaryColor.withValues(alpha: 0.18)
                : const Color(0xffEDEFF3),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
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
                        child: Text(
                          notification.title ?? appearance.label,
                          style: TextStyle(
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (notification.createdAt != null)
                        Text(
                          timeAgo(notification.createdAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                    ],
                  ),
                  if ((notification.message ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      notification.message!,
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
            if (isUnread) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: appSecondaryColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationDetailsSheet extends StatelessWidget {
  final nm.Notification notification;

  const _NotificationDetailsSheet({required this.notification});

  @override
  Widget build(BuildContext context) {
    final appearance = _appearanceFor(notification.type);
    final billId = notification.metadata?.billId;
    final hasBillAction = billId != null && billId.isNotEmpty;
    final created = notification.createdAt;
    final dateLabel = created != null
        ? DateFormat('MMM dd, yyyy • hh:mm a').format(created.toLocal())
        : null;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: appearance.color.withValues(alpha: 0.12),
                  ),
                  child: Icon(
                    appearance.icon,
                    color: appearance.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title ?? appearance.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appearance.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            if ((notification.message ?? '').isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xffF7F8FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification.message!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            if (dateLabel != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    dateLabel,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
            ..._buildMetadataDetails(notification.metadata),
            const SizedBox(height: 22),
            if (hasBillAction)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: appPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Get.to(
                      () => SplitBillDetailsScreen(billId: billId),
                      transition: Transition.rightToLeft,
                    );
                  },
                  child: const Text(
                    'View Split Bill',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black87,
                    side: BorderSide(color: Colors.grey[300]!),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildMetadataDetails(nm.Metadata? metadata) {
    if (metadata == null) return [];
    final items = <Widget>[];
    if ((metadata.otp ?? '').isNotEmpty) {
      items.add(_metaTile(Icons.password_rounded, 'OTP Code', metadata.otp!));
    }
    if ((metadata.email ?? '').isNotEmpty) {
      items.add(_metaTile(Icons.mail_outline, 'Email', metadata.email!));
    }
    if ((metadata.phoneNumber ?? '').isNotEmpty) {
      items.add(
        _metaTile(Icons.phone_outlined, 'Phone', metadata.phoneNumber!),
      );
    }
    if ((metadata.link ?? '').isNotEmpty) {
      items.add(_metaTile(Icons.link_rounded, 'Link', metadata.link!));
    }
    if (items.isEmpty) return [];
    return [
      const SizedBox(height: 16),
      ...items.map((w) => Padding(padding: const EdgeInsets.only(top: 8), child: w)),
    ];
  }

  Widget _metaTile(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffEDEFF3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

_NotificationAppearance _appearanceFor(String? type) {
  final t = (type ?? '').toLowerCase();
  if (t.contains('split') || t.contains('bill')) {
    return const _NotificationAppearance(
      icon: Icons.receipt_long_rounded,
      color: appPrimaryColor,
      label: 'Split Bill',
    );
  }
  if (t.contains('campaign') || t.contains('donation')) {
    return const _NotificationAppearance(
      icon: Icons.volunteer_activism_outlined,
      color: Color(0xFF0B7A4B),
      label: 'Campaign',
    );
  }
  if (t.contains('event')) {
    return const _NotificationAppearance(
      icon: Icons.event_outlined,
      color: Color(0xFF3182CE),
      label: 'Event',
    );
  }
  if (t.contains('security')) {
    return const _NotificationAppearance(
      icon: Icons.shield_outlined,
      color: Color(0xFFD69E2E),
      label: 'Security',
    );
  }
  if (t.contains('auth') || t.contains('otp')) {
    return const _NotificationAppearance(
      icon: Icons.lock_outline_rounded,
      color: Color(0xFF805AD5),
      label: 'Verification',
    );
  }
  if (t.contains('wallet') || t.contains('payment') || t.contains('transfer')) {
    return const _NotificationAppearance(
      icon: Icons.account_balance_wallet_outlined,
      color: appSecondaryColor,
      label: 'Wallet',
    );
  }
  return const _NotificationAppearance(
    icon: Icons.notifications_none_rounded,
    color: Color(0xFF4A5568),
    label: 'Notification',
  );
}
