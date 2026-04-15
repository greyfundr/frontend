import 'package:flutter/material.dart';
import 'package:animated_digit/animated_digit.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/core/models/event_details_model.dart';
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

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      eventProvider = Provider.of<EventProvider>(context, listen: false);
      eventProvider?.getEventById(widget.eventId);
    });
  }

  final List<String> _fallbackCoverImages = const [
    'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=1200',
  ];

  @override
  void dispose() {
    _pageController.dispose();
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
                            Gap(20),

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
                          const TabBar(
                            isScrollable: true,
                            labelColor: appPrimaryColor,
                            unselectedLabelColor: Colors.black54,
                            indicatorColor: appPrimaryColor,
                            tabs: [
                              Tab(text: 'Details'),
                              Tab(text: 'Activity'),
                              Tab(text: 'Comment'),
                              Tab(text: 'Donation Board'),
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
                      _RsvpCommentTab(),
                      _RsvpDonationBoardTab(),
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
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
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
                      _showGiftAmountBottomSheet();
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

  Future<void> _showGiftAmountBottomSheet() async {
    final amountController = TextEditingController();
    final amountFocusNode = FocusNode();

    await showCustomBottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) {
          final amount = double.tryParse(amountController.text) ?? 0;

          return Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/bottom_sheet_cureve_right.png'),
                Container(
                  color: const Color(0xffF1F1F7),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.widthOf(5),
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Gift This Event',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: () {
                              amountFocusNode.requestFocus();
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Column(
                                children: [
                                  if (amount <= 0)
                                    Text(
                                      'Enter amount',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.grey[500],
                                      ),
                                    )
                                  else
                                    AnimatedDigitWidget(
                                      value: amount,
                                      textStyle: const TextStyle(
                                        fontSize: 34,
                                        fontWeight: FontWeight.w800,
                                        color: appPrimaryColor,
                                      ),
                                      enableSeparator: true,
                                      prefix: '₦',
                                    ),
                                  const Gap(4),
                                  Text(
                                    'Tap to type amount',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 0,
                            height: 0,
                            child: TextField(
                              controller: amountController,
                              focusNode: amountFocusNode,
                              autofocus: true,
                              keyboardType: TextInputType.number,
                              showCursor: false,
                              onChanged: (value) {
                                final sanitized = value.replaceAll(
                                  RegExp(r'[^0-9]'),
                                  '',
                                );
                                if (sanitized != value) {
                                  amountController.value = TextEditingValue(
                                    text: sanitized,
                                    selection: TextSelection.collapsed(
                                      offset: sanitized.length,
                                    ),
                                  );
                                }
                                setSheetState(() {});
                              },
                              decoration: const InputDecoration.collapsed(
                                hintText: '',
                              ),
                            ),
                          ),
                          const Gap(16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: amount <= 0
                                  ? null
                                  : () {
                                      Get.back();
                                      Get.to(
                                        PaymentMethodScreen(
                                          type: 'gifting',
                                          eventId: widget.eventId,
                                          amount: amount,
                                        ),
                                        transition: Transition.rightToLeft,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: appPrimaryColor,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: Colors.grey[300],
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      context,
      backgroundColor: Colors.transparent,
    );

    amountController.dispose();
    amountFocusNode.dispose();
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

class _RsvpCommentTab extends StatelessWidget {
  const _RsvpCommentTab();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Coming soon'));
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
