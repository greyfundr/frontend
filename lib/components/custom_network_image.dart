
 import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:greyfundr/components/shimmer_loader_widget.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    Key? key,
    this.imageUrl,
    required this.radius,
  }) : super(key: key);

  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
          // shape: BoxShape.circle, border: Border.all(color: lightYellowColor)
          // image: DecorationImage(
          //     image: AssetImage('assets/images/accountOwner.png'))
          ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Builder(builder: (ctx) {
            final s = imageUrl?.trim() ?? '';
            final isNetwork = s.startsWith('http://') || s.startsWith('https://');
            if (isNetwork) {
              return CachedNetworkImage(
                imageUrl: s,
                fit: BoxFit.cover,
                placeholder: (context, url) => ShimmerLoader(
                  padding: EdgeInsets.zero,
                  content: Container(height: radius, width: radius, color: Colors.white),
                ),
                errorWidget: (context, url, error) => Image.asset('assets/images/placeholder.jpg'),
              );
            }

            // fallback to asset placeholder when value is missing or not a valid network URL
            return Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
          }),
        ),
    );
  }
}