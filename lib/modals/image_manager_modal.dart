// lib/screens/campaign/modals/image_manager_modal.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/text_style.dart';
 import 'package:image_picker/image_picker.dart';

// Custom Clipper for the curved top edge
class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 20);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 1);
    var secondControlPoint = Offset(3 * size.width / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

void showImageManagerModal(
  BuildContext context,
  List<File> currentImages,
  Function(List<File>) onSave,
) {
  List<File> tempImages = List.from(currentImages);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ClipPath(
      clipper: CurvedTopClipper(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        color: Colors.white,
        child: StatefulBuilder(
          builder: (context, setModalState) => Column(
            children: [
              // Draggable nudge handle + Title
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  children: [
                    // Nudge handle (drag indicator)
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      "Campaign Images",
                      style: txStyle18.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),

              // Image Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: tempImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            tempImages[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => setModalState(() => tempImages.removeAt(index)),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 16, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Add More Images Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickMultiImage();
                    if (picked.isNotEmpty) {
                      setModalState(() {
                        tempImages.addAll(picked.map((x) => File(x.path)));
                      });
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text("Add More Images"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // Save Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: ElevatedButton(
                  onPressed: () {
                    onSave(tempImages);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Save Images"),
                ),
              ),
              const SizedBox(height: 100),
            ],
            
          ),
        ),
      ),
    ),
  );
}