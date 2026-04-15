import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Form(
      key: _formKey,
      child: Column(
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
            controller: authProvider.emailOrPhoneForgotPasswordController,
            validator: (value) =>
                authProvider.validateEmailOrPhoneNumber(value ?? ""),
            onChanged: (value) {
              authProvider.notifyListeners();
            },
          ),

          Gap(40),

          CustomButton(
            onTap: () async {
              if (!_formKey.currentState!.validate()) return;
              bool res = await authProvider.forgotPassword(
                email: authProvider.emailOrPhoneForgotPasswordController.text,
              );
              if (res) {
                authProvider.animateToNextPage(2);
              }
            },
            label: "Continue",
          ),
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
      ),
    );
  }
}
