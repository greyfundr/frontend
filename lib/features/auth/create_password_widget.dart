import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_pin_input.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/auth/password_change_success_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class CreatePasswordWidget extends StatefulWidget {
  const CreatePasswordWidget({super.key});

  @override
  State<CreatePasswordWidget> createState() => _CreatePasswordWidgetState();
}

class _CreatePasswordWidgetState extends State<CreatePasswordWidget> {
  AuthProvider? authProvider;
  TextEditingController passwordController = TextEditingController();
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
      authProvider?.startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Create New Password", style: txStyle27Bold),
        Text(
          "Create a password with at list 6 letters and numbers. It should be something others can’t guess.",
          style: txStyle12.copyWith(color: greyTextColor),
        ),
        Gap(40),

        Center(child: Lottie.asset("assets/lottie/password.json", height: 120)),
        Gap(40),

        CustomTextField(
          hintText: "New Password",
          obscureText: true,
          controller: passwordController,
          onChanged: (val) {
            authProvider.checkPasswordStrength(val ?? "");
          },
        ),
        Gap(15),

        CustomTextField(hintText: "Confirm Password", obscureText: true),

        Gap(20),

        CustomButton(
          onTap: () async {
            bool res = await authProvider.createPassword(
              password: passwordController.text,
            );
            if (!res) return;
            Get.to(PasswordChangeSuccessScreen());
            authProvider.animateToNextPage(0);
          },
          label: "Change Password",
        ),

        Gap(20),
      ],
    );
  }
}