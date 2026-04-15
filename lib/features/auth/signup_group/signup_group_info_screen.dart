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

class SignupGroupInfoScreen extends StatefulWidget {
  const SignupGroupInfoScreen({super.key});

  @override
  State<SignupGroupInfoScreen> createState() => _SignupGroupInfoScreenState();
}

class _SignupGroupInfoScreenState extends State<SignupGroupInfoScreen> {
  final _companyNameController = TextEditingController();
  final _cacNumberController = TextEditingController();
  final _tinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Form(
      key: _formKey,
      child: SizedBox(
        height: SizeConfig.heightOf(50),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: true,
          removeBottom: true,
          child: ListView(
            // crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Group Information", style: txStyle27Bold),
              Text(
                "Tell us more about your group",
                style: txStyle13.copyWith(color: greyTextColor),
              ),
              Gap(20),
              CustomTextField(
                hintText: "Enter Company Name",
                labelText: "Company Name",
                textInputType: TextInputType.name,
                controller: _companyNameController,
                validator: (val) => authProvider.validateComment(val!),
              ),
              Gap(15),

              CustomTextField(
                hintText: "Enter CAC Number",
                labelText: "CAC Number",
                textInputType: TextInputType.text,
                controller: _cacNumberController,
                validator: (val) => authProvider.validateComment(val!),
              ),

              Gap(15),
              CustomTextField(
                hintText: "Enter  TIN",
                labelText: "TIN",
                textInputType: TextInputType.text,
                controller: _tinController,
                validator: (val) => authProvider.validateComment(val!),
              ),

              Gap(40),

              CustomButton(
                onTap: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  // authProvider.animateToNextSignupPage(1);
                  bool res = await authProvider.completeKycApi(
                    companyName: _companyNameController.text,
                    cacNumber: _cacNumberController.text,
                    tin: _tinController.text,
                  );
                  if (res) {
                    Get.to(
                      SignupSuccessScreen(name: _companyNameController.text),
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
      ),
    );
  }
}
