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

class SignupGroupScreen extends StatefulWidget {
  const SignupGroupScreen({super.key});

  @override
  State<SignupGroupScreen> createState() => _SignupGroupScreenState();
}

class _SignupGroupScreenState extends State<SignupGroupScreen> {
  AuthProvider? authProvider;
  final _formKey = GlobalKey<FormState>();

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
    Future.delayed(Duration.zero, () {
      authProvider?.disposeSignupController();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Form(
      key: _formKey,
      child: SizedBox(
        height: SizeConfig.heightOf(60),
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
                labelText: "Company Email",
                textInputType: TextInputType.emailAddress,
                controller: authProvider.emailController,
                validator: (val) => authProvider.validateEmail(val!),
              ),
              Gap(15),
              CustomTextField(
                hintText: "Enter Phone Number",
                labelText: "Company Phone Number",
                textInputType: TextInputType.phone,
                controller: authProvider.phoneController,
                validator: (val) => authProvider.validatePhoneNumber(val!),
              ),
              Gap(15),
              CustomTextField(
                hintText: "********",
                labelText: "Password",
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
                controller: authProvider.passwordController,
                validator: (val) => authProvider.validatePassword(val!),
              ),
              Gap(15),
              CustomTextField(
                hintText: "********",
                labelText: "Re-type Password",
                textInputType: TextInputType.visiblePassword,
                obscureText: true,
                controller: authProvider.confirmPasswordController,
                validator: (val) => authProvider.validatePassword(val!),
              ),

              Gap(40),

              CustomButton(
                enabled:
                    authProvider.emailController.text.isNotEmpty &&
                    authProvider.phoneController.text.isNotEmpty &&
                    authProvider.passwordController.text.isNotEmpty &&
                    authProvider.confirmPasswordController.text.isNotEmpty,
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  var response = await authProvider.signUpApi(
                    email: authProvider.emailController.text,
                    phoneNumber: authProvider.phoneController.text,
                    password: authProvider.passwordController.text,
                    accountType: "group",
                  );
                  if (response) {
                    authProvider.animateToNextSignupPage(1);
                  }
                },
                label: "Continue",
              ),

              Gap(20),
            ],
          ),
        ),
      ),
    );
  }
}
