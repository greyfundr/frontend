import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/bill/bill_screen.dart';
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
  final List<Widget> _views = [HomeScreen(), BillScreen(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      var userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUserProfileApi();
    });
  }

  // Maaynr

  @override
  Widget build(BuildContext context) {
    var userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      body: _views.elementAt(userProvider.selectedIndex),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(primaryColor: Colors.white),
        child: BottomNavigationBar(
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
          currentIndex: userProvider.selectedIndex,
          selectedItemColor: appPrimaryColor,
          unselectedItemColor: greyTextColor,
          onTap: (index) {
            doHepticFeedback();
            userProvider.updateSelectedIndex(index);
          },
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset(
                    'assets/svgs/home.svg',
                    color: userProvider.selectedIndex == 0
                        ? appPrimaryColor
                        : greyTextColor,
                  ),
                ),
              ),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset(
                    'assets/svgs/bills.svg',
                    color: userProvider.selectedIndex == 1
                        ? appPrimaryColor
                        : greyTextColor,
                  ),
                ),
              ),
              label: 'Bills',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: SvgPicture.asset(
                    'assets/svgs/profile.svg',
                    color: userProvider.selectedIndex == 2
                        ? appPrimaryColor
                        : greyTextColor,
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
