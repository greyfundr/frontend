import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class ForgotPasswordWidget extends StatelessWidget {
  const ForgotPasswordWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Forgot Password", style: txStyle27Bold),
        Text(
          "Enter your phone number or email, and we will send you a code",
          style: txStyle13.copyWith(color: greyTextColor),
        ),
        Gap(40),
        CustomTextField(
          hintText: "Enter Email or Phone",
          labelText: "Email or Phone",
        ),

        Gap(40),

        CustomButton(onTap: () {
          authProvider.animateToNextPage(2);
        }, label: "Continue"),
        Gap(10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                authProvider.animateToNextPage(0);
              },
              child: Text(
                "Remember your password? ",
                style: txStyle13.copyWith(color: appPrimaryColor),
              ),
            ),
          ],
        ),
        Gap(20),
      ],
    );
  }
}
