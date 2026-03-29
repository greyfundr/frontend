import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/custom_media_picker.dart';
import 'package:greyfundr/components/custom_date_picker_textField.dart';
import 'package:greyfundr/components/custom_time_picker_textField.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/shared/text_style.dart';

class Step1NamesAndCo extends StatelessWidget {
  const Step1NamesAndCo({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    // Filter categories that have names
    final categories = provider.eventCategoriesList
        .map((e) => e.name)
        .whereType<String>()
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Basic Info",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "Let's start with the basics",
            style: txStyle14.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          CustomTextField(
            labelText: "Event Name",
            hintText: "Enter event name",
            controller: provider.nameCtrl,
            isRequired: true,
            maxLength: 20,
            onChanged: (_) => provider.notifyListeners(),
          ),
          const Gap(20),

          CustomTextField(
            labelText: "Event Hashtag (Optional)",
            hintText: "#greyfundrevent",
            controller: provider.hashtagCtrl,
          ),
          const Gap(20),

          CustomTextField(
            hintText: "Short Description",
            labelText: "Description",
            controller: provider.shortDescCtrl,
          ),
          const Gap(20),

          GestureDetector(
            onTap: () {
              // Open BottomSheet with categories
              showCustomBottomSheet(
                _CategorySelectionSheet(
                  title: "Select Category",
                  categories: categories.isEmpty
                      ? [
                          "Concert",
                          "Conference",
                          "Party",
                          "Wedding",
                          "Other",
                        ] // Fallback
                      : categories,
                  onSelected: (cat) {
                    provider.setCategory(cat);
                    Navigator.pop(context);
                  },
                ),
                context,
                backgroundColor: Colors.transparent,
              );
            },
            child: AbsorbPointer(
              child: CustomTextField(
                labelText: "Category",
                hintText: "Select category",
                controller: provider.categoryCtrl,
                isRequired: true,
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const Gap(20),

          GestureDetector(
            onTap: () {
              // Open BottomSheet with visibility status
              showCustomBottomSheet(
                _CategorySelectionSheet(
                  title: "Select Event Type",
                  categories: const [
                    "Public (Anyone can RSVP)",
                    "Private (Invite Only)",
                  ],
                  onSelected: (status) {
                    provider.visibilityStatusCtrl.text = status;
                    provider.notifyListeners();
                    Navigator.pop(context);
                  },
                ),
                context,
                backgroundColor: Colors.transparent,
              );
            },
            child: AbsorbPointer(
              child: CustomTextField(
                labelText: "Event Type",
                hintText: "Select event type",
                controller: provider.visibilityStatusCtrl,
                isRequired: true,
                suffixIcon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          const Gap(20),

          Text(
            "Cover Image",
            style: txStyle13.copyWith(fontWeight: FontWeight.w600),
          ),
          Gap(5),
          CustomMediaPicker(
            images: provider.coverImages,
            networkImages: provider.existingCoverImageUrls,
            onAddMedia: () async {
              final picked = await ImagePicker().pickMultiImage();
              if (picked.isNotEmpty) provider.addCoverImages(picked);
            },
            onRemoveMedia: (index) => provider.removeCoverImage(index),
            onRemoveNetworkMedia: (index) =>
                provider.removeExistingCoverImageUrl(index),
          ),
          const Gap(20),

          Row(
            children: [
              Expanded(
                child: CustomDatePickerTextFiled(
                  labelText: "Date",
                  hintText: "Date of event",
                  selectedDate: provider.selectedDate?.toIso8601String() ?? "",
                  initialDate: DateTime.now(),
                  minimumDate: DateTime.now().subtract(const Duration(days: 1)),
                  maximumDate: DateTime.now().add(
                    const Duration(days: 365 * 5),
                  ),
                  isRequired: true,
                  onDateChanged: (date) {
                    provider.selectedDate = date;
                    provider.notifyListeners();
                  },
                ),
              ),
              const Gap(16),
              Expanded(
                child: CustomTimePickerTextFiled(
                  labelText: "Time",
                  selectedTime: provider.selectedTime?.toIso8601String() ?? "",
                  initialTime: DateTime.now(),
                  isRequired: true,
                  onTimeChanged: (time) {
                    provider.selectedTime = time;
                    provider.notifyListeners();
                  },
                ),
              ),
            ],
          ),
          const Gap(20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Span across multiple days?", style: txStyle15),
              Switch(
                value: provider.spanMultipleDays,
                activeThumbColor: appPrimaryColor,
                onChanged: (val) => provider.toggleSpanMultipleDays(val),
              ),
            ],
          ),
          if (provider.spanMultipleDays) ...[
            const Gap(10),
            CustomDatePickerTextFiled(
              labelText: "End Date",
              selectedDate: provider.endDate?.toIso8601String() ?? "",
              initialDate: provider.selectedDate ?? DateTime.now(),
              minimumDate: provider.selectedDate ?? DateTime.now(),
              maximumDate: DateTime.now().add(const Duration(days: 365)),
              isRequired: true,
              onDateChanged: (date) {
                provider.endDate = date;
                provider.notifyListeners();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _CategorySelectionSheet extends StatelessWidget {
  final String title;
  final List<String> categories;
  final Function(String) onSelected;

  const _CategorySelectionSheet({
    this.title = 'Select Category',
    required this.categories,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SizeConfig.heightOf(50),
      child: Column(
        children: [
          Image.asset("assets/images/bottom_sheet_cureve_right.png"),

          Expanded(
            child: Container(
              color: Color(0xffF1F1F7),
              child: SafeArea(
                child:
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: txStyle16SemiBold),
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
                        Expanded(
                          child: ListView.separated(
                            itemCount: categories.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (context, index) {
                              final cat = categories[index];
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(cat, style: txStyle15),
                                onTap: () => onSelected(cat),
                              );
                            },
                          ),
                        ),
                      ],
                    ).paddingSymmetric(
                      horizontal: SizeConfig.widthOf(5),
                      vertical: 20,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
