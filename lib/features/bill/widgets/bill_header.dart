import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

import 'package:greyfundr/features/shared/notification.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/components/custom_network_image.dart';

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

class BillHeader extends StatelessWidget {
  final bool isCollapsed;
  final TabController tabController;
  final dynamic userProfile;
  final dynamic walletModel;
  final bool isBalanceVisible;
  final VoidCallback onToggleBalance;
  final VoidCallback onAddMoney;
  final VoidCallback onCreateBill;

  const BillHeader({
    super.key,
    required this.isCollapsed,
    required this.tabController,
    this.userProfile,
    this.walletModel,
    required this.isBalanceVisible,
    required this.onToggleBalance,
    required this.onAddMoney,
    required this.onCreateBill,
  });

  Widget _headerTabButton(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (title == 'Charity') {
          Get.toNamed('/charity');
        } else if (title == 'Lifestyle') {
          Get.toNamed('/lifestyle');
        }
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

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: isCollapsed ? 170 : 300,
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
                      if (isCollapsed)
                        Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => Get.back(),
                                child: const Icon(Icons.arrow_back_ios, color: Colors.white),
                              ),
                              Gap(40),
                              Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      _headerTabButton('Charity', tabController.index == 1),
                                      _headerTabButton('Bill', tabController.index == 0),
                                      _headerTabButton('Lifestyle', tabController.index == 2),
                                    ],
                                  ),
                                ),
                              ),
                              Row(children: [
                                GestureDetector(
                                  onTap: () => Get.to(() => const NotificationScreen(), transition: Transition.rightToLeft),
                                  child: SvgPicture.asset(
                                    "assets/svgs/notification.svg",
                                    height: 22,
                                    width: 22,
                                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                                const SizedBox(width: 16),
                              ]),
                            ],
                          ),
                        )
                      else
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => Get.to(() => const SettingsScreen(), transition: Transition.rightToLeft),
                              child: Row(children: const [CustomNetworkImage(imageUrl: "imageUrl", radius: 40), Gap(5)]),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Hello!", style: TextStyle(color: Colors.white70, fontSize: 13)),
                                Text(
                                  '{userProfile?.firstName ?? ''} {userProfile?.lastName ?? ''}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                          ],
                        ),
                      GestureDetector(
                        onTap: () => Get.to(() => const NotificationScreen()),
                        child: SvgPicture.asset("assets/svgs/notification.svg"),
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedOpacity(
                opacity: isCollapsed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Offstage(
                  offstage: isCollapsed,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 55, left: 20, right: 20),
                    child: Column(children: const [SizedBox(height: 6), Divider(color: Colors.white24, height: 10)]),
                  ),
                ),
              ),

              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                top: isCollapsed ? 60 : 200,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Bills", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const Text("₦0.00", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Row(children: [
                          _billSummaryColumn("Champion", "₦0.00"),
                          const SizedBox(width: 24),
                          _billSummaryColumn("Split", "₦0.00"),
                          const SizedBox(width: 24),
                          _billSummaryColumn("Backed", "₦0.00"),
                        ]),
                      ],
                    ),

                    ElevatedButton(
                      onPressed: onCreateBill,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B35),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.favorite_border, size: 14), SizedBox(width: 6), Text("Create Bill", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _billSummaryColumn(String label, String amount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(amount, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
