import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:greyfundr/features/settings/interest_selection_screen.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:image_picker/image_picker.dart';
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
  var usernameController = TextEditingController();
  var bioController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  List<String> selectedInterests = [];
  String? _localAvatarPath;

  UserProvider? userProvider;
  bool isChanged = false;

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(_checkIfChanged);
    lastNameController.addListener(_checkIfChanged);
    usernameController.addListener(_checkIfChanged);
    bioController.addListener(_checkIfChanged);
    Future.delayed(Duration.zero, () {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      initController();
    });
  }

  @override
  void dispose() {
    firstNameController.removeListener(_checkIfChanged);
    lastNameController.removeListener(_checkIfChanged);
    usernameController.removeListener(_checkIfChanged);
    bioController.removeListener(_checkIfChanged);
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _checkIfChanged() {
    var userProfile = userProvider?.userProfileModel;
    if (userProfile != null) {
      bool changed =
          firstNameController.text != (userProfile.firstName ?? "") ||
          lastNameController.text != (userProfile.lastName ?? "") ||
          usernameController.text != (userProfile.username ?? "") ||
          bioController.text != (userProfile.profile?.bio ?? "") ||
          !_areListsEqual(
            selectedInterests,
            userProfile.profile?.interests ?? [],
          );
      if (isChanged != changed) {
        setState(() {
          isChanged = changed;
        });
      }
    }
  }

  bool _areListsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (!list2.contains(list1[i])) return false;
    }
    return true;
  }

  initController() {
    var userProfile = userProvider!.userProfileModel;
    firstNameController.text = userProfile?.firstName ?? "";
    lastNameController.text = userProfile?.lastName ?? "";
    usernameController.text = userProfile?.username ?? "";
    bioController.text = userProfile?.profile?.bio ?? "";
    selectedInterests = List.from(userProfile?.profile?.interests ?? []);
    _localAvatarPath = null;
    setState(() {});
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(
      source: source,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    setState(() {
      _localAvatarPath = pickedFile.path;
    });

    final success =
        await userProvider?.updateProfileAvatar(filePath: pickedFile.path) ??
        false;

    if (success && mounted) {
      initController();
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return UploadImageOption(
          fromGallery: () => _pickAndUploadAvatar(ImageSource.gallery),
          fromCamera: () => _pickAndUploadAvatar(ImageSource.camera),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final avatarUrl =
        userProvider.userProfileModel?.profile?.image?.toString() ?? "";

    return Scaffold(
      appBar: CustomAppBar(title: "Edit Profile"),
      body: ListView(
        children: [
          Center(
            child: Stack(
              children: [
                ClipOval(
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: _localAvatarPath != null
                        ? Image.file(File(_localAvatarPath!), fit: BoxFit.cover)
                        : CustomNetworkImage(imageUrl: avatarUrl, radius: 100),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: _showImageSourceBottomSheet,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(8),
          Center(
            child: TextButton(
              onPressed: _showImageSourceBottomSheet,
              child: const Text("Change profile image"),
            ),
          ),
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
          CustomTextField(
            labelText: "Username",
            hintText: "Enter your username",
            controller: usernameController,
          ),
          Gap(20),
          CustomTextField(
            labelText: "Bio",
            hintText: "Tell us a bit about yourself",
            controller: bioController,
          ),
          Gap(20),
          const Text(
            "Interests",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const Gap(10),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              ...selectedInterests.map((interest) {
                return Chip(
                  label: Text(interest),
                  onDeleted: () {
                    setState(() {
                      selectedInterests.remove(interest);
                    });
                    _checkIfChanged();
                  },
                  backgroundColor: Colors.grey.shade100,
                  deleteIconColor: Colors.black54,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
              ActionChip(
                label: const Text("Add+"),
                onPressed: () async {
                  final result = await Get.to(
                    () => InterestSelectionScreen(
                      initialInterests: selectedInterests,
                    ),
                  );
                  if (result != null && result is List<String>) {
                    setState(() {
                      selectedInterests = result;
                    });
                    _checkIfChanged();
                  }
                },
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ],
          ),
          Gap(20),
          CustomButton(
            enabled: isChanged,
            onTap: () async {
              if (isChanged) {
                bool success = await userProvider.editProfile(
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  username: usernameController.text,
                  bio: bioController.text,
                  interests: selectedInterests,
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
