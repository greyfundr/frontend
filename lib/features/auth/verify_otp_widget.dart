import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_pin_input.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class VerifyOtpWidget extends StatefulWidget {
  const VerifyOtpWidget({super.key});

  @override
  State<VerifyOtpWidget> createState() => _VerifyOtpWidgetState();
}

class _VerifyOtpWidgetState extends State<VerifyOtpWidget> {
  AuthProvider? authProvider;
  TextEditingController otpController = TextEditingController();
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
            text: "We sent a code to the phone number",
            style: txStyle13.copyWith(color: greyTextColor),
            children: [
              // TextSpan(
              //   text: "+234 803 456 7890",
              //   style: txStyle13.copyWith(color: appPrimaryColor),
              // ),
            ],
          ),
        ),
        Gap(40),

        Center(
          child: Lottie.asset("assets/lottie/verify_code.json", height: 100),
        ),
        Gap(40),

        Center(child: PINCodeInput2(inputLenght: 6, controller: otpController)),
        Gap(10),

        Center(
          child: TextButton(
            onPressed: authProvider.timerActive
                ? null
                : () async {
                    bool res = await authProvider.forgotPassword(
                      email: authProvider
                          .emailOrPhoneForgotPasswordController
                          .text,
                    );
                    otpController.clear();

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
          onTap: () async {
            bool res = await authProvider.verifyOtpApi(
              email: authProvider.emailOrPhoneForgotPasswordController.text,
              otp: otpController.text,
            );
            if (res) {
              authProvider.animateToNextPage(3);
            }
          },
          label: "Continue",
        ),

        Gap(20),
      ],
    );
  }
}