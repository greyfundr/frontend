import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greyfundr/core/providers/socket_provider.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/bill/bill__outlet_screen.dart';
import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/features/profile/profile_screen.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final List<Widget> _views = [HomeScreen(), BillOutletScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      var walletProvider = Provider.of<WalletProvider>(context, listen: false);

      userProvider.fetchUserProfileApi();
      walletProvider.fetchUserWallet();
      walletProvider.fetchTransactions();
      userProvider.updateFcmToken();
      Provider.of<SocketProvider>(context, listen: false).connect();
    });
  }

 
  Future<bool> _confirmExit(BuildContext context) async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Close App?',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to close GreyFundr?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00484D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldExit = await _confirmExit(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.red,
        body: SafeArea(
          top: false,
          child: _views.elementAt(userProvider.selectedIndex),
        ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00484D), Color(0xFF0098A2)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
          showSelectedLabels: true,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          unselectedLabelStyle: TextStyle(
            color: Colors.white.withOpacity(.5),
            fontWeight: FontWeight.w500,
          ),
          selectedLabelStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          currentIndex: userProvider.selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(.5),
          onTap: (index) {
            doHepticFeedback();
            userProvider.updateSelectedIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    'assets/svgs/home.svg',
                    color: userProvider.selectedIndex == 0
                        ? Colors.white
                        : Colors.white.withOpacity(.5),
                  ),
                ),
              ),
              label: "Homes",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    'assets/svgs/bills.svg',
                    color: userProvider.selectedIndex == 1
                        ? Colors.white
                        : Colors.white.withOpacity(.5),
                  ),
                ),
              ),
              label: 'Bills',
            ),

            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: SvgPicture.asset(
                    'assets/svgs/profile.svg',
                    color: userProvider.selectedIndex == 2
                        ? Colors.white
                        : Colors.white.withOpacity(.5),
                  ),
                ),
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
      ),
    );
  }
}
