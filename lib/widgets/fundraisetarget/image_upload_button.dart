// lib/screens/campaign/widgets/image_upload_button.dart
import 'package:flutter/material.dart';
import 'dart:io';

class ImageUploadButton extends StatelessWidget {
  final int index;
  final List<File> selectedImages;
  final bool isMain;
  final VoidCallback onTap;
  final ValueChanged<int> onDelete;

  const ImageUploadButton({
    super.key,
    required this.index,
    required this.selectedImages,
    required this.isMain,
    required this.onTap,
    required this.onDelete,
  });

  bool get hasImage => index < selectedImages.length;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: hasImage ? null : onTap,
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              border: Border.all(
                color: isMain ? Colors.teal : Colors.grey.shade300,
                width: isMain ? 0.5 : 0.25,
              ),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[50],
            ),
            child: hasImage
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImages[index],
                            fit: BoxFit.cover),
                      ),
                      if (isMain)
                        Positioned(
                          top: 4,
                          left: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text("MAIN",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_outlined,
                          color: isMain ? Colors.teal : Colors.grey, size: 28),
                      if (isMain)
                        const Text("Cover",
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.teal,
                                fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
        if (hasImage)
          Positioned(
            right: -8,
            top: -8,
            child: GestureDetector(
              onTap: () => onDelete(index),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(Icons.close,
                    color: Colors.white, size: 14),
              ),
            ),
          ),
      ],
    );
  }
}