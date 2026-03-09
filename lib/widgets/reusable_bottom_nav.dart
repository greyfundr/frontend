import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';
import 'package:get/route_manager.dart';

Widget reusableBottomNav(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context);

  return BottomNavigationBar(
    backgroundColor: Colors.white,
    type: BottomNavigationBarType.fixed,
    showUnselectedLabels: true,
    showSelectedLabels: true,
    elevation: 0,
    selectedFontSize: 12,
    unselectedFontSize: 12,
    unselectedLabelStyle: const TextStyle(
      color: greyTextColor,
      fontWeight: FontWeight.w500,
    ),
    selectedLabelStyle: const TextStyle(
      color: appPrimaryColor,
      fontWeight: FontWeight.w500,
    ),
    currentIndex: userProvider.selectedIndex,
    selectedItemColor: appPrimaryColor,
    unselectedItemColor: greyTextColor,
    onTap: (index) {
      doHepticFeedback();
      userProvider.updateSelectedIndex(index);

      // If tapping Home or Profile → pop back to root if needed
      if (index != 1) {
        Get.until((route) => route.isFirst);
      }
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
              colorFilter: ColorFilter.mode(
                userProvider.selectedIndex == 0 ? appPrimaryColor : greyTextColor,
                BlendMode.srcIn,
              ),
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
              colorFilter: ColorFilter.mode(
                userProvider.selectedIndex == 1 ? appPrimaryColor : greyTextColor,
                BlendMode.srcIn,
              ),
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
              colorFilter: ColorFilter.mode(
                userProvider.selectedIndex == 2 ? appPrimaryColor : greyTextColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        label: 'Profile',
      ),
    ],
  );
}