// lib/screens/campaign/widgets/edit_campaign_header.dart
import 'dart:io';
import 'package:flutter/material.dart';

class EditCampaignHeader extends StatelessWidget {
  final List<File> images;
  final VoidCallback onEditPressed;

  const EditCampaignHeader({super.key, required this.images, required this.onEditPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: WavyBottomClipper(),  // Custom wavy clipper
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: images.isEmpty
                ? Container(
                    color: Colors.grey[300],
                    child: const Center(child: Text("No images")),
                  )
                : PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (_, i) => Image.file(
                      images[i],
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
        Positioned(
          top: 100,  // Adjusted downward to account for the wave extending ~40px below the original bottom
          right: 20,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Colors.white,
            onPressed: onEditPressed,
            child: const Icon(Icons.camera_enhance_outlined, color: Color.fromRGBO(0, 164, 175, 1)),
          ),
        ),
      ],
    );
  }
}

// Custom clipper for a gentle wavy bottom curve
class WavyBottomClipper extends CustomClipper<Path> {
  final double depth;

  const WavyBottomClipper({this.depth = 30});

  @override
  Path getClip(Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height - depth)
      ..quadraticBezierTo(size.width * 0.75, size.height, size.width * 0.5, size.height)
      ..quadraticBezierTo(size.width * 0.25, size.height, 0, size.height - depth)
      ..close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}