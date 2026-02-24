import 'package:expandable_page_view/expandable_page_view.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/get_core.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/auth/create_password_widget.dart';
import 'package:greyfundr/features/auth/forgot_password_widget.dart';
import 'package:greyfundr/features/auth/signin_widget.dart';
import 'package:greyfundr/features/auth/signup_personal/signup_personal_info_screen.dart';
import 'package:greyfundr/features/auth/signup_personal/signup_personal_otp_screen.dart';
import 'package:greyfundr/features/auth/signup_personal/signup_personal_screen.dart';
import 'package:greyfundr/features/auth/verify_otp_widget.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class SignupPersonalOutlet extends StatefulWidget {
  const SignupPersonalOutlet({super.key});

  @override
  State<SignupPersonalOutlet> createState() => _SignupPersonalOutletState();
}

class _SignupPersonalOutletState extends State<SignupPersonalOutlet> {
  AuthProvider? authProvider;
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider?.disposePersonalSignup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      body: SizedBox(
        height: SizeConfig.screenHeight,
        child: Stack(
          children: [
            Stack(
              children: [
                Container(
                  height: SizeConfig.heightOf(60),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/images/auth_bg.png"),
                    ),
                  ),
                ),
                Positioned(
                  right: 15,
                  left: 15,
                  top: 5,
                  child: SafeArea(
                    child: SizedBox(
                      width: SizeConfig.screenWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AdaptiveIcons(
                            onTap: () {
                              if (authProvider.currentSignupPage > 0) {
                                authProvider.animateToNextPage(
                                  authProvider.currentSignupPage - 1,
                                );
                              } else {
                                Get.close(1);
                              }
                            },
                            iconName: "arrow.left.circle",
                            iconData: Icons.arrow_back,
                          ),
                          AdaptiveIcons(
                            iconName: "questionmark.circle",
                            iconData: Icons.help_outline,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "GreyFundr",
                      style: txStyle30SemiBold.copyWith(
                        color: appPrimaryColor,
                        fontSize: 35,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              bottom: 0,
              child: Container(
                width: SizeConfig.screenWidth,
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 20,
                ),
                decoration: BoxDecoration(color: Color(0xffD9F1F3)),
                child: ExpandablePageView(
                  controller: authProvider.signupPageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    SignupPersonalScreen(),
                    SignupPersonalOtpScreen(),
                    SignupPersonalInfoScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
