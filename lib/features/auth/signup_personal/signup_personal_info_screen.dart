import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/auth/signup_success_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:provider/provider.dart';

class SignupPersonalInfoScreen extends StatefulWidget {
  const SignupPersonalInfoScreen({super.key});

  @override
  State<SignupPersonalInfoScreen> createState() =>
      _SignupPersonalInfoScreenState();
}

class _SignupPersonalInfoScreenState extends State<SignupPersonalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return SizedBox(
      height: SizeConfig.heightOf(50),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("More About You", style: txStyle27Bold),
            Text(
              "Ensure the information you provide matches the details on your Government issued ID",
              style: txStyle13.copyWith(color: greyTextColor),
            ),
            Gap(20),
            CustomTextField(
              hintText: "Enter First Name",
              labelText: "First Name",
              textInputType: TextInputType.name,
              controller: firstNameController,
              validator: (val) => authProvider.validateName(val!),
            ),
            Gap(10),
            CustomTextField(
              hintText: "Enter Last Name",
              labelText: "Last Name",
              textInputType: TextInputType.name,
              controller: lastNameController,
              validator: (val) => authProvider.validateName(val!),
            ),
            Gap(10),
            CustomTextField(
              hintText: "Enter Username",
              labelText: "Username",
              textInputType: TextInputType.text,
              controller: usernameController,
              validator: (val) => authProvider.validateComment(val!),
            ),

            Gap(40),

            CustomButton(
              onTap: () async {
                bool res = await authProvider.submitBasicInfoApi(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  username: usernameController.text,
                );
                if (res) {
                  Get.to(
                    SignupSuccessScreen(name: "${firstNameController.text} ${lastNameController.text}"),
                    transition: Transition.rightToLeft,
                  );
                }
              },
              label: "Continue",
            ),

            // Gap(20),
          ],
        ),
      ),
    );
  }
}
