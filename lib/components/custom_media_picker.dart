import 'dart:io';
import 'package:greyfundr/components/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';

class CustomMediaPicker extends StatelessWidget {
  final List<XFile> images;
  final List<String> networkImages;
  final VoidCallback onAddMedia;
  final Function(int) onRemoveMedia;
  final Function(int)? onRemoveNetworkMedia;

  const CustomMediaPicker({
    super.key,
    required this.images,
    this.networkImages = const [],
    required this.onAddMedia,
    required this.onRemoveMedia,
    this.onRemoveNetworkMedia,
  });

  @override
  Widget build(BuildContext context) {
    final totalMediaCount = networkImages.length + images.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (totalMediaCount > 0) ...[
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: totalMediaCount + 1, // +1 for the add more button
              separatorBuilder: (_, __) => const Gap(12),
              itemBuilder: (context, index) {
                if (index == totalMediaCount) {
                  // Add more button
                  return GestureDetector(
                    onTap: onAddMedia,
                    child: DottedBorder(
                      color: appPrimaryColor,
                      strokeWidth: 1.5,
                      dashPattern: const [6, 4],
                      radius: const Radius.circular(12),
                      child: Container(
                        width: 100,
                        height: 120,
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.add_photo_alternate_outlined,
                          color: appPrimaryColor,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                }

                if (index < networkImages.length) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          networkImages[index],
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        ),
                      ),
                      if (onRemoveNetworkMedia != null)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => onRemoveNetworkMedia!(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                }

                final localIndex = index - networkImages.length;

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(images[localIndex].path),
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => onRemoveMedia(localIndex),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ] else ...[
          GestureDetector(
            onTap: onAddMedia,
            child: DottedBorder(
              color: appPrimaryColor,
              strokeWidth: 1.5,
              dashPattern: const [6, 4],
              radius: const Radius.circular(12),
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: appPrimaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Handle case if upload.svg doesn't exist by falling back to Icon
                    SvgPicture.asset(
                      'assets/svgs/upload.svg',
                      height: 40,
                      colorFilter: const ColorFilter.mode(
                        appPrimaryColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const Gap(12),
                    Text(
                      "Click to upload media",
                      style: txStyle14.copyWith(
                        color: appPrimaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      "SVG, PNG, JPG or GIF (max. 5MB)",
                      style: txStyle12.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
