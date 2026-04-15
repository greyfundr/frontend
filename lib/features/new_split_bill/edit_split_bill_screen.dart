import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_network_image.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/components/custom_snackbars.dart';
import 'package:greyfundr/core/models/user_profile_model.dart';
import 'package:greyfundr/services/user_local_storage_service.dart';
import 'package:greyfundr/shared/moeny_formater.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/responsiveState/responsive_state.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/components/custom_date_picker_textField.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/dotted_border.dart';
import 'package:greyfundr/features/new_split_bill/split_bill_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:greyfundr/shared/utils.dart';

class EditSplitBillScreen extends StatefulWidget {
  final String billId;
  const EditSplitBillScreen({super.key, required this.billId});

  @override
  State<EditSplitBillScreen> createState() => _EditSplitBillScreenState();
}

class _EditSplitBillScreenState extends State<EditSplitBillScreen> {
  NewSplitBillProvider? provider;
  String billImageUrl = "";
  String receiptUrl = "";
  bool hasPaid = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      provider = Provider.of<NewSplitBillProvider>(context, listen: false);

      final details = provider?.splitBillDetails;
      if (details != null && details.data != null) {
        setState(() {
          hasPaid =
              details.data!.participants?.any((p) => (p.amountPaid ?? 0) > 0) ??
              false;
        });

        provider?.initEditSplitBill(details);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    Future.delayed(Duration.zero, () {
      provider?.disposeEditSplitBill();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context);
    return Scaffold(
      appBar: CustomAppBar(title: 'Edit Split Bill'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            const Text(
              "Bill Details",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Create a split bill with your friends",
              style: txStyle14.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Title Field
            CustomTextField(
              labelText: "Bill Title",
              hintText: "Enter bill title",
              controller: provider.editTitleController,
              isRequired: true,
              // maxLength: 30,
              onChanged: (_) => provider.checkIfEditSplitBillIsComplete(),
            ),
            const Gap(20),

            // Description Field
            CustomTextField(
              labelText: "Description",
              hintText: "What is this bill for?",
              controller: provider.editDescriptionController,
              maxLines: 3,
              onChanged: (_) => provider.checkIfEditSplitBillIsComplete(),
            ),
            const Gap(20),

            // Total Amount Field
            CustomTextField(
              labelText: "Total Amount",
              hintText: "0.00",
              controller: provider.editTotalAmountController,
              isRequired: true,
              readOnly: hasPaid,
              formatters: MoneyInputFormatter(),
              textInputType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => provider.checkIfEditSplitBillIsComplete(),
            ),
            const Gap(20),

            // Bill Image Picker
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        "Bill Photo",
                        style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(10),
                      _ImagePickerCard(
                        selectedFile: provider.editBillImageFile,
                        existingImageUrl: provider.editBillImageUrl,
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            provider.editBillImageFile = File(image.path);
                            // clear existing image url since a new file is picked
                            provider.editBillImageUrl = null;
                            provider.checkIfEditSplitBillIsComplete();
                          }
                        },
                        label: "Add Bill Photo",
                        icon: Icons.receipt_long_outlined,
                      ),
                    ],
                  ),
                ),
                Gap(20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Receipt (Optional)",
                        style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Gap(10),
                      _ImagePickerCard(
                        selectedFile: provider.editReceiptFile,
                        existingImageUrl: provider.editReceiptUrl,
                        onTap: () async {
                          final ImagePicker picker = ImagePicker();
                          final XFile? image = await picker.pickImage(
                            source: ImageSource.gallery,
                          );
                          if (image != null) {
                            provider.editReceiptFile = File(image.path);
                            provider.editReceiptUrl = null;
                            provider.checkIfEditSplitBillIsComplete();
                          }
                        },
                        label: "Add Receipt",
                        icon: Icons.image_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Gap(20),

            const Gap(20),

            // Due Date Picker
            CustomDatePickerTextFiled(
              labelText: "Due Date",
              hintText: "When should this be settled?",
              selectedDate: provider.editDueDate?.toIso8601String() ?? "",
              initialDate: DateTime.now(),
              minimumDate: DateTime.now().subtract(const Duration(seconds: 10)),
              maximumDate: DateTime.now().add(const Duration(days: 365)),
              isRequired: true,
              onDateChanged: (date) {
                provider.editDueDate = date;
                provider.checkIfEditSplitBillIsComplete();
              },
            ),
            const Gap(20),

            // Participants Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Participants",
                  style: txStyle13.copyWith(fontWeight: FontWeight.w600),
                ),
                if (!hasPaid)
                  CustomOnTap(
                    onTap: () {
                      if (provider.editTotalAmountController.text.isEmpty) {
                        showErrorToast(
                          "Please enter total amount before managing participant amounts",
                        );
                        return;
                      }
                      if (provider.getEditSelectedParticipants().isEmpty) {
                        showErrorToast("Please add at least one participant");
                        return;
                      }
                      showCustomBottomSheet(
                        const EditManageBillAmountSheet(),
                        context,
                        // backgroundColor: Colors.transparent,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: appPrimaryColor.withOpacity(0.2),
                        border: Border.all(color: appPrimaryColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "Manage Amounts",
                        style: txStyle12.copyWith(
                          fontWeight: FontWeight.w600,
                          color: appPrimaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Gap(10),
            GestureDetector(
              onTap: hasPaid
                  ? () {
                      showErrorToast(
                        "You can no longer add participants as payment has started.",
                      );
                    }
                  : () {
                      showCustomBottomSheet(
                        const EditAddParticipantSheet(),
                        context,
                        backgroundColor: Colors.transparent,
                      );
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: appPrimaryColor),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/svgs/add_participant.svg",
                      height: 48,
                      width: 48,
                    ),
                    if (provider.getEditSelectedParticipants().isNotEmpty) ...[
                      const Gap(16),
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: List.generate(
                              provider.getEditSelectedParticipants().length,
                              (index) {
                                final participant = provider
                                    .getEditSelectedParticipants()[index];
                                final hasImage =
                                    participant.imageUrl != null &&
                                    participant.imageUrl!.isNotEmpty;
                                return Positioned(
                                  left: index * (48 * 0.7),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                      image: hasImage
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                participant.imageUrl!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                );
                              },
                            ).reversed.toList(),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Gap(20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Allow Partial Payments",
                              style: txStyle14.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Gap(4),
                            Text(
                              "Set minimum payment amount",
                              style: txStyle13.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: provider.editAllowPartialPayments,
                        activeThumbColor: appPrimaryColor,
                        onChanged: (val) {
                          provider.toggleEditAllowPartialPayments(val);
                        },
                      ),
                    ],
                  ),
                  if (provider.editAllowPartialPayments) ...[
                    const Gap(16),
                    const Divider(),
                    const Gap(16),
                    CustomTextField(
                      labelText: "Minimum Payment Amount",
                      hintText: "0.00",
                      controller: provider.editMinPaymentAmountForPartial,
                      isRequired: true,
                      formatters: MoneyInputFormatter(),
                      textInputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (value) {
                        // if (value != null && value.isNotEmpty) {
                        //   provider.editMinPaymentAmountForPartial =
                        //       double.tryParse(value) ?? 0.0;
                        // }
                        provider.notifyListeners();
                      },
                    ),
                  ],
                ],
              ),
            ),
            const Gap(32),

            // Create Button
            CustomButton(
              enabled: provider.isEditSplitBillFormComplete,
              onTap: () async {
                provider.checkIfEditAmountsAreEqual();

                if (billImageUrl.isEmpty &&
                    provider.editBillImageFile != null) {
                  billImageUrl =
                      await provider.uploadImage(provider.editBillImageFile!) ??
                      "";
                  setState(() {});
                }

                if (receiptUrl.isEmpty && provider.editReceiptFile != null) {
                  receiptUrl =
                      await provider.uploadImage(provider.editReceiptFile!) ??
                      "";
                  setState(() {});
                }

                if (billImageUrl.isNotEmpty) {
                  provider.editBillImageUrl = billImageUrl;
                }
                if (receiptUrl.isNotEmpty) {
                  provider.editReceiptUrl = receiptUrl;
                }

                bool success = await provider.updateSplitBill(
                  splitBillId: widget.billId,
                );

                if (success) {
                  showSuccessToast("Split Bill updated successfully");
                  // pop to detail screen
                  Navigator.pop(context);
                  // refresh details
                  provider.getSplitBillDetails(splitBillId: widget.billId);
                } else {
                  showErrorToast("Failed to update split bill");
                }
              },
              label: "Save Changes",
              width: double.infinity,
            ),
            const Gap(20),
          ],
        ),
      ),
    );
  }
}

class _ImagePickerCard extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;
  final File? selectedFile;
  final String? existingImageUrl;

  const _ImagePickerCard({
    required this.onTap,
    required this.label,
    required this.icon,
    this.selectedFile,
    this.existingImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: appPrimaryColor,
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        radius: const Radius.circular(12),
        borderPadding: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(20),
        child: selectedFile != null
            ? Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: FileImage(selectedFile!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : existingImageUrl != null
            ? Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(existingImageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                alignment: Alignment.center,

                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 40, color: appPrimaryColor),
                    const Gap(8),
                    Text(
                      label,
                      style: txStyle14.copyWith(
                        color: appPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      "Tap to upload",
                      style: txStyle13.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class EditAddParticipantSheet extends StatefulWidget {
  const EditAddParticipantSheet({super.key});

  @override
  State<EditAddParticipantSheet> createState() =>
      _EditAddParticipantSheetState();
}

class _EditAddParticipantSheetState extends State<EditAddParticipantSheet> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final provider = Provider.of<NewSplitBillProvider>(
        context,
        listen: false,
      );
      provider.searchParticipantController.clear();
      provider.clearSearchResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    final provider = Provider.of<NewSplitBillProvider>(context);
    UserProfileModel? user = UserLocalStorageService().getUserData();
    return SizedBox(
      height: SizeConfig.heightOf(85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bottom_sheet_cureve_right.png"),
          Expanded(
            child: Container(
              color: const Color(0xffF1F1F7),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.widthOf(5),
                  vertical: 20,
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Add Participants', style: txStyle16),
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: borderColor,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.black,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Gap(15),

                      // Quick Action Buttons - Add me to bill & Select from contacts
                      if (user?.phoneNumber?.isNotEmpty ?? false)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                // Check if current user is already added
                                Builder(
                                  builder: (context) {
                                    final isCurrentUserAdded = provider
                                        .getEditSelectedParticipants()
                                        .any(
                                          (p) =>
                                              p.phoneNumber ==
                                              user!.phoneNumber!,
                                        );

                                    return Expanded(
                                      child: _ActionButton(
                                        onTap: isCurrentUserAdded
                                            ? null
                                            : () async {
                                                await provider
                                                    .addCurrentUserToBill(
                                                      phoneNumber:
                                                          user!.phoneNumber!,
                                                    );
                                              },
                                        label: "Add me",
                                        isDisabled: isCurrentUserAdded,
                                      ),
                                    );
                                  },
                                ),
                                const Gap(10),
                                Expanded(
                                  child: _ActionButton(
                                    onTap: () async {
                                      await provider.handleSelectContact(
                                        context,
                                      );
                                    },
                                    label: "From contacts",
                                    isDisabled: false,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(15),
                            const Divider(),
                            const Gap(15),
                          ],
                        ),

                      // Selected Participants Preview
                      if (provider
                          .getEditSelectedParticipants()
                          .isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Added (${provider.getEditSelectedParticipants().length})",
                              style: txStyle13.copyWith(
                                fontWeight: FontWeight.w600,
                                color: appPrimaryColor,
                              ),
                            ),
                            const Gap(8),
                            SizedBox(
                              height: 50,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: provider
                                    .getEditSelectedParticipants()
                                    .length,
                                separatorBuilder: (_, __) => const Gap(8),
                                itemBuilder: (context, index) {
                                  final participant = provider
                                      .getEditSelectedParticipants()[index];
                                  final hasImage =
                                      participant.imageUrl != null &&
                                      participant.imageUrl!.isNotEmpty;

                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: appPrimaryColor,
                                        width: 1.5,
                                      ),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (hasImage)
                                          CustomNetworkImage(
                                            radius: 32,
                                            imageUrl: participant.imageUrl!,
                                          )
                                        else
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: appPrimaryColor
                                                  .withOpacity(0.15),
                                            ),
                                            child: Icon(
                                              Icons.person,
                                              color: appPrimaryColor,
                                              size: 16,
                                            ),
                                          ),
                                        const Gap(8),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              participant.name,
                                              style: txStyle12.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (participant
                                                .phoneNumber
                                                .isNotEmpty)
                                              Text(
                                                participant.phoneNumber,
                                                style: txStyle13.copyWith(
                                                  color: Colors.grey[600],
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                          ],
                                        ),
                                        const Gap(8),
                                        GestureDetector(
                                          onTap: () {
                                            provider.removeEditParticipant(
                                              participant.id,
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withOpacity(
                                                0.1,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.close,
                                              size: 14,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const Gap(15),
                        const Divider(),
                        const Gap(15),
                      ],

                      // Search Field
                      CustomSearchField(
                        hintText: "Search by phone number, email or username",
                        onChange: (val) {
                          provider.temporaryGuestName = "";
                          provider.temporaryGuestPhone = "";
                          setState(() {});
                        },
                        suffixIcon: CustomOnTap(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            provider.searchForUser(
                              identifier:
                                  provider.searchParticipantController.text,
                            );
                          },
                          child: Icon(Icons.search),
                        ),
                        textEditingController:
                            provider.searchParticipantController,
                        // textInputType: TextInputType.phone,
                        // onChange: (value) {
                        //   provider.searchForUser(identifier: value);
                        // },
                        // onSubmit: (value) {
                        //   provider.searchForUser(identifier: value);
                        // },
                      ),
                      const Gap(15),
                      const Divider(),
                      const Gap(15),

                      // Search Results
                      Expanded(
                        child: ResponsiveStateFunction(
                          state: provider.searchUserState,
                          onIdle: () => Center(
                            child: Text(
                              "Search for participants",
                              style: txStyle14.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          onBusy: () => UiBusyWidget(),
                          onSuccess: () {
                            return provider.searchResults.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.person_off_outlined,
                                          size: 40,
                                          color: Colors.grey[400],
                                        ),
                                        const Gap(16),
                                        Text(
                                          "User not found on GreyFundr",
                                          style: txStyle14.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const Gap(8),
                                        Text(
                                          "Add them as a guest\ninstead",
                                          textAlign: TextAlign.center,
                                          style: txStyle13.copyWith(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const Gap(16),
                                        CustomButton(
                                          onTap: () {
                                            showCustomBottomSheet(
                                              AddGuestParticipantSheet(
                                                guestName:
                                                    provider
                                                        .temporaryGuestName
                                                        .isEmpty
                                                    ? provider
                                                          .searchParticipantController
                                                          .text
                                                    : provider
                                                          .temporaryGuestName,
                                                guestPhoneNumber: provider
                                                    .temporaryGuestPhone,
                                              ),
                                              context,
                                              backgroundColor:
                                                  Colors.transparent,
                                            );
                                          },
                                          label: "Add Guest",
                                          width: 150,
                                          height: 40,
                                          icon: const Icon(
                                            Icons.person_add,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: provider.searchResults.length,
                                    separatorBuilder: (_, __) =>
                                        const Divider(),
                                    itemBuilder: (context, index) {
                                      final user =
                                          provider.searchResults[index];
                                      final isSelected = provider
                                          .getEditSelectedParticipants()
                                          .any((p) => p.id == user.id);

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            user.profile?.image != null &&
                                                    (user
                                                            .profile
                                                            ?.image
                                                            ?.isNotEmpty ??
                                                        false)
                                                ? CustomNetworkImage(
                                                    radius: 40,
                                                    imageUrl:
                                                        user.profile!.image!,
                                                  )
                                                : CustomNetworkImage(
                                                    radius: 40,
                                                    imageUrl: "",
                                                  ),
                                            const Gap(12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    user.username ??
                                                        user.firstName ??
                                                        "Unknown",
                                                    style: txStyle14.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  Builder(
                                                    builder: (context) {
                                                      // final totalAmount =
                                                      //     double.tryParse(
                                                      //       provider
                                                      //           .editTotalAmountController
                                                      //           .text,
                                                      //     ) ??
                                                      //     0.0;
                                                      // final numParticipants =
                                                      //     provider
                                                      //         .getEditSelectedParticipants()
                                                      //         .length;
                                                      // final splitAmount =
                                                      //     numParticipants > 0
                                                      //     ? totalAmount /
                                                      //           numParticipants
                                                      //     : totalAmount;
                                                      // final formattedAmount =
                                                      //     convertStringToCurrency(
                                                      //       splitAmount
                                                      //           .toStringAsFixed(
                                                      //             2,
                                                      //           ),
                                                      //     );
                                                      return Text(
                                                        user.phoneNumber ?? "",
                                                        style: txStyle13.copyWith(
                                                          color:
                                                              appPrimaryColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      );
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const Gap(12),
                                            SizedBox(
                                              width: 70,
                                              height: 36,
                                              child: CustomButton(
                                                onTap: isSelected
                                                    ? () => provider
                                                          .removeEditParticipant(
                                                            user.id ?? "",
                                                          )
                                                    : () {
                                                        provider.addEditParticipant(
                                                          CustomParticipantClass.fromUser(
                                                            user,
                                                          ),
                                                        );
                                                      },
                                                label: isSelected
                                                    ? "Remove"
                                                    : "Add",
                                                fontSize: 12,
                                                height: 36,
                                                backgroundColor: isSelected
                                                    ? Colors.grey[300]!
                                                    : appPrimaryColor,
                                                color: isSelected
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                          },
                          onNoDataAvailable: () => Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_off_outlined,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                                const Gap(16),
                                Text(
                                  "User not found on GreyFundr",
                                  style: txStyle14.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const Gap(8),
                                Text(
                                  "Add them as a guest\ninstead",
                                  textAlign: TextAlign.center,
                                  style: txStyle13.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const Gap(16),
                                CustomButton(
                                  onTap: () {
                                    showCustomBottomSheet(
                                      AddGuestParticipantSheet(
                                        guestName: provider.temporaryGuestName,
                                        guestPhoneNumber:
                                            provider.temporaryGuestPhone,
                                      ),
                                      context,
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                                  label: "Add Guest",
                                  width: 150,
                                  height: 40,
                                  icon: const Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          onError: () => Center(
                            child: Text(
                              "Error searching for participants",
                              style: txStyle14.copyWith(color: Colors.red),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class AddGuestParticipantSheet extends StatefulWidget {
  final String guestPhoneNumber;
  final String guestName;
  const AddGuestParticipantSheet({
    super.key,
    required this.guestPhoneNumber,
    required this.guestName,
  });

  @override
  State<AddGuestParticipantSheet> createState() =>
      _AddGuestParticipantSheetState();
}

class _AddGuestParticipantSheetState extends State<AddGuestParticipantSheet> {
  NewSplitBillProvider? provider;
  final _guestNameController = TextEditingController();
  final _guestPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      provider = Provider.of<NewSplitBillProvider>(context, listen: false);
      _guestPhoneController.text = widget.guestPhoneNumber;
      _guestNameController.text = widget.guestName;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _guestNameController.dispose();
    _guestPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset("assets/images/bottom_sheet_cureve_right.png"),
          Container(
            color: const Color(0xffF1F1F7),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.widthOf(5),
                vertical: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Add Guest Participant', style: txStyle16),
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            color: borderColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Gap(20),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                          size: 20,
                        ),
                        const Gap(12),
                        Expanded(
                          child: Text(
                            "An SMS will be sent to complete payment",
                            style: txStyle13.copyWith(color: Colors.blue[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(20),

                  // Guest Name Field
                  CustomTextField(
                    labelText: "Guest Name",
                    hintText: "Enter full name",
                    controller: _guestNameController,
                    isRequired: true,
                  ),
                  const Gap(16),

                  // Guest Phone Field
                  CustomTextField(
                    labelText: "Phone Number",
                    hintText: "Enter phone number",
                    controller: _guestPhoneController,
                    isRequired: true,
                    textInputType: TextInputType.phone,
                  ),
                  const Gap(24),

                  // Add Button
                  CustomButton(
                    onTap: () {
                      final name = _guestNameController.text.trim();
                      final phone = _guestPhoneController.text.trim();

                      if (name.isEmpty || phone.isEmpty) {
                        log(
                          "Guest name or phone number is empty::: $name ::: $phone",
                        );
                        showErrorToast(
                          "Please enter both name and phone number",
                        );
                        return;
                      }

                      provider.addEditParticipant(
                        CustomParticipantClass.guest(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: name,
                          phoneNumber: phone,
                        ),
                      );

                      Get.close(2);
                    },
                    label: "Add Guest",
                  ),
                  Gap(20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Action Button with light primary color background and green text
class _ActionButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;
  final bool isDisabled;

  const _ActionButton({
    required this.onTap,
    required this.label,
    required this.isDisabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isDisabled
                ? Colors.grey[200]
                : appPrimaryColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isDisabled
                  ? Colors.grey[300]!
                  : appPrimaryColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: txStyle13.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDisabled ? Colors.grey[400] : appPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditManageBillAmountSheet extends StatefulWidget {
  const EditManageBillAmountSheet({super.key});

  @override
  State<EditManageBillAmountSheet> createState() =>
      _EditManageBillAmountSheetState();
}

class _EditManageBillAmountSheetState extends State<EditManageBillAmountSheet> {
  bool isByAmount = true;
  NewSplitBillProvider? provider;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      provider = Provider.of<NewSplitBillProvider>(context, listen: false);
      if (provider?.getEditSelectedParticipants().isNotEmpty ?? false) {
        // Automatically check if it's already split evenly or not, or just ensure amount controllers have values
        setState(() {});
      }
    });
  }

  double _calculateTotalEntered() {
    if (provider == null) return 0.0;
    double totalEntered = 0;
    for (var participant in provider!.getEditSelectedParticipants()) {
      final amount =
          double.tryParse(
            participant.amountController?.text.replaceAll(',', '') ?? "0",
          ) ??
          0;
      totalEntered += amount;
    }
    return totalEntered;
  }

  bool _isEquallySplit() {
    if (provider == null || provider!.getEditSelectedParticipants().isEmpty) {
      return false;
    }
    final participants = provider!.getEditSelectedParticipants();
    final totalAmount =
        double.tryParse(
          provider!.editTotalAmountController.text.replaceAll(',', ''),
        ) ??
        0.0;
    if (totalAmount <= 0) return false;

    final expectedAmount = totalAmount / participants.length;
    for (var participant in participants) {
      final amount =
          double.tryParse(
            participant.amountController?.text.replaceAll(',', '') ?? "0",
          ) ??
          0;
      // Allow minor rounding differences
      if ((amount - expectedAmount).abs() > 0.05) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NewSplitBillProvider>(context);
    final participants = provider.getEditSelectedParticipants();

    // Return early if no participants
    if (participants.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Add participants first",
            style: txStyle14.copyWith(color: Colors.grey[600]),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SizedBox(
        height: SizeConfig.heightOf(85),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/images/bottom_sheet_cureve_right.png"),
            Expanded(
              child: Container(
                color: const Color(0xffF1F1F7),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.widthOf(5),
                    vertical: 20,
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Manage Amounts', style: txStyle16),
                            InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: borderColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.black,
                                  size: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Gap(20),

                        // Total Amount Display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: appPrimaryColor.withOpacity(0.08),
                            border: Border.all(
                              color: appPrimaryColor.withOpacity(0.2),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: txStyle13.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                convertStringToCurrency(
                                  provider.editTotalAmountController.text
                                      .replaceAll(",", ""),
                                ),
                                style: txStyle13.copyWith(
                                  color: appPrimaryColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),

                        // By Amount / By Percentage Tabs
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isByAmount = true;

                                      // When switching back to amount, update the amount controllers based on previously set values
                                      // Or normally, keep the exact amount. As the user edited percentage, it was syncing real-time
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isByAmount
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: isByAmount
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "By amount",
                                      style: txStyle13.copyWith(
                                        fontWeight: isByAmount
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: isByAmount
                                            ? Colors.black
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isByAmount = false;

                                      // Pre-fill percentages based on current amounts
                                      final totalAmount =
                                          double.tryParse(
                                            provider
                                                .editTotalAmountController
                                                .text
                                                .replaceAll(',', ''),
                                          ) ??
                                          0;
                                      if (totalAmount > 0) {
                                        for (var participant in participants) {
                                          final currentAmount =
                                              double.tryParse(
                                                participant
                                                        .amountController
                                                        ?.text
                                                        .replaceAll(',', '') ??
                                                    "0",
                                              ) ??
                                              0;
                                          final percentage =
                                              (currentAmount / totalAmount) *
                                              100;
                                          participant.percentageController ??=
                                              TextEditingController();
                                          participant
                                              .percentageController!
                                              .text = percentage
                                              .toStringAsFixed(2)
                                              .replaceAll(
                                                RegExp(r'\.00$'),
                                                '',
                                              ); // Clean up .00
                                        }
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !isByAmount
                                          ? Colors.white
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: !isByAmount
                                          ? [
                                              BoxShadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.05,
                                                ),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      "By percentage",
                                      style: txStyle13.copyWith(
                                        fontWeight: !isByAmount
                                            ? FontWeight.w600
                                            : FontWeight.w500,
                                        color: !isByAmount
                                            ? Colors.black
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),

                        // Split Equally action
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: _isEquallySplit()
                                ? null
                                : () {
                                    provider.applyEditEqualSplit();
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _isEquallySplit()
                                    ? Colors.grey[100]
                                    : appPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isEquallySplit()
                                      ? Colors.grey[300]!
                                      : appPrimaryColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _isEquallySplit()
                                        ? Icons.check_circle
                                        : Icons.pie_chart_outline_rounded,
                                    size: 16,
                                    color: _isEquallySplit()
                                        ? Colors.grey[500]
                                        : appPrimaryColor,
                                  ),
                                  const Gap(6),
                                  Text(
                                    "Split Equally",
                                    style: txStyle12.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: _isEquallySplit()
                                          ? Colors.grey[500]
                                          : appPrimaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const Gap(12),
                        const Divider(),
                        const Gap(16),

                        // Participants List with Amount Fields
                        Expanded(
                          child: ListView.separated(
                            itemCount: participants.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final participant = participants[index];
                              // Initialize controllers if they don't exist
                              participant.amountController ??=
                                  TextEditingController();
                              participant.percentageController ??=
                                  TextEditingController();

                              final totalAmount =
                                  double.tryParse(
                                    provider.editTotalAmountController.text
                                        .replaceAll(',', ''),
                                  ) ??
                                  0.0;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        participant.name,
                                        style: txStyle13.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    const Gap(8),
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: isByAmount
                                            ? participant.amountController
                                            : participant.percentageController,
                                        keyboardType:
                                            const TextInputType.numberWithOptions(
                                              decimal: true,
                                            ),
                                        inputFormatters: isByAmount
                                            ? [MoneyInputFormatter()]
                                            : [],
                                        decoration: InputDecoration(
                                          hintText: "0.00",
                                          prefixText: isByAmount ? "₦ " : "% ",
                                          prefixStyle: txStyle14.copyWith(
                                            color: appPrimaryColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: appPrimaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: appPrimaryColor
                                                  .withOpacity(0.3),
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            borderSide: BorderSide(
                                              color: appPrimaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: 12,
                                              ),
                                        ),
                                        onChanged: (value) {
                                          if (isByAmount) {
                                            // Handle input by amount
                                            final currentAmount =
                                                double.tryParse(
                                                  value.replaceAll(',', ''),
                                                ) ??
                                                0;
                                            if (totalAmount > 0) {
                                              final pct =
                                                  (currentAmount /
                                                      totalAmount) *
                                                  100;
                                              participant
                                                  .percentageController
                                                  ?.text = pct
                                                  .toStringAsFixed(2)
                                                  .replaceAll(
                                                    RegExp(r'\.00$'),
                                                    '',
                                                  );
                                            }
                                          } else {
                                            // Handle input by percentage
                                            final percent =
                                                double.tryParse(value) ?? 0;
                                            final calculatedAmount =
                                                (percent / 100) * totalAmount;
                                            participant.amountController?.text =
                                                calculatedAmount
                                                    .toStringAsFixed(2);
                                          }
                                          // trigger provider repaint or local setstate
                                          provider.notifyListeners();
                                        },
                                        style: txStyle14,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Gap(16),

                        // Verify Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              // Validate amounts
                              final totalAmount =
                                  double.tryParse(
                                    provider.editTotalAmountController.text
                                        .replaceAll(',', ''),
                                  ) ??
                                  0;

                              if ((_calculateTotalEntered() - totalAmount)
                                      .abs() >
                                  0.01) {
                                showErrorToast(
                                  "Total amount must equal ${convertStringToCurrency(totalAmount.toStringAsFixed(2))}",
                                );
                                return;
                              }

                              Navigator.pop(context);
                            },
                            child: CustomButton(
                              enabled:
                                  (provider
                                          .editTotalAmountController
                                          .text
                                          .isNotEmpty &&
                                      _calculateTotalEntered() > 0) &&
                                  (_calculateTotalEntered() -
                                              (double.tryParse(
                                                    provider
                                                        .editTotalAmountController
                                                        .text
                                                        .replaceAll(',', ''),
                                                  ) ??
                                                  0))
                                          .abs() <=
                                      0.01,
                              onTap: () {
                                Get.close(1);
                              },
                              label: "Confirm",
                            ),
                          ),
                        ),
                        const Gap(16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
