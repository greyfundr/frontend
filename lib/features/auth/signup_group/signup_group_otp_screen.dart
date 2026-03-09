import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_pin_input.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SignupGroupOtpScreen extends StatefulWidget {
  const SignupGroupOtpScreen({super.key});

  @override
  State<SignupGroupOtpScreen> createState() => _SignupGroupOtpScreenState();
}

class _SignupGroupOtpScreenState extends State<SignupGroupOtpScreen> {
  AuthProvider? authProvider;
  final _otpController = TextEditingController();
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
        Text("Verify OTP", style: txStyle27Bold),
        RichText(
          text: TextSpan(
            text: "We sent a code to your email and phone number ",
            style: txStyle13.copyWith(color: greyTextColor),
            children: [
              TextSpan(
                text: authProvider.emailController.text,
                style: txStyle13.copyWith(color: appPrimaryColor),
              ),
              TextSpan(
                text: " and ",
                style: txStyle13.copyWith(color: greyTextColor),
              ),
              TextSpan(
                text: authProvider.phoneController.text,
                style: txStyle13.copyWith(color: appPrimaryColor),
              ),
            ],
          ),
        ),
        Gap(40),

        Center(
          child: Lottie.asset("assets/lottie/verify_code.json", height: 100),
        ),
        Gap(40),

        Center(
          child: PINCodeInput2(controller: _otpController, inputLenght: 6),
        ),
        Gap(10),

        Center(
          child: TextButton(
            onPressed: authProvider.timerActive
                ? null
                : () async {
                    bool res = await authProvider.resendOtpApi(
                      email: authProvider.emailController.text,
                    );

                    if (res) {
                      authProvider.startTimer();
                    }
                  },
            child: authProvider.timerActive
                ? Text(
                    "Resend code in ${authProvider.secondsRemaining}",
                    style: txStyle14.copyWith(color: Colors.grey),
                  )
                : Text(
                    "Resend code",
                    style: txStyle14.copyWith(color: appPrimaryColor),
                  ),
          ),
        ),

        Gap(20),

        CustomButton(
          enabled: _otpController.text.length == 6,
          onTap: () async {
            bool res = await authProvider.verifyOtpApi(
              email: authProvider.emailController.text,
              otp: _otpController.text,
            );
            if (res) {
              authProvider.animateToNextSignupPage(2);
            }
          },
          label: "Continue",
        ),

        Gap(20),
      ],
    );
  }
}