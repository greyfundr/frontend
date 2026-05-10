import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/core/models/event_contributions_response_model.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
import 'package:greyfundr/core/providers/socket_provider.dart';
import 'package:greyfundr/features/bill/event_gift_bottom_sheet.dart';
import 'package:greyfundr/features/event/event_description_screen.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/features/payment/payment_method_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class RsvpDetailsScreen extends StatefulWidget {
  final String eventId;
  const RsvpDetailsScreen({super.key, required this.eventId});

  @override
  State<RsvpDetailsScreen> createState() => _RsvpDetailsScreenState();
}

class _RsvpDetailsScreenState extends State<RsvpDetailsScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  EventProvider? eventProvider;
  SocketProvider? _socketProvider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider?.getEventById(widget.eventId);
      eventProvider?.getEventLeaderboard(widget.eventId);
      _socketProvider = Provider.of<SocketProvider>(context, listen: false);
      _socketProvider?.subscribe('event', widget.eventId, () {
        eventProvider?.getEventById(widget.eventId);
        eventProvider?.getEventLeaderboard(widget.eventId);
      });
    });
  }

  final List<String> _fallbackCoverImages = const [
    'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=1200',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _socketProvider?.unsubscribe('event', widget.eventId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = Provider.of<EventProvider>(context);
    final currentEvent = eventProvider.eventDetailsModel;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      body: ResponsiveState(
        state: eventProvider.selectedEventState,
        busyWidget: const UiBusyWidget(),
        errorWidget: UiErrorWidget(
          onRetry: () => eventProvider.getEventById(widget.eventId),
        ),
        successWidget: SafeArea(
          child: Builder(
            builder: (context) {
              final event = eventProvider.eventDetailsModel;
              if (event == null) {
                return const Center(child: Text('No event details found'));
              }

              return DefaultTabController(
                length: 4,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildCoverCarousel(context, event),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Gap(20),
                            Text(
                              "${event.name ?? 'Event Name'}",
                              style: txStyle18SemiBold,
                            ).paddingSymmetric(
                              horizontal: SizeConfig.widthOf(5),
                            ),
                            // Gap(5),
                            _buildAmountProgressBar(event),
                          ],
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverTabBarDelegate(
                          TabBar(
                            isScrollable: true,
                            tabAlignment: TabAlignment.start,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.black87,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            dividerColor: Colors.transparent,
                            indicatorPadding: const EdgeInsets.symmetric(
                              vertical: 8,
                            ),
                            indicator: BoxDecoration(
                              color: appPrimaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            tabs: const [
                              Tab(text: 'About'),
                              Tab(text: 'Activity'),
                              Tab(text: 'Comment'),
                              Tab(text: 'Gift'),
                            ],
                          ),
                        ),
                      ),
                    ];
                  },
                  body: const TabBarView(
                    children: [
                      _RsvpDetailsTab(),
                      _RsvpActivityTab(),
                      SizedBox(),
                      _RsvpCommentTab(),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.transparent,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 5),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentEvent == null) return;
                      _showBuyItemsBottomSheet(currentEvent);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appSecondaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Buy Items',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final event = context
                          .read<EventProvider>()
                          .eventDetailsModel;
                      if (event == null) return;
                      showEventGiftBottomSheet(
                        context: context,
                        eventId: widget.eventId,
                        event: event,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Gift Us',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBuyItemsBottomSheet(EventDetailsModel event) {
    final rawItems = event.purchasableItems ?? [];
    final items = rawItems
        .whereType<dynamic>()
        .map((raw) {
          if (raw is Map<String, dynamic>) return raw;
          if (raw is Map) return Map<String, dynamic>.from(raw);
          return <String, dynamic>{};
        })
        .where((item) => item.isNotEmpty)
        .toList();

    final Map<int, int> selectedQuantity = {
      for (int i = 0; i < items.length; i++) i: 0,
    };

    showCustomBottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          double total = 0;
          int totalUnits = 0;
          for (int i = 0; i < items.length; i++) {
            final item = items[i];
            final unitPrice = _toDouble(item['price']);
            final qty = selectedQuantity[i] ?? 0;
            total += unitPrice * qty;
            totalUnits += qty;
          }

          return Container(
            color: const Color(0xffF1F1F7),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cart',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const Gap(6),
                    Text(
                      'Select preferred quantity for each item',
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                    ),
                    const Gap(12),
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Text(
                          'No purchasable items available.',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      )
                    else
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: SizeConfig.heightOf(46),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Gap(10),
                          itemBuilder: (context, index) {
                            final item = items[index];
                            final imagesRaw = item['images'];
                            String? firstImage;
                            if (imagesRaw is List && imagesRaw.isNotEmpty) {
                              firstImage = imagesRaw.first.toString();
                            }

                            final name = item['name']?.toString() ?? 'Item';
                            final unitPrice = _toDouble(item['price']);
                            final stock = _toInt(item['quantity']);
                            final selected = selectedQuantity[index] ?? 0;
                            final canAdd = stock <= 0 ? true : selected < stock;

                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: Row(
                                children: [
                                  if (firstImage != null &&
                                      firstImage.isNotEmpty)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        firstImage,
                                        width: 46,
                                        height: 46,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  else
                                    Container(
                                      width: 46,
                                      height: 46,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[100],
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.shopping_bag_outlined,
                                      ),
                                    ),
                                  const Gap(10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Gap(4),
                                        Text(
                                          convertStringToCurrency(
                                            unitPrice.toString(),
                                          ),
                                          style: TextStyle(
                                            color: Colors.grey[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      _CartQtyButton(
                                        icon: Icons.remove,
                                        onTap: selected <= 0
                                            ? null
                                            : () {
                                                setSheetState(() {
                                                  selectedQuantity[index] =
                                                      selected - 1;
                                                });
                                              },
                                      ),
                                      Container(
                                        width: 34,
                                        alignment: Alignment.center,
                                        child: Text(
                                          '$selected',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                      _CartQtyButton(
                                        icon: Icons.add,
                                        onTap: !canAdd
                                            ? null
                                            : () {
                                                setSheetState(() {
                                                  selectedQuantity[index] =
                                                      selected + 1;
                                                });
                                              },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const Gap(14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total ($totalUnits items)',
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Gap(4),
                                Text(
                                  convertStringToCurrency(
                                    total.toStringAsFixed(0),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: appPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 46,
                            child: ElevatedButton(
                              onPressed: total <= 0
                                  ? null
                                  : () {
                                      final selectedItems =
                                          <Map<String, dynamic>>[];
                                      for (int i = 0; i < items.length; i++) {
                                        final qty = selectedQuantity[i] ?? 0;
                                        if (qty <= 0) continue;
                                        final item = items[i];
                                        selectedItems.add({
                                          "name": item['name'],
                                          "quantity": qty,
                                          "price": _toDouble(item['price']),
                                        });
                                      }
                                      Get.back();
                                      Get.to(
                                        PaymentMethodScreen(
                                          type: 'purchase',
                                          eventId: widget.eventId,
                                          amount: total,
                                          extraPayload: {
                                            "items": selectedItems,
                                          },
                                        ),
                                        transition: Transition.rightToLeft,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                disabledBackgroundColor: Colors.grey[300],
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                ),
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      context,
      backgroundColor: Colors.transparent,
    );
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Widget _buildAmountProgressBar(EventDetailsModel event) {
    final raised = (event.amountRaised ?? 0).toDouble();
    final target = (event.targetAmount ?? 0).toDouble();
    final progress = target <= 0 ? 0.0 : (raised / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).round();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            appPrimaryColor.withValues(alpha: 0.16),
            appPrimaryColor.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: appPrimaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Event Gift Progress',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$percentage%',
                style: txStyle14SemiBold.copyWith(
                  fontSize: 15,
                  // fontWeight: FontWeight.w800,
                  color: appPrimaryColor,
                ),
              ),
            ],
          ),
          const Gap(10),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: progress,
              backgroundColor: Colors.white,
              valueColor: const AlwaysStoppedAnimation<Color>(appPrimaryColor),
            ),
          ),
          const Gap(10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Raised: ${convertStringToCurrency('${event.amountRaised ?? 0}')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Target: ${convertStringToCurrency('${event.targetAmount ?? 0}')}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (event.organizers != null && event.organizers!.isNotEmpty) ...[
            const Gap(16),
            Divider(color: appPrimaryColor.withValues(alpha: 0.2), height: 1),
            const Gap(12),
            const Text(
              'Organizers',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
            const Gap(8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: event.organizers!.length,
                separatorBuilder: (context, index) => const Gap(12),
                itemBuilder: (context, index) {
                  final org = event.organizers![index];
                  final name =
                      '${org.user?.firstName ?? ''} ${org.user?.lastName ?? ''}'
                          .trim();
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'O';
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: appPrimaryColor.withValues(alpha: 0.1),
                      ),
                    ),
                    padding: const EdgeInsets.only(right: 12, left: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: appPrimaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: appPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const Gap(8),
                        Text(
                          name.isNotEmpty ? name : 'Organizer',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCoverCarousel(BuildContext context, EventDetailsModel event) {
    final topPadding = MediaQuery.of(context).padding.top;
    final coverImages = (event.coverImages?.isNotEmpty ?? false)
        ? event.coverImages!
        : _fallbackCoverImages;

    return SizedBox(
      height: SizeConfig.heightOf(45),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: coverImages.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return CurvedCornerContainer(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(coverImages[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
          // Positioned.fill(
          //   child: DecoratedBox(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         begin: Alignment.topCenter,
          //         end: Alignment.bottomCenter,
          //         colors: [
          //           Colors.black.withValues(alpha: 0.2),
          //           Colors.transparent,
          //           Colors.black.withValues(alpha: 0.35),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
          Positioned(
            top: topPadding + 10,
            left: 14,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(coverImages.length, (index) {
                final isActive = _currentIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: isActive ? 22 : 7,
                  decoration: BoxDecoration(
                    color: isActive ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpDetailsTab extends StatelessWidget {
  const _RsvpDetailsTab();

  @override
  Widget build(BuildContext context) {
    final event = context.read<EventProvider>().eventDetailsModel;
    if (event == null) {
      return const Center(child: Text('No event details found'));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // _InfoTile(title: 'Event Name', value: event.name ?? 'N/A'),
        _InfoTile(title: 'Category', value: event.category?.name ?? 'N/A'),
        _InfoTile(
          title: 'Visibility',
          value: event.visibilityStatus == 'private' ? 'Private' : 'Public',
        ),
        _InfoTile(
          title: 'Date',
          value: event.startDateTime != null
              ? formatDateToString(event.startDateTime!)
              : 'N/A',
        ),
        _InfoTile(
          title: 'Venue',
          value: event.venueName ?? event.location?.address ?? 'N/A',
        ),
        if ((event.shortDescription ?? '').isNotEmpty)
          _InfoTile(title: 'About Event', value: event.shortDescription!),
      ],
    );
  }
}

class _RsvpActivityTab extends StatelessWidget {
  const _RsvpActivityTab();

  bool _isActivityActive(DateTime? activityTime) {
    if (activityTime == null) return false;
    final now = DateTime.now();
    return now.year == activityTime.year &&
        now.month == activityTime.month &&
        now.day == activityTime.day &&
        now.hour == activityTime.hour &&
        now.minute == activityTime.minute;
  }

  @override
  Widget build(BuildContext context) {
    final event = context.read<EventProvider>().eventDetailsModel;
    if (event == null) {
      return const Center(child: Text('No activities available yet'));
    }

    final activities = event.activities ?? [];
    if (activities.isEmpty) {
      return const Center(child: Text('No activities available yet'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      separatorBuilder: (_, __) => const Gap(12),
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isActive = _isActivityActive(activity.time);

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      activity.name ?? 'Activity',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.circle, color: Colors.green, size: 8),
                          Gap(4),
                          Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Gap(6),
              Text(
                activity.description ?? '',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const Gap(8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.time != null
                            ? formatDateToTime(activity.time!)
                            : 'No time',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Gap(4),
                      Text(
                        'Goal: ${convertStringToCurrency('${activity.targetAmount ?? 0}')}',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appPrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Gift'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RsvpCommentTab extends StatefulWidget {
  const _RsvpCommentTab();

  @override
  State<_RsvpCommentTab> createState() => _RsvpCommentTabState();
}

class _RsvpCommentTabState extends State<_RsvpCommentTab> {
  String subTab = 'ALL';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<EventProvider>(context, listen: false);
      final eventId = provider.eventDetailsModel?.id ?? '';
      if (eventId.isNotEmpty) {
        provider.getEventContributions(eventId);
      }
    });
  }

  void _onSubTabSelected(String key) {
    if (subTab == key) return;
    setState(() => subTab = key);
    final provider = Provider.of<EventProvider>(context, listen: false);
    final eventId = provider.eventDetailsModel?.id ?? '';
    if (eventId.isEmpty) return;
    if (key == 'ALL' && provider.contributions.isEmpty) {
      provider.getEventContributions(eventId);
    } else if (key == 'TOP' && provider.leaderboard.isEmpty) {
      provider.getEventLeaderboard(eventId);
    }
  }

  Future<void> _onRefresh(EventProvider provider, String eventId) {
    if (subTab == 'ALL') {
      return provider.getEventContributions(eventId, refresh: true);
    }
    return provider.getEventLeaderboard(eventId);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);
    final eventId = provider.eventDetailsModel?.id ?? '';

    return Column(
      children: [
        _DonorsSubTabBar(
          selected: subTab,
          onSelected: _onSubTabSelected,
        ),
        Expanded(
          child: RefreshIndicator(
            color: appPrimaryColor,
            onRefresh: () => _onRefresh(provider, eventId),
            child: subTab == 'ALL'
                ? _buildAllDonors(provider)
                : _buildTopDonors(provider),
          ),
        ),
      ],
    );
  }

  Widget _buildAllDonors(EventProvider provider) {
    return ResponsiveStateFunction(
      state: provider.contributionsState,
      onIdle: () => const _LeaderboardSkeleton(),
      onBusy: () => const _LeaderboardSkeleton(),
      onError: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: SizeConfig.heightOf(15)),
          Center(
            child: Text(
              "Couldn't load donors",
              style: txStyle14.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
      onNoDataAvailable: () => _emptyDonors(),
      onSuccess: () => _AllDonorsList(entries: provider.contributions),
    );
  }

  Widget _buildTopDonors(EventProvider provider) {
    return ResponsiveStateFunction(
      state: provider.leaderboardState,
      onIdle: () => const _LeaderboardSkeleton(),
      onBusy: () => const _LeaderboardSkeleton(),
      onError: () => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: SizeConfig.heightOf(15)),
          Center(
            child: Text(
              "Couldn't load leaderboard",
              style: txStyle14.copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
      onNoDataAvailable: () => _emptyDonors(),
      onSuccess: () => _LeaderboardList(entries: provider.leaderboard),
    );
  }

  Widget _emptyDonors() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: SizeConfig.heightOf(15)),
        Center(
          child: Column(
            children: [
              Icon(
                Icons.emoji_events_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const Gap(10),
              Text(
                "No contributors yet",
                style: txStyle16.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(4),
              Text(
                "Be the first to support this event",
                style: txStyle13.copyWith(color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DonorsSubTabBar extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _DonorsSubTabBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const items = [
      {'key': 'ALL', 'label': 'All Donors'},
      {'key': 'TOP', 'label': 'Top Donors'},
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xffF7F8FA),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: items.map((t) {
          final key = t['key']!;
          final label = t['label']!;
          final isSelected = selected == key;
          return GestureDetector(
            onTap: () => onSelected(key),
            child: Padding(
              padding: const EdgeInsets.only(right: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected ? appPrimaryColor : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? appPrimaryColor : Colors.grey[700],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _AllDonorsList extends StatelessWidget {
  final List<EventContribution> entries;

  const _AllDonorsList({required this.entries});

  String _formatAmount(double? amount) {
    final whole = amount?.round();
    final s = whole.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write(',');
    }
    return '₦${buf.toString()}';
  }

  double get _totalRaised =>
      entries.fold<double>(0, (sum, e) => sum + (e.amount ?? 0));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: appPrimaryColor.withValues(alpha: 0.06),
            border: Border.all(color: appPrimaryColor.withValues(alpha: 0.18)),
          ),
          child: Row(
            children: [
              const Icon(Icons.people_alt_rounded,
                  color: appPrimaryColor, size: 26),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "All donors",
                      style: txStyle14.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Gap(2),
                    Text(
                      "${entries.length} ${entries.length == 1 ? 'person' : 'people'} • ${_formatAmount(_totalRaised)} raised",
                      style: txStyle12.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(14),
        ...entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _AllDonorsRow(
              entry: e,
              amountLabel: _formatAmount(double.tryParse("${e.amount}") ?? 0),
            ),
          );
        }),
      ],
    );
  }
}

class _AllDonorsRow extends StatelessWidget {
  final EventContribution entry;
  final String amountLabel;

  const _AllDonorsRow({required this.entry, required this.amountLabel});

  @override
  Widget build(BuildContext context) {
    final image = (entry.image ?? '').trim();
    final hasImage = image.isNotEmpty;
    final comment = (entry.comment ?? '').trim();
    final hasComment = comment.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffEDEFF3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            CustomNetworkImage(
              imageUrl: image,
              radius: 42,
              borderRadius: 21,
            )
          else
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: appPrimaryColor.withValues(alpha: 0.1),
              ),
              child: Text(
                entry.displayName != null && entry.displayName!.isNotEmpty
                    ? entry.displayName![0].toUpperCase()
                    : 'U',
                style: txStyle14.copyWith(
                  color: appPrimaryColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        entry.displayName ?? 'Anonymous',
                        style: txStyle14.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      amountLabel,
                      style: txStyle14.copyWith(
                        color: appPrimaryColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (hasComment) ...[
                  const Gap(6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: appPrimaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 14,
                          color: appPrimaryColor.withValues(alpha: 0.7),
                        ),
                        const Gap(6),
                        Expanded(
                          child: Text(
                            comment,
                            style: txStyle12.copyWith(
                              color: Colors.grey[800],
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
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
}

class _LeaderboardSkeleton extends StatelessWidget {
  const _LeaderboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 5,
      separatorBuilder: (_, __) => const Gap(10),
      itemBuilder: (_, __) => Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}

class _LeaderboardList extends StatelessWidget {
  final List<EventLeaderboardEntry> entries;

  const _LeaderboardList({required this.entries});

  String _formatAmount(double amount) {
    final whole = amount.round();
    final s = whole.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final remaining = s.length - i;
      buf.write(s[i]);
      if (remaining > 1 && remaining % 3 == 1) buf.write(',');
    }
    return '₦${buf.toString()}';
  }

  double get _totalRaised =>
      entries.fold<double>(0, (sum, e) => sum + e.totalAmount);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              colors: [
                appPrimaryColor.withValues(alpha: 0.18),
                appPrimaryColor.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(color: appPrimaryColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: appPrimaryColor, size: 28),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Top contributors",
                      style: txStyle14.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Gap(2),
                    Text(
                      "${entries.length} ${entries.length == 1 ? 'person' : 'people'} • ${_formatAmount(_totalRaised)} raised",
                      style: txStyle12.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Gap(14),
        ...List.generate(entries.length, (index) {
          final entry = entries[index];
          final rank = index + 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _LeaderboardRow(
              rank: rank,
              entry: entry,
              amountLabel: _formatAmount(entry.totalAmount),
            ),
          );
        }),
      ],
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final EventLeaderboardEntry entry;
  final String amountLabel;

  const _LeaderboardRow({
    required this.rank,
    required this.entry,
    required this.amountLabel,
  });

  Color _accentColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFE6B800);
      case 2:
        return const Color(0xFF8E9AAF);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return appPrimaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor();
    final isPodium = rank <= 3;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPodium
              ? accent.withValues(alpha: 0.4)
              : const Color(0xffEDEFF3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.15),
            ),
            child: isPodium
                ? Icon(Icons.emoji_events, size: 18, color: accent)
                : Text(
                    '#$rank',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: accent,
                    ),
                  ),
          ),
          const Gap(12),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appPrimaryColor.withValues(alpha: 0.1),
            ),
            child: Text(
              entry.initials,
              style: txStyle14.copyWith(
                color: appPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.fullName,
                  style: txStyle14.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if ((entry.username ?? '').isNotEmpty) ...[
                  const Gap(2),
                  Text(
                    '@${entry.username}',
                    style: txStyle12.copyWith(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const Gap(8),
          Text(
            amountLabel,
            style: txStyle14.copyWith(
              color: appPrimaryColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _RsvpDonationBoardTab extends StatelessWidget {
  const _RsvpDonationBoardTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Donation board content coming soon'));
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(6),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CartQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _CartQtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.grey[200] : const Color(0xffF5F5F8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey[500] : Colors.black87,
        ),
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: const Color(0xffF7F8FA), child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _SliverTabBarDelegate oldDelegate) {
    return oldDelegate.tabBar != tabBar;
  }
}
