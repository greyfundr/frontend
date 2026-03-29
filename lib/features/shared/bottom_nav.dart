import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/bill/bill__outlet_screen.dart';
import 'package:greyfundr/features/charity/charity_screen.dart';
import 'package:greyfundr/features/event/event_home.dart';
import 'package:greyfundr/features/home/home_screen.dart';
import 'package:greyfundr/features/profile/profile_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
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
    });
  }

  // Maaynr

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.red,
      body: SafeArea(
        top: false,
        child: _views.elementAt(userProvider.selectedIndex)),
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
    );
  }
}
