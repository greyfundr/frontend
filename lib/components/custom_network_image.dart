
 import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greyfundr/components/shimmer_loader_widget.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    this.imageUrl,
    required this.radius,
    this.width,
    this.borderRadius,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final double radius;
  final double? width;
  final double? borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final w = width ?? radius;
    final r = borderRadius ?? radius;
    return Container(
      height: radius,
      width: w,
      decoration: BoxDecoration(
          // shape: BoxShape.circle, border: Border.all(color: lightYellowColor)
          // image: DecorationImage(
          //     image: AssetImage('assets/images/accountOwner.png'))
          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(r),
          child: Builder(builder: (ctx) {
            final s = imageUrl?.trim() ?? '';
            final isNetwork = s.startsWith('http://') || s.startsWith('https://');
            if (isNetwork) {
              return CachedNetworkImage(
                imageUrl: s,
                fit: fit,
                placeholder: (context, url) => ShimmerLoader(
                  padding: EdgeInsets.zero,
                  content: Container(height: radius, width: w, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Image.asset('assets/images/placeholder.jpg', fit: fit),
              );
            }

            // fallback to asset placeholder when value is missing or not a valid network URL
            return Image.asset('assets/images/placeholder.jpg', fit: fit);
          }),
        ),
    );
  }
}