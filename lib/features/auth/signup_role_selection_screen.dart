import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/auth/auth_outlet.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/auth/signup_group/signup_group_outlet.dart';
import 'package:greyfundr/features/auth/signup_personal/signup_personal_outlet.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

List<RoleSelectionClass> roles = [
  RoleSelectionClass(
    roleName: "Personal",
    roleImage: "assets/images/personal.png",
    roleDescription:
        "By setting up a Personal Account, you gain and control all aspects of this Account",
  ),
  RoleSelectionClass(
    roleName: "Group",
    roleImage: "assets/images/group.png",
    roleDescription:
        "This account type allows you to create and manage a group account, where multiple users can collaborate and contribute to the same account. Ideal for community, business, organizations, charities and non-profits.",
  ),
];

class SignupRoleSelectionScreen extends StatelessWidget {
  const SignupRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AdaptiveIcons(
                  iconName: "arrow.left.circle",
                  iconData: Icons.arrow_back,
                  onTap: () {
                    Get.close(1);
                  },
                ),
                AdaptiveIcons(
                  iconName: "questionmark.circle",
                  iconData: Icons.help_outline,
                  onTap: () {},
                ),
              ],
            ),
            Gap(20),
            Text("Account Type", style: txStyle30SemiBold),
            Text(
              "Select the type of account that best suit your need",
              style: txStyle14.copyWith(color: greyTextColor),
            ),
            Gap(20),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: roles.length,
              itemBuilder: (context, index) {
                var role = roles.elementAt(index);
                bool isSelected = authProvider.selectedRole == role.roleName;
                return CustomOnTap(
                  onTap: () {
                    authProvider.setSelectedRole(role.roleName);
                  },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 500),
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? appSecondaryColor : borderColor,
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(role.roleImage, width: 60, height: 60),
                        Gap(20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${role.roleName} Account",
                                style: txStyle16SemiBold,
                              ),
                              // Gap(5),
                              Text(
                                role.roleDescription,
                                maxLines: isSelected ? 10 : 2,
                                overflow: TextOverflow.ellipsis,
                                style: txStyle12.copyWith(color: greyTextColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).marginOnly(bottom: 20),
                );
              },
            ),
            Gap(20),

            CustomButton(
              enabled: authProvider.selectedRole.isNotEmpty,
              onTap: () {
                if (authProvider.selectedRole == "Personal") {
                  Get.to(
                    SignupPersonalOutlet(),
                    transition: Transition.rightToLeft,
                  );
                } else {
                  Get.to(
                    SignupGroupOutlet(),
                    transition: Transition.rightToLeft,
                  );
                }
              },
              label: "Continue",
            ),

            Gap(10),
            Center(
              child: CustomOnTap(
                onTap: () {
                  Get.off(AuthOutlet(), transition: Transition.rightToLeft);
                },
                child: RichText(
                  text: TextSpan(
                    text: "Already have an account? ",
                    style: txStyle13.copyWith(color: Colors.black),
                    children: [
                      TextSpan(
                        text: "Login",
                        style: txStyle13.copyWith(color: appPrimaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).paddingSymmetric(horizontal: SizeConfig.widthOf(5)),
      ),
    );
  }
}

class RoleSelectionClass {
  final String roleName;
  final String roleImage;
  final String roleDescription;

  RoleSelectionClass({
    required this.roleName,
    required this.roleImage,
    required this.roleDescription,
  });
}
