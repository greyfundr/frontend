import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'image_upload_button.dart';

class ImageUploadSection extends StatelessWidget {
  final List<File> selectedImages;
  final ValueChanged<List<File>> onImagesChanged;
  final ImagePicker imagePicker;

  const ImageUploadSection({
    super.key,
    required this.selectedImages,
    required this.onImagesChanged,
    required this.imagePicker,
  });

  Future<void> _pickImage() async {
    if (selectedImages.length >= 4) {
      // You can show snackbar from parent if needed
      return;
    }
    final XFile? picked =
        await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null) {
      onImagesChanged([...selectedImages, File(picked.path)]);
    }
  }

  void _deleteImage(int index) {
    final newList = List<File>.from(selectedImages)..removeAt(index);
    onImagesChanged(newList);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 2), // horizontal padding for the whole column
 child: Container(
  padding: const EdgeInsets.all(6), // horizontal + vertical padding
  decoration: BoxDecoration(
    border: Border.all(
      color: Colors.grey.shade300, // light border
      width: 1,
    ),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Upload Images',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 4),
      const Text(
        'Add images that tells your story in a glance',
        style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 116, 115, 115)),
      ),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(4, (i) => Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: i == 0 ? 0 : 4,
              right: i == 3 ? 0 : 4,
            ),
            child: ImageUploadButton(
              index: i,
              selectedImages: selectedImages,
              isMain: i == 0,
              onTap: _pickImage,
              onDelete: _deleteImage,
            ),
          ),
        )),
      ),
      const SizedBox(height: 8),
      const Text(
        'Please use images of yourself or your cause and not images that might infringe copyright when used.',
        style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 116, 115, 115)),
      ),
      const SizedBox(height: 10),
    ],
  ),
)

);
  }
  
}
