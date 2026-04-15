import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/route_manager.dart';
import 'package:greyfundr/components/custom_ontap.dart';
import 'package:greyfundr/features/event/event_description_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:greyfundr/components/custom_textfield_component.dart';
import 'package:greyfundr/components/custom_media_picker.dart';
import 'package:greyfundr/features/event/event_provider.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

class Step3DetailedDescription extends StatelessWidget {
  const Step3DetailedDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Detailed Description", style: txStyle24SemiBold),
              CustomOnTap(
                onTap: () {
                  Get.to(
                    CustomEventImages(),
                    transition: Transition.rightToLeft,
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: appSecondaryColor.withOpacity(.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "View sample",
                    style: txStyle12Bold.copyWith(color: appSecondaryColor),
                  ),
                ),
              ),
            ],
          ),
          Gap(5),
          Text(
            "Add sections to describe your event",
            style: txStyle14.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.detailedDescription.length,
            separatorBuilder: (_, __) => const Gap(24),
            itemBuilder: (context, index) {
              final section = provider.detailedDescription[index];
              final controller = provider.detailControllers[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Section ${index + 1}",
                        style: txStyle15.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (provider.detailedDescription.length > 1)
                        IconButton(
                          onPressed: () => provider.removeDetailSection(index),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  const Gap(8),
                  CustomTextField(
                    labelText: "Title",
                    hintText: "E.g: Our Mission",
                    controller: provider.detailTitleControllers[index],
                    onChanged: (title) {
                      provider.updateDetailSectionTitle(index, "$title");
                    },
                  ),
                  const Gap(15),
                  CustomTextField(
                    hintText: "Enter description text...",
                    labelText: "Description",
                    controller: controller,
                    maxLines: 5,

                    onChanged: (text) {
                      provider.updateDetailSectionText(index, "$text");
                    },
                  ),
                  const Gap(15),

                  // Media Section
                  CustomMediaPicker(
                    images: section.media,
                    networkImages: section.existingMediaUrls,
                    onAddMedia: () async {
                      final picked = await ImagePicker().pickMultiImage();
                      if (picked.isNotEmpty) {
                        provider.addMediaToDetailSection(index, picked);
                      }
                    },
                    onRemoveMedia: (mIndex) =>
                        provider.removeMediaFromDetailSection(index, mIndex),
                    onRemoveNetworkMedia: (mIndex) => provider
                        .removeExistingMediaFromDetailSection(index, mIndex),
                  ),
                ],
              );
            },
          ),
          const Gap(24),

          Center(
            child: OutlinedButton.icon(
              onPressed: provider.addDetailSection,
              icon: const Icon(Icons.add, color: appPrimaryColor),
              label: Text(
                "Add Paragraph",
                style: TextStyle(color: appPrimaryColor),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: appPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ),

          const Gap(80),
        ],
      ),
    );
  }
}
