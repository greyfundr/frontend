import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/home/add_money_sheet.dart';
import 'package:greyfundr/features/settings/settings_screen.dart';
import 'package:greyfundr/features/shared/notification.dart';
import 'package:greyfundr/shared/utils.dart'; // for showCustomBottomSheet & convertStringToCurrency

// Import your screens (adjust paths if needed)
import 'package:greyfundr/features/bill/bill__outlet_screen.dart'; // ← add this
import 'package:greyfundr/features/event/event_home.dart'; // ← add this (or event_screen.dart)
import 'package:greyfundr/features/charity/charity_screen.dart';












class ConcaveBottomClipper extends CustomClipper<Path> {
  final double depth;
  const ConcaveBottomClipper({this.depth = 30});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - depth)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width * 0.5, size.height)
      ..quadraticBezierTo(size.width * 0.25, size.height, 0, size.height - depth)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class EventHeaderSection extends StatefulWidget {
  final bool isCollapsed;
  final VoidCallback onStartCampaign;
  final VoidCallback onSettings;

  const EventHeaderSection({
    super.key,
    required this.isCollapsed,
    required this.onStartCampaign,
    required this.onSettings,
  });

  @override
  State<EventHeaderSection> createState() => _EventHeaderSectionState();
}

class _EventHeaderSectionState extends State<EventHeaderSection> {
  bool _showBalance = true;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final walletProvider = Provider.of<WalletProvider>(context);

    final userProfile = userProvider.userProfileModel;

    final firstName = userProfile?.firstName ?? '';
    final lastName = userProfile?.lastName ?? '';

    // Wallet data
    final available = walletProvider.walletModel?.balance?.available ?? "0";
    final ledger = walletProvider.walletModel?.balance?.ledger ?? "0";
    final escrow = walletProvider.walletModel?.balance?.escrow ?? "0";

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      height: widget.isCollapsed ? 145 : 270,
      width: double.infinity,
      child: ClipPath(
        clipper: const ConcaveBottomClipper(depth: 30),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF007A74), Color.fromARGB(255, 29, 45, 44)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Stack(
            children: [
              // Top bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // Profile Avatar - Opens Settings
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => SettingsScreen(),
                                  transition: Transition.rightToLeft,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 23,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: const AssetImage('assets/images/personal.png'),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Greeting or tabs
                         widget.isCollapsed
    ? Row(
        children: [
         
          _tabButton('Bill', Get.currentRoute == '/bill', () {
            Get.offNamed('/bill');  // ← no transition here anymore
          }),
          _tabButton('Charity', Get.currentRoute == '/charity', () {
            Get.toNamed('/charity');  // ← no transition here
          }),
          _tabButton('Lifestyle', Get.currentRoute == '/lifestyle', () {
            Get.toNamed('/lifestyle');  // ← no transition here
          }),
        ],
      )
                                : Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Hello!",
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        "$firstName $lastName".trim().isEmpty ? "User" : "$firstName $lastName",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                          ],
                        ),
                        Row(
                          children: [
                            // Notification SVG - Opens NotificationScreen
                            GestureDetector(
                              onTap: () {
                                Get.to(
                                  () => const NotificationScreen(),
                                  transition: Transition.rightToLeft,
                                );
                              },
                              child: SvgPicture.asset(
                                "assets/svgs/notification.svg",
                                height: 22,
                                width: 22,
                                colorFilter: const ColorFilter.mode(
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
                  ),
                ),
              ),

              // Expanded content: Balance + Add Money (unchanged)
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: widget.isCollapsed
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.fromLTRB(20, 55, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),

                            // Points section (placeholder)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Total Point",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    Text(
                                      "0Pts",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      "10 points to your next star",
                                      style: TextStyle(color: Colors.white70, fontSize: 10),
                                    ),
                                  ],
                                ),
                                Image.asset(
                                  'assets/images/trophy.png',
                                  width: 48,
                                  height: 48,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.emoji_events, color: Colors.amber, size: 42),
                                ),
                              ],
                            ),

                            const Divider(color: Colors.white24, height: 10),

                            // Balance + Add Money
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Total Balance",
                                      style: TextStyle(color: Colors.white70, fontSize: 12),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          convertStringToCurrency(available),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _showBalance = !_showBalance;
                                            });
                                          },
                                          child: Icon(
                                            _showBalance
                                                ? Icons.remove_red_eye_outlined
                                                : Icons.visibility_off_outlined,
                                            color: Colors.white70,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Ledger: ${convertStringToCurrency(ledger)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                    Text(
                                      'Escrow: ${convertStringToCurrency(escrow)}',
                                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  width: 100,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      showCustomBottomSheet(
                                        const AddMoneySheet(),
                                        context,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                      shadowColor: Colors.transparent,
                                      elevation: 0,
                                      side: BorderSide.none,
                                      splashFactory: NoSplash.splashFactory,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                        horizontal: 8,
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/icons/plus2.svg',
                                          width: 22,
                                          height: 22,
                                          colorFilter: const ColorFilter.mode(
                                            Colors.white,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        const Text(
                                          "Add Money",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const Divider(color: Colors.white24, height: 10),
                          ],
                        ),
                      ),
              ),

              // Total Donations + Start Campaign (unchanged)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                top: widget.isCollapsed ? 62 : 200,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Total Gift",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          "₦0.00",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: widget.onStartCampaign,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B35),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.favorite_border, size: 14),
                            SizedBox(width: 6),
                            Text(
                              "Create Event",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
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
  }

  Widget _tabButton(String title, bool active, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // increased horizontal padding
        margin: const EdgeInsets.symmetric(horizontal: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: active ? Colors.white : Colors.white70,
                fontWeight: active ? FontWeight.bold : FontWeight.w500,
                fontSize: active ? 15 : 13,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: active ? 30 : 0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}