import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greyfundr/core/models/split_bill_response_model.dart';
import 'package:greyfundr/features/splitbill/splitbill_provider.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:greyfundr/core/api/splitbill_api/splitbill_api.dart'; // ← correct interface
import 'package:greyfundr/core/api/splitbill_api/splitbill_api_impl.dart'; // ← correct impl
import 'package:greyfundr/core/models/ny_split_bill_model.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';

import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/features/shared/notification.dart';

import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/features/bill/bill__outlet_screen.dart';
import 'package:greyfundr/features/profile/profile_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/features/bill/sort_bill_modal.dart';
import 'package:greyfundr/features/bill/bill_summary.dart';

import 'package:gap/gap.dart';
// import 'package:greyfundr/services/custom_alert.dart';
import 'package:greyfundr/shared/utils.dart';

class PayBillScreen extends StatefulWidget {
  const PayBillScreen({super.key});

  @override
  State<PayBillScreen> createState() => _PayBillScreenState();
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

class _PayBillScreenState extends State<PayBillScreen>
    with SingleTickerProviderStateMixin {

  // for Bill | Charity | Lifestyle
  late TabController _tabController;

  final ScrollController _scrollController = ScrollController();
  bool _isHeaderCollapsed = true;
  double _previousScrollOffset = 0.0;
  bool _isBalanceVisible = true;
  bool _selectAll = false;
  // Track per-bill selection for the Select All feature
  final Map<String, bool> _selectedBills = {};

  // secondary tabs removed — show only Bill list

  // For Sort Bill modal
  final TextEditingController donorController = TextEditingController();
  String? nickname;
  String? donorName;
  String? comment;

  late UserProvider _userProvider;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this, initialIndex: 0);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    _scrollController.addListener(_scrollListener);

    Future.delayed(Duration.zero, () {
      _userProvider = Provider.of<UserProvider>(context, listen: false);
      var splitBillProvider = Provider.of<SplitBillProvider>(
        context,
        listen: false,
      );
      splitBillProvider.getCurrentUserSplitBill();
    });
    // _fetchSplitBills();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      if (!_isHeaderCollapsed) setState(() => _isHeaderCollapsed = true);
    } else if (delta < 0 && currentOffset < 100) {
      if (_isHeaderCollapsed) setState(() => _isHeaderCollapsed = false);
    }

    _previousScrollOffset = currentOffset;
  }

  String formatAmount(dynamic amount) {
    final numValue = int.tryParse(amount.toString()) ?? 0;
    return NumberFormat("#,###").format(numValue);
  }

  final formatter = NumberFormat('#,##0.00');

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

  Widget _headerTabButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (title == 'Charity') {
          Get.toNamed('/charity'); // ← no transition param needed anymore
        } else if (title == 'Lifestyle') {
          Get.toNamed('/lifestyle');
        }
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

  // Moved modal into SortBillModal widget (features/bill/sort_bill_modal.dart)

  Widget _buildBillCard({
    required SplitBillDatum bill,
    required String title,
    required String timeLeft,
    required String amountPaid,
    required String totalAmount,
    required double progress,
    required String remainingAmount,
    required String splits,
    required String champions,
    required String backers,
    required String progressPercent,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BillSummaryScreen(bill: bill)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 12, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Checkbox(
                    value: _selectedBills[bill.id] ?? false,
                    onChanged: (v) => setState(
                      () => _selectedBills["${bill.id}"] = v ?? false,
                    ),
                  ),
                ),
                CustomNetworkImage(imageUrl: "imageUrl", radius: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Row(
                      //   children: [
                      //     Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      //     const SizedBox(width: 6),
                      //     Text(
                      //       timeLeft,
                      //       style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        children: [
                          // Text(
                          //  "VIEW INVOICE",
                          //   style: TextStyle(color: Colors.grey[600], fontSize: 12),
                          // ),
                          ElevatedButton(
                            onPressed: () => SortBillModal.show(context, bill),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: const Color(0xFF007A74),
                              shadowColor: Colors.transparent,
                              elevation: 0,

                              side: BorderSide.none,

                              splashFactory: NoSplash.splashFactory,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 12,
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              "VIEW INVOICE",
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF007A74),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => SortBillModal.show(context, bill),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007A74),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text("Pay", style: TextStyle(fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              "$amountPaid paid of $totalAmount",
              style: TextStyle(color: Colors.grey[700], fontSize: 14),
            ),

            // Text(
            //   "Date - 12th Jan, 2027", // ← placeholder text since API doesn't return date
            //   style: TextStyle(color: Colors.grey[700], fontSize: 14),
            // ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // Simple card used for Request and History dummy lists

  // Request/History UI removed — only Bill list is used
  SplitBillDatum widgetKeyForBillPlaceholder() {
    return SplitBillDatum(
      id: 'placeholder',
      title: 'Placeholder',
      description: '',
      currency: 'NGN',
      totalAmount: 1000.0,
      creatorId: '',
      splitMethod: 'equal',
      dueDate: DateTime.now().add(const Duration(days: 7)),
      isFinalized: false,
      status: 'OPEN',
      imageUrl: '',
      totalParticipants: 1,
      totalCollected: 0.0,
      // t: 0.0,
      // percentageComplete: 0.0,
      // isOverdue: false,
      participants: [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);
    final splitBillProvider = Provider.of<SplitBillProvider>(context);

    var userProfile = userProvider.userProfileModel;
    var walletModel = walletProvider.walletModel;
    // If shown standalone (no ancestor BottomNavigationBar), make sure
    // the provider marks Bills as active so the compact nav highlights it.
    final bool noAncestorNav =
        context.findAncestorWidgetOfExactType<BottomNavigationBar>() == null;
    if (noAncestorNav && userProvider.selectedIndex != 1) {
      userProvider.updateSelectedIndex(1);
    }
    userProvider.setSuppressAppNav(noAncestorNav);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      // bottomNavigationBar: noAncestorNav
      //     ? Builder(builder: (ctx) {
      //         final up = Provider.of<UserProvider>(ctx);
      //         int mapTo3(int gi) {
      //           if (gi == 0) return 0;
      //           if (gi == 1) return 1;
      //           if (gi == 4) return 2;
      //           return 0;
      //         }
      //         return BottomNavigationBar(
      //           backgroundColor: Colors.white,
      //           type: BottomNavigationBarType.fixed,
      //           showUnselectedLabels: true,
      //           showSelectedLabels: true,
      //           elevation: 0,
      //           selectedFontSize: 12,
      //           unselectedFontSize: 12,
      //           unselectedLabelStyle: const TextStyle(
      //             color: greyTextColor,
      //             fontWeight: FontWeight.w500,
      //           ),
      //           selectedLabelStyle: const TextStyle(
      //             color: appPrimaryColor,
      //             fontWeight: FontWeight.w500,
      //           ),
      //           currentIndex: mapTo3(up.selectedIndex),
      //           selectedItemColor: appPrimaryColor,
      //           unselectedItemColor: greyTextColor,
      //           onTap: (i) {
      //             doHepticFeedback();
      //             if (i == 0) {
      //               up.updateSelectedIndex(0);
      //               Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const HomeScreen()));
      //               return;
      //             }
      //             if (i == 1) {
      //               up.updateSelectedIndex(1);
      //               Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const BillScreen()));
      //               return;
      //             }
      //             if (i == 2) {
      //               up.updateSelectedIndex(4);
      //               Navigator.pushReplacement(ctx, MaterialPageRoute(builder: (_) => const ProfileScreen()));
      //               return;
      //             }
      //           },
      //           items: [
      //             BottomNavigationBarItem(
      //               icon: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: SizedBox(
      //                   height: 20,
      //                   width: 20,
      //                   child: SvgPicture.asset(
      //                     'assets/svgs/home.svg',
      //                     colorFilter: ColorFilter.mode(
      //                       mapTo3(up.selectedIndex) == 0 ? appPrimaryColor : greyTextColor,
      //                       BlendMode.srcIn,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               label: 'Home',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: SizedBox(
      //                   height: 20,
      //                   width: 20,
      //                   child: SvgPicture.asset(
      //                     'assets/svgs/bills.svg',
      //                     colorFilter: ColorFilter.mode(
      //                       mapTo3(up.selectedIndex) == 1 ? appPrimaryColor : greyTextColor,
      //                       BlendMode.srcIn,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               label: 'Bills',
      //             ),
      //             BottomNavigationBarItem(
      //               icon: Padding(
      //                 padding: const EdgeInsets.all(8.0),
      //                 child: SizedBox(
      //                   height: 20,
      //                   width: 20,
      //                   child: SvgPicture.asset(
      //                     'assets/svgs/profile.svg',
      //                     colorFilter: ColorFilter.mode(
      //                       mapTo3(up.selectedIndex) == 2 ? appPrimaryColor : greyTextColor,
      //                       BlendMode.srcIn,
      //                     ),
      //                   ),
      //                 ),
      //               ),
      //               label: 'Profile',
      //             ),
      //           ],
      //         );
      //       })
      //     : null,
      body: SafeArea(
        child: Column(
          children: [
            // Animated Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: double.infinity,
              height: _isHeaderCollapsed ? 170 : 170,
              child: ClipPath(
                clipper: const ConcaveBottomClipper(depth: 30),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF007A74), Color(0xFF1D2D2C)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_isHeaderCollapsed)
                                Expanded(
                                  child: Row(
                                    children: [
                                      CustomOnTap(
                                        onTap: () {
                                          Get.back();
                                        },
                                        child: Row(
                                          children: const [
                                            Icon(
                                              Icons.arrow_back_ios,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Gap(40),
                                      Expanded(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              _headerTabButton(
                                                'Charity',
                                                _tabController.index == 1,
                                              ),
                                              _headerTabButton(
                                                'Bill',
                                                _tabController.index == 0,
                                              ),
                                              _headerTabButton(
                                                'Lifestyle',
                                                _tabController.index == 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          // Notification SVG - Opens NotificationScreen
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
                                          const SizedBox(width: 16),
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
                                          transition: Transition.rightToLeft,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          CustomNetworkImage(
                                            imageUrl: "imageUrl",
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
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              CustomOnTap(
                                onTap: () {
                                  Get.to(() => const NotificationScreen());
                                },
                                child: SvgPicture.asset(
                                  "assets/svgs/notification.svg",
                                ),
                              ),
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
                        top: _isHeaderCollapsed ? 60 : 80,
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
                                  "340",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                      "${convertStringToCurrency(walletModel?.balance?.available ?? "0")}",
                                      style: txStyle18SemiBold.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 20),

                                    // Eye Icon with Toggle Functionality
                                  ],
                                ),
                                Text(
                                  "Escrow:  ${convertStringToCurrency("${walletModel?.balance?.escrow ?? "0"}")}",
                                  style: txStyle12wt,
                                ),
                              ],
                            ),

                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                shadowColor: Colors.transparent,
                                elevation: 0,

                                side: BorderSide.none,

                                splashFactory: NoSplash.splashFactory,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 8,
                                ),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                                          MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/svgs/add_money.svg",
                                          height: 30,
                                        ),
                                        Text("Add Money", style: txStyle12wt),
                                      ],
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

            Gap(10),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Pay Bills",
                  style: TextStyle(
                    color: const Color.fromARGB(179, 41, 41, 41),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                // show the number of fetched bills beside the title
                Text(
                  "(${splitBillProvider.userSplitBills.length})",
                  style: TextStyle(
                    color: const Color.fromARGB(179, 41, 41, 41),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Gap(10),
              ],
            ),

            Gap(20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Checkbox(
                    value: _selectAll,
                    onChanged: (v) => setState(() {
                      _selectAll = v ?? false;
                      for (final b in splitBillProvider.userSplitBills) {
                        _selectedBills["${b.id}"] = _selectAll;
                      }
                    }),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select All',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF292929),
                    ),
                  ),
                  const Spacer(),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
                ],
              ),
            ),

            // Main content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Bill list container with fixed height so we can place a label below
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          height: 450,
                          child: RefreshIndicator(
                            onRefresh: () =>
                                splitBillProvider.getCurrentUserSplitBill(),
                            color: const Color(0xFF007A74),
                            child: ResponsiveState(
                              state: splitBillProvider.userSplitBillState,
                              busyWidget: const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: Center(
                                child: Text(
                                  "No split bills found",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              successWidget: ListView.builder(
                                controller: _scrollController,
                                padding: const EdgeInsets.all(16),
                                itemCount:
                                    splitBillProvider.userSplitBills.length,
                                itemBuilder: (context, index) {
                                  final bill =
                                      splitBillProvider.userSplitBills[index];
                                  final progress = ((bill.totalAmount ?? 0) > 0
                                      ? (bill.totalCollected ?? 0) /
                                            (bill.totalAmount ?? 0) *
                                            100
                                      : 0);

                                  final daysLeft = bill.dueDate
                                      ?.difference(DateTime.now())
                                      .inDays;
                                  final timeLeft = (daysLeft ?? 0) > 0
                                      ? "$daysLeft Day${daysLeft == 1 ? '' : 's'} left"
                                      : "Overdue";

                                  final paidFormatted = formatter.format(
                                    bill.totalCollected,
                                  );
                                  final totalFormatted = formatter.format(
                                    bill.totalAmount,
                                  );
                                  final remaining =
                                      bill.totalAmount - bill.totalCollected;
                                  final remainingFormatted = formatter.format(
                                    remaining,
                                  );

                                  final championsCount = bill.participants
                                      ?.where((p) => p.status == "paid")
                                      .length;
                                  final backersCount = bill.participants
                                      ?.where((p) => (p.amountPaid ?? 0) > 0)
                                      .length;

                                  return _buildBillCard(
                                    bill: bill,
                                    title: bill.title ?? "title",
                                    timeLeft: timeLeft,
                                    amountPaid: paidFormatted,
                                    totalAmount: totalFormatted,
                                    progress: progress,
                                    remainingAmount: remainingFormatted,
                                    splits:
                                        "${bill.totalParticipants} Split${bill.totalParticipants == 1 ? '' : 's'}",
                                    champions:
                                        "$championsCount Champion${championsCount == 1 ? '' : 's'}",
                                    backers:
                                        "$backersCount Backer${backersCount == 1 ? '' : 's'}",
                                    progressPercent:
                                        "${(progress * 100).toInt()}%",
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "1 Bill Selected",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                              Text(
                                "Total ₦ 100,000",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0xFFDDDDDD),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 12.0,
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => SortBillModal.show(
                                context,
                                widgetKeyForBillPlaceholder(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007A74),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
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
    );
  }
}
