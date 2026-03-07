import 'dart:io';

import 'package:flutter/material.dart';

class BillImagePreview extends StatelessWidget {
  final File? imageFile;
  final String? imageUrl;
  final VoidCallback onPickImage;
  final VoidCallback onRemove;

  const BillImagePreview({
    super.key,
    this.imageFile,
    this.imageUrl,
    required this.onPickImage,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF007A74);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bill Receipt",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  "Upload a photo of the bill receipt",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            GestureDetector(
              onTap: onPickImage,
              child: Container(
                padding: const EdgeInsets.all(10),
                // decoration: BoxDecoration(
                //   color: primaryColor.withOpacity(0.08),
                //   borderRadius: BorderRadius.circular(12),
                // ),
                child: Image.asset(
                  'assets/images/scan_image.png',
                  width: 48,
                  height: 48,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        if (imageFile != null || (imageUrl != null && imageUrl!.isNotEmpty))
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: imageFile != null
                    ? Image.file(
                        imageFile!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        imageUrl!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
          )
        else
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[20],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Center(
              child: Text(
                "No receipt added yet",
                style: TextStyle(color: Colors.grey[500]),
              ),
            ),
          ),
      ],
    );
  }
}