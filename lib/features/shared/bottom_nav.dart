import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/core/providers/wallet_provider.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
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
  final List<Widget> _views = [HomeScreen(), BillScreen(), CharityScreen(), EventHome(), ProfileScreen()];

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
    int _mapToCompact(int gi) {
      if (gi == 0) return 0;
      if (gi == 1) return 1;
      if (gi == 4) return 2;
      return 0;
    }

    final compactIndex = _mapToCompact(userProvider.selectedIndex);

    return Scaffold(
      body: _views.elementAt(compactIndex),
      bottomNavigationBar: userProvider.suppressAppNav
          ? null
          : BottomNavigationBar(
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        showSelectedLabels: true,
        elevation: 0,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        unselectedLabelStyle: TextStyle(
          color: greyTextColor,
          fontWeight: FontWeight.w500,
        ),
        selectedLabelStyle: TextStyle(
          color: appPrimaryColor,
          fontWeight: FontWeight.w500,
        ),
        currentIndex: compactIndex,
        selectedItemColor: appPrimaryColor,
        unselectedItemColor: greyTextColor,
        onTap: (index) {
          doHepticFeedback();
          // map compact index back to global indices
          final map = {0: 0, 1: 1, 2: 4};
          final target = map[index] ?? 0;
          userProvider.updateSelectedIndex(target);
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
                    color: compactIndex == 0 ? appPrimaryColor : greyTextColor,
                ),
              ),
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  'assets/svgs/bills.svg',
                    color: compactIndex == 1 ? appPrimaryColor : greyTextColor,
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
                  'assets/svgs/bills.svg',
                  color: userProvider.selectedIndex == 2
                      ? appPrimaryColor
                      : greyTextColor,
                ),
              ),
            ),
            label: 'Charity',
          ),

          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  'assets/svgs/bills.svg',
                  color: userProvider.selectedIndex == 3
                      ? appPrimaryColor
                      : greyTextColor,
                ),
              ),
            ),
            label: 'Lifestyle',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: SvgPicture.asset(
                  'assets/svgs/profile.svg',
                    color: compactIndex == 2 ? appPrimaryColor : greyTextColor,
                ),
              ),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}