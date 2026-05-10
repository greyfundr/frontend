import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_date_picker_textField.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/auth/auth_provider.dart';
import 'package:greyfundr/features/auth/signup_success_screen.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:greyfundr/shared/responsiveState/view_state.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
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
  String dobController = "";
  String dobController1 = "";

  Timer? _usernameDebounce;

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String? val, UserProvider provider) {
    _usernameDebounce?.cancel();
    final username = (val ?? '').trim();
    if (username.isEmpty) {
      provider.resetUsernameState();
      return;
    }
    _usernameDebounce = Timer(const Duration(milliseconds: 500), () {
      provider.checkIfUsernameExist(username: username);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final typedUsername = usernameController.text.trim();
    final showTakenError =
        userProvider.usernameState == ViewState.Success &&
        userProvider.usernameExist &&
        typedUsername.isNotEmpty;

    return PopScope(
      canPop: false,
      child: SizedBox(
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 18,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Username",
                        style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Visibility(
                        visible: showTakenError,
                        maintainSize: true,
                        maintainAnimation: true,
                        maintainState: true,
                        child: Text(
                          "Username already taken",
                          style: txStyle12.copyWith(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
                CustomTextField(
                  hintText: "Enter Username",
                  textInputType: TextInputType.text,
                  controller: usernameController,
                  validator: (val) => authProvider.validateComment(val!),
                  onChanged: (val) {
                    _onUsernameChanged(val, userProvider);
                    setState(() {});
                  },
                  suffixIcon: SizedBox(
                    height: 20,
                    child: ResponsiveState(
                      state: userProvider.usernameState,
                      busyWidget: UiBusyWidget(height: 16),
                      successWidget: Icon(
                        showTakenError ? Icons.close : Icons.check,
                        color: showTakenError ? Colors.transparent : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gap(10),
            CustomDatePickerTextFiled(
              labelText: "Date of Birth",
              hintText: "01-01-1990",
              onDateChanged: (val) {
                dobController1 = val.toIso8601String();
                authProvider.notifyListeners();
              },
              selectedDate: dobController1,
            ),

            Gap(40),

            CustomButton(
              onTap: () async {
                if (await userProvider.checkIfUsernameExist(
                  username: usernameController.text.trim(),
                )) {
                  showErrorToast("Username already taken");
                  return;
                }
                bool res = await authProvider.submitBasicInfoApi(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  username: usernameController.text,
                  dob: dobController1,
                );
                if (res) {
                  Get.to(
                    SignupSuccessScreen(
                      name:
                          "${firstNameController.text} ${lastNameController.text}",
                    ),
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
