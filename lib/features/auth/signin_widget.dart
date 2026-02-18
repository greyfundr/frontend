import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/auth/create_pin_screen.dart';
import 'package:greyfundr/features/auth/signup_role_selection_screen.dart';
import 'package:greyfundr/features/shared/bottom_nav.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome back", style: txStyle27Bold),
        RichText(
          text: TextSpan(
            text: "Log in to ",
            style: txStyle13.copyWith(color: Colors.black),
            children: [
              TextSpan(
                text: "GreyFundr",
                style: txStyle14.copyWith(color: appPrimaryColor),
              ),
              TextSpan(text: " to continue", style: txStyle14),
            ],
          ),
        ),
        Gap(40),
        CustomTextField(
          hintText: "Enter Email or Phone",
          labelText: "Email or Phone",
          controller: _emailController,
        ),
        Gap(20),
        CustomTextField(
          hintText: "Enter Password",
          labelText: "Password",
          obscureText: true,
          controller: _passwordController,
        ),
        Gap(10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () {
                authProvider.animateToNextPage(1);
              },
              child: Text(
                "Forgot password?",
                style: txStyle13.copyWith(color: appPrimaryColor),
              ),
            ),
          ],
        ),

        Gap(20),

        CustomButton(
          onTap: () async {
            // Get.to(CreatePinScreen());
            bool res = await authProvider.signInApi(
              emailOrPhone: _emailController.text,
              password: _passwordController.text,
            );

            if (res) {
              Get.offAll(BottomNav(), transition: Transition.rightToLeft);
            }
          },
          label: "Log in",
        ),
        Gap(10),

        Center(
          child: CustomOnTap(
            onTap: () {
              Get.to(
                SignupRoleSelectionScreen(),
                transition: Transition.rightToLeft,
              );
            },
            child: RichText(
              text: TextSpan(
                text: "New to GreyFundr? ",
                style: txStyle13.copyWith(color: Colors.black),
                children: [
                  TextSpan(
                    text: "Sign up",
                    style: txStyle14.copyWith(color: appPrimaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
