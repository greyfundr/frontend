import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class SignupPersonalScreen extends StatefulWidget {
  const SignupPersonalScreen({super.key});

  @override
  State<SignupPersonalScreen> createState() => _SignupPersonalScreenState();
}

class _SignupPersonalScreenState extends State<SignupPersonalScreen> {
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: SafeArea(
        child: Form(
          key: _formKey,
          child: SizedBox(
            height: SizeConfig.heightOf(50),
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Register", style: txStyle27Bold),
                  Text(
                    "Create a  GreyFundr account to continue",
                    style: txStyle13.copyWith(color: greyTextColor),
                  ),
                  Gap(20),
                  CustomTextField(
                    hintText: "Enter Email",
                    labelText: "Email",
                    textInputType: TextInputType.emailAddress,
                    controller: authProvider.emailController,
                    validator: (val) => authProvider.validateEmail(val!),
                  ),
                  Gap(15),
                  CustomTextField(
                    hintText: "090********",
                    labelText: "Phone Number",
                    textInputType: TextInputType.phone,
                    controller: authProvider.phoneController,
                    validator: (val) => authProvider.validatePhoneNumber(val!),
                  ),
                  Gap(15),
                  CustomTextField(
                    hintText: "********",
                    labelText: "Password",
                    textInputType: TextInputType.visiblePassword,
                    controller: authProvider.passwordController,
                    validator: (val) => authProvider.validatePassword(val!),
                    obscureText: true,
                  ),
                  Gap(15),
                  CustomTextField(
                    hintText: "********",
                    labelText: "Re-type Password",
                    textInputType: TextInputType.visiblePassword,
                    controller: authProvider.confirmPasswordController,
                    validator: (val) => authProvider.confirmPassword(val!),
                    obscureText: true,
                  ),

                  Gap(40),

                  CustomButton(
                    onTap: () async {
                      if (!_formKey.currentState!.validate()) {
                        return;
                      }
                      var response = await authProvider.signUpApi(
                        email: authProvider.emailController.text,
                        phoneNumber: formatPhoneNumber(
                          authProvider.phoneController.text,
                        ),
                        password: authProvider.passwordController.text,
                        accountType: "personal",
                      );
                      if (response) {
                        authProvider.animateToNextSignupPage(1);
                      }
                    },
                    label: "Continue",
                    // enabled: _formKey.currentState!.validate(),
                  ),

                  Gap(20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
