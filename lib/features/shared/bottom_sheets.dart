import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/onboardinf/onboarding_screen.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class LogoutAppSheet extends StatelessWidget {
  final String userName;
  const LogoutAppSheet({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.widthOf(5),
        vertical: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("About to logout?", style: txStyle16Bold),
          Gap(20),
          Text("Dear $userName, would you like to logout?", style: txStyle14),
          Gap(30),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onTap: () {
                      Get.close(1);
                    },
                    label: "Stay",
                    backgroundColor: Colors.transparent,
                    color: appPrimaryColor,
                    borderColor: appPrimaryColor,
                  ),
                ),
                Gap(10),
                Expanded(
                  child: CustomButton(
                    onTap: () {
                      logout();
                      UserLocalStorageService().clearUserData();
                      
                    },
                    label: "Logout",
                  ),
                ),
              ],
            ),
          ),
          Gap(20),
        ],
      ),
    );
  }
}