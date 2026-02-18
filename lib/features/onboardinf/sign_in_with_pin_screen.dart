import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_num_pad.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

import 'package:provider/provider.dart';

class SignInWithPinScreen extends StatefulWidget {
  const SignInWithPinScreen({super.key});

  @override
  State<SignInWithPinScreen> createState() => _SignInWithPinScreenState();
}

class _SignInWithPinScreenState extends State<SignInWithPinScreen> {
  AuthProvider? authProvider;
  final TextEditingController pinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authProvider = Provider.of<AuthProvider>(context, listen: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // authProvider?.disposePin();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    

    return Scaffold(
      backgroundColor: Color(0xffD9F1F3),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color(0xffD9F1F3),
        leading: SizedBox(),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Gap(0),
                        Text(
                          'Welcome Back',
                          style: txStyle14.copyWith(color: appPrimaryColor),
                        ),
                        // Gap(10),
                        Text(
                          'Welcome Back',
                          style: txStyle32Bold.copyWith(color: appPrimaryColor),
                        ),
                        Center(
                          child: Text(
                            'Enable faster sign in and transaction completion with PIN',
                            style: txStyle14,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Gap(64),
                        PinCodeText(pin: authProvider.newPin),
                        Spacer(),
                        NumPad(
                          onValue: (value) {
                            authProvider.addToPin(value);
                            // signInProvider.checkPinFiled();
                          },
                          onDelete: () {
                            authProvider.deleteFromPin();
                            // signInProvider.checkPinFiled();
                          },
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: CustomButton(onTap: () {}, label: ""),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
