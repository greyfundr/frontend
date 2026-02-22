import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  var firstNameController = TextEditingController();
  var lastNameController = TextEditingController();
  UserProvider? userProvider;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_checkIfChanged);
    lastNameController.addListener(_checkIfChanged);
    Future.delayed(Duration.zero, () {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      initController();
    });
  }

  @override
  void dispose() {
    firstNameController.removeListener(_checkIfChanged);
    lastNameController.removeListener(_checkIfChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  void _checkIfChanged() {
    var userProfile = userProvider?.userProfileModel;
    if (userProfile != null) {
      bool changed =
          firstNameController.text != (userProfile.firstName ?? "") ||
          lastNameController.text != (userProfile.lastName ?? "");
      if (isChanged != changed) {
        setState(() {
          isChanged = changed;
        });
      }
    }
  }

  initController() {
    var userProfile = userProvider!.userProfileModel;
    firstNameController.text = userProfile?.firstName ?? "";
    lastNameController.text = userProfile?.lastName ?? "";
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: "Edit Profile"),
      body: Column(
        children: [
          CustomNetworkImage(imageUrl: "", radius: 100),
          Gap(20),
          CustomTextField(
            labelText: "First Name",
            hintText: "Enter your first name",
            controller: firstNameController,
          ),
          Gap(20),
          CustomTextField(
            labelText: "Last Name",
            hintText: "Enter your last name",
            controller: lastNameController,
          ),
          Gap(20),
          CustomButton(
            enabled: isChanged,
            onTap: () async {
              if (isChanged) {
                bool success = await userProvider.editProfile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                );
                if (success) {
                  await userProvider.fetchUserProfileApi();
                  initController();
                }
              }
            },
            label: "Save changes",
          ),
        ],
      ).paddingSymmetric(horizontal: SizeConfig.widthOf(5), vertical: 20),
    );
  }
}
