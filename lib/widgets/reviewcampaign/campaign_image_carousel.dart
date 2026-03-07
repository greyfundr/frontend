// lib/screens/campaign_review/widgets/campaign_image_carousel.dart
import 'dart:io';
import 'package:flutter/material.dart';

class CampaignImageCarousel extends StatefulWidget {
  final List<File> images;
  const CampaignImageCarousel({super.key, required this.images});

  @override
  State<CampaignImageCarousel> createState() => _CampaignImageCarouselState();
}

class _CampaignImageCarouselState extends State<CampaignImageCarousel> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Container(
        height: 240,
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 60, color: Colors.white70),
              SizedBox(height: 8),
              Text("No images added", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    // LIVE SECTION - With beautiful wavy bottom
    return SizedBox(
      height: 220,
      child: ClipPath(
        clipper: WavyBottomClipper(),
        child: Stack(
          children: [
            // PageView with images
            PageView.builder(
              onPageChanged: (i) => setState(() => currentIndex = i),
              itemCount: widget.images.length,
              itemBuilder: (_, i) => Image.file(
                widget.images[i],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),

            // Optional dark gradient at bottom so indicators are always visible
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black54,
                    ],
                  ),
                ),
              ),
            ),

            // Page indicators (pills style - looks modern)
            Positioned(
              bottom: 55,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.images.asMap().entries.map((entry) {
                  int idx = entry.key;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 8,
                    width: currentIndex == idx ? 24 : 8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black38,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================
// Custom Clipper for Wavy Bottom
// ============================
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