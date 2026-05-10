import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greyfundr/core/models/split_bill_response_model.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
import 'package:greyfundr/features/bill/lifestyle_screen.dart';
import 'package:greyfundr/features/campaign/campaign_option_screen.dart';
import 'package:greyfundr/features/charity/charity_provider.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/features/event/event_screen.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/features/new_split_bill/create_split_bill_screen.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:greyfundr/features/shared/notification.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/features/bill/bill-stack/transfer_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/pay_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/request_bill.dart';
import 'package:greyfundr/features/bill/bill-stack/split_bill.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/shared/utils.dart';

class BillOutletScreen extends StatefulWidget {
  const BillOutletScreen({super.key});

  @override
  State<BillOutletScreen> createState() => _BillOutletScreenState();
}

class ConcaveBottomClipper extends CustomClipper<Path> {
  final double depth;

  const ConcaveBottomClipper({this.depth = 30});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - depth)
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height,
        size.width * 0.5,
        size.height - 0,
      )
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height,
        0,
        size.height - depth,
      )
      ..close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _BillOutletScreenState extends State<BillOutletScreen>
    with SingleTickerProviderStateMixin {
  // for Bill | Charity | Lifestyle
  // late TabController _tabController; (Moved to EventProvider)

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = true;
  bool _areFeatureIconsVisible = true;
  double _previousScrollOffset = 0.0;
  bool _isBalanceVisible = true;

  // For Sort Bill modal
  final TextEditingController donorController = TextEditingController();
  String? nickname;
  String? donorName;
  String? comment;

  late UserProvider _userProvider;
  late EventProvider _eventProvider;

  @override
  void initState() {
    super.initState();
    _userProvider = Provider.of<UserProvider>(context, listen: false);
    _eventProvider = Provider.of<EventProvider>(context, listen: false);
    _eventProvider.initBillOutletController(this);
    _scrollController.addListener(_scrollListener);
    // _fetchSplitBills();
  }

  @override
  void dispose() {
    // _tabController.dispose(); (Handled in EventProvider)
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    donorController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    final currentOffset = _scrollController.offset;
    final delta = currentOffset - _previousScrollOffset;

    if (delta.abs() < 5) {
      _previousScrollOffset = currentOffset;
      return;
    }

    const double threshold = 30.0;

    if (delta > 0 && currentOffset > threshold) {
      if (_areFeatureIconsVisible) {
        setState(() => _areFeatureIconsVisible = false);
      }
    } else if (delta < 0 && currentOffset < 100) {
      if (!_areFeatureIconsVisible) {
        setState(() => _areFeatureIconsVisible = true);
      }
    }

    _previousScrollOffset = currentOffset;
  }

  double _innerPreviousOffset = 0.0;

  bool _handleInnerScroll(ScrollNotification notification) {
    // Only react to direct scrolls (not nested overscroll/refresh notifications)
    if (notification.depth > 1) return false;
    if (notification is! ScrollUpdateNotification) return false;

    final currentOffset = notification.metrics.pixels;
    final delta = currentOffset - _innerPreviousOffset;

    if (delta.abs() < 5) {
      _innerPreviousOffset = currentOffset;
      return false;
    }

    const double threshold = 30.0;

    if (delta > 0 && currentOffset > threshold) {
      if (_areFeatureIconsVisible) {
        setState(() => _areFeatureIconsVisible = false);
      }
    } else if (delta < 0 && currentOffset < 100) {
      if (!_areFeatureIconsVisible) {
        setState(() => _areFeatureIconsVisible = true);
      }
    }

    _innerPreviousOffset = currentOffset;
    return false;
  }

  Widget _billSummaryColumn(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          amount,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _headerTabButton(String title, bool isActive, int index) {
    return GestureDetector(
      onTap: () {
        _eventProvider.billOutletTabController.animateTo(index);
        // if (title == 'Charity') {
        //   Get.toNamed('/charity'); // ← no transition param needed anymore
        // } else if (title == 'Lifestyle') {
        //   Get.toNamed('/lifestyle');
        // }
        // Bill does nothing
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: isActive ? 15 : 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: isActive ? 24 : 16,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureIcon(
    String label,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
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

  Widget _charityCategoryItem({
    required String label,
    required String asset,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const bgColor = Color(0x3300A4AF);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00A4AF)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Image.asset(asset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: txStyle12.copyWith(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _charityCategoryRow() {
    final provider = Provider.of<CharityProvider>(context);
    final selected = provider.selectedCategory;

    final items = <Map<String, String>>[
      {'label': 'All', 'asset': 'assets/images/grey_wallet.png'},
      {'label': 'Medical', 'asset': 'assets/images/medidal.png'},
      {'label': 'Education', 'asset': 'assets/images/education.png'},
      {'label': 'Travel', 'asset': 'assets/images/travel.png'},
      {'label': 'Nature', 'asset': 'assets/images/nature.png'},
      {'label': 'Animal', 'asset': 'assets/images/animals.png'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _charityCategoryItem(
              label: items[i]['label']!,
              asset: items[i]['asset']!,
              isSelected: selected == items[i]['label'],
              onTap: () => provider.setCategory(items[i]['label']!),
            ),
            if (i != items.length - 1) const SizedBox(width: 20),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final eventProvider = Provider.of<EventProvider>(context);
    var userProfile = userProvider.userProfileModel;
    var walletModel = walletProvider.walletModel;
    // If shown standalone (no ancestor BottomNavigationBar), make sure
    // the provider marks Bills as active so the compact nav highlights it.
    // final bool noAncestorNav =
    //     context.findAncestorWidgetOfExactType<BottomNavigationBar>() == null;
    // if (noAncestorNav && userProvider.selectedIndex != 1) {
    //   userProvider.updateSelectedIndex(1);
    // }
    // userProvider.setSuppressAppNav(noAncestorNav);

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: Column(
        children: [
          // Animated Header
          GestureDetector(
            onTap: () {
              setState(() {
                _isHeaderCollapsed = !_isHeaderCollapsed;
              });
            },
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  width: double.infinity,
                  height: _isHeaderCollapsed
                      ? Platform.isIOS
                            ? 200
                            : 170
                      : 340,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xff02494d),
                          Color(0xFF005b61),
                          Color(0xFF039da7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: SafeArea(
                      child: Stack(
                        children: [
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  if (_isHeaderCollapsed)
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CustomOnTap(
                                            onTap: () {
                                              Get.to(
                                                () => const SettingsScreen(),
                                                transition:
                                                    Transition.rightToLeft,
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                CustomNetworkImage(
                                                  imageUrl:
                                                      "${userProfile?.profile?.image}",
                                                  radius: 40,
                                                ),
                                                Gap(10),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  _headerTabButton(
                                                    'Bill',
                                                    eventProvider
                                                            .billOutletTabController
                                                            .index ==
                                                        0,
                                                    0,
                                                  ),
                                                  _headerTabButton(
                                                    'Charity',
                                                    eventProvider
                                                            .billOutletTabController
                                                            .index ==
                                                        1,
                                                    1,
                                                  ),
                                                  _headerTabButton(
                                                    'Event',
                                                    eventProvider
                                                            .billOutletTabController
                                                            .index ==
                                                        2,
                                                    2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.to(
                                                    () =>
                                                        const NotificationScreen(),
                                                    transition:
                                                        Transition.rightToLeft,
                                                  );
                                                },
                                                child: SvgPicture.asset(
                                                  "assets/svgs/notification.svg",
                                                  height: 22,
                                                  width: 22,
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                        Colors.white,
                                                        BlendMode.srcIn,
                                                      ),
                                                ),
                                              ),
                                              // const SizedBox(width: 16),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  else
                                    Row(
                                      children: [
                                        CustomOnTap(
                                          onTap: () {
                                            Get.to(
                                              () => const SettingsScreen(),
                                              transition:
                                                  Transition.rightToLeft,
                                            );
                                          },
                                          child: Row(
                                            children: [
                                              CustomNetworkImage(
                                                imageUrl:
                                                    "${userProfile?.profile?.image}",
                                                radius: 40,
                                              ),
                                              Gap(5),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Hello!",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Text(
                                              "${userProfile?.firstName ?? ''} ${userProfile?.lastName ?? ''}",
                                              style: txStyle13wt,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  // CustomOnTap(
                                  //   onTap: () {
                                  //     Get.to(() => const NotificationScreen());
                                  //   },
                                  //   child: SvgPicture.asset(
                                  //     "assets/svgs/notification.svg",
                                  //   ),
                                  // ),
                                ],
                              ),
                            ),
                          ),

                          AnimatedOpacity(
                            opacity: _isHeaderCollapsed ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 300),
                            child: Offstage(
                              offstage: _isHeaderCollapsed,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 55,
                                  left: 20,
                                  right: 20,
                                ),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 6),

                                    // Points + Trophy
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Left: Points text
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: const [
                                            Text(
                                              "Total Point",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              "0Pts",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            Text(
                                              "10 points to your next star",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ),

                                        // Right: Trophy — wrapped in a Column and pulled in from the edge
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            right: 20.0,
                                          ), // This brings it inward
                                          child: Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,

                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                      0,
                                                      108,
                                                      107,
                                                      107,
                                                    ),
                                                    width: 1.8,
                                                  ),
                                                ),
                                                child: Image.asset(
                                                  'assets/images/trophy.png',
                                                  width: 38,
                                                  height: 38,
                                                  errorBuilder: (_, __, ___) =>
                                                      const Icon(
                                                        Icons.emoji_events,
                                                        color: Colors.amber,
                                                        size: 38,
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Divider(
                                      color: Colors.white24,
                                      height: 10,
                                    ),

                                    // Balance + Add Money
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Total Balance",
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  convertStringToCurrency(
                                                    "${walletModel?.balance?.available}",
                                                  ),
                                                  style: txStyle18SemiBold
                                                      .copyWith(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                const SizedBox(width: 20),
                                                // Eye Icon with Toggle Functionality
                                                GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      _isBalanceVisible =
                                                          !_isBalanceVisible;
                                                    });
                                                  },
                                                  child: Icon(
                                                    _isBalanceVisible
                                                        ? Icons
                                                              .visibility_outlined
                                                        : Icons
                                                              .visibility_off_outlined,
                                                    color: Colors.white70,
                                                    size: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              "Escrow:  ${convertStringToCurrency("${walletModel?.balance?.escrow}")}",
                                              style: txStyle12wt,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          width: 100,
                                          child: ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor: Colors.white,
                                              shadowColor: Colors.transparent,
                                              elevation: 0,

                                              side: BorderSide.none,

                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 8,
                                                  ),
                                              tapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    showCustomBottomSheet(
                                                      AddMoneySheet(),
                                                      context,
                                                    );
                                                  },
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        "assets/svgs/add_money.svg",
                                                        height: 30,
                                                      ),
                                                      Text(
                                                        "Add Money",
                                                        style: txStyle12wt,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    const Divider(
                                      color: Colors.white24,
                                      height: 10,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 400),
                            top: _isHeaderCollapsed ? 60 : 200,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Total Bills",
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const Text(
                                      "₦0.00",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        _billSummaryColumn("Champion", "₦0.00"),
                                        const SizedBox(width: 24),
                                        _billSummaryColumn("Split", "₦0.00"),
                                        const SizedBox(width: 24),
                                        _billSummaryColumn("Backed", "₦0.00"),
                                      ],
                                    ),
                                  ],
                                ),

                                ElevatedButton(
                                  onPressed: () {
                                    eventProvider
                                                .billOutletTabController
                                                .index ==
                                            2
                                        ? Get.to(EventScreen())
                                        : eventProvider
                                                  .billOutletTabController
                                                  .index ==
                                              1
                                        ? Get.to(CampaignOptionScreen())
                                        : Get.to(CreateSplitBillScreen());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFF6B35),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.favorite_border, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        eventProvider
                                                    .billOutletTabController
                                                    .index ==
                                                2
                                            ? "Create Event"
                                            : eventProvider
                                                      .billOutletTabController
                                                      .index ==
                                                  1
                                            ? "Start Campaign"
                                            : "Create Bill",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Image.asset("assets/images/bill_page_curve.png"),
              ],
            ),
          ),

          // Feature Icons / Charity categories
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: !_areFeatureIconsVisible
                ? const SizedBox.shrink()
                : (eventProvider.billOutletTabController.index == 1)
                ? _charityCategoryRow()
                : Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _featureIcon(
                          "Pay Bill",
                          Icons.receipt,
                          Colors.amber,
                          onTap: () {},
                        ),
                        _featureIcon(
                          "Transfer Bill",
                          Icons.swap_horiz,
                          Colors.pink,
                          onTap: () {},
                        ),
                        _featureIcon(
                          "Split Bill",
                          Icons.call_split,
                          Colors.green,
                          onTap: () {},
                        ),
                        _featureIcon(
                          "Request Bill",
                          Icons.request_page,
                          Colors.orange,
                          onTap: () {},
                        ),
                        _featureIcon(
                          "Scan Bill",
                          Icons.qr_code_scanner,
                          Colors.blue,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
          ),

          // Main content
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: _handleInnerScroll,
              child: TabBarView(
                controller: eventProvider.billOutletTabController,
                children: [
                  // Bill sub-tab (shows secondary tabs + list)
                  BillScreen(),
                  // Container(),
                  // Container(color: Colors.green),
                  const CharityComponent(),
                  LifestyleScreen(),
                  // EventHome(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
