import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_date_picker_textField.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/settings/verification_screen.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:provider/provider.dart';

class LogoutAppSheet extends StatelessWidget {
  final String userName;
  const LogoutAppSheet({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bottom_sheet_cureve_right.png"),
        Container(
          color: Color(0xffF1F1F7),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(5),
              vertical: 20,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("About to logout?", style: txStyle16Bold),
                  Gap(20),
                  Text(
                    "Dear $userName, would you like to logout?",
                    style: txStyle14,
                  ),
                  Gap(30),
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            onTap: () {
                              Get.close(1);
                            },
                            label: "Stay",
                            backgroundColor: Colors.transparent,
                            color: appPrimaryColor,
                            borderColor: appPrimaryColor,
                          ),
                        ),
                        Gap(10),
                        Expanded(
                          child: CustomButton(
                            onTap: () {
                              logout();
                              UserLocalStorageService().clearUserData();
                            },
                            label: "Logout",
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SubmitDateOfBirthSheet extends StatefulWidget {
  final String userName;
  const SubmitDateOfBirthSheet({super.key, required this.userName});

  @override
  State<SubmitDateOfBirthSheet> createState() => _SubmitDateOfBirthSheetState();
}

class _SubmitDateOfBirthSheetState extends State<SubmitDateOfBirthSheet> {
  DateTime? selectedDate;
  @override
  Widget build(BuildContext context) {
    final userProv = Provider.of<UserProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset("assets/images/bottom_sheet_cureve_right.png"),
        Container(
          color: Color(0xffF1F1F7),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(5),
              vertical: 20,
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("One more thing", style: txStyle16Bold),
                  Gap(20),
                  Text(
                    "${widget.userName}, your date of birth is required to complete your profile setup. Please submit it to continue to the next step.",
                    style: txStyle14,
                  ),
                  Gap(30),
                  CustomDatePickerTextFiled(
                    labelText: "Date",
                    hintText: "Date of birth",
                    selectedDate: selectedDate?.toIso8601String() ?? "",
                    initialDate: DateTime.now().subtract(
                      const Duration(days: 365 * 6),
                    ),
                    minimumDate: DateTime.now().subtract(
                      const Duration(days: 365 * 100),
                    ),
                    maximumDate: DateTime.now().subtract(
                      const Duration(days: 365 * 6),
                    ),
                    isRequired: true,
                    onDateChanged: (date) {
                      selectedDate = date; 
                      userProv.notifyListeners();
                    },
                  ),
                  Gap(20),
                  CustomButton(
                    height: 40,
                    onTap: () async {
                      bool res = await userProv.editProfile(
                        dateOfBirth: selectedDate?.toIso8601String(),
                      );
                      userProv.fetchUserProfileApi();
                      Get.off(
                        VerificationScreen(),
                        transition: Transition.rightToLeft,
                      );
                    },
                    label: "Submit",
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
