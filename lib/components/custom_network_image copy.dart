import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:greyfundr/components/shimmer_loader_widget.dart';
import 'package:greyfundr/shared/app_colors.dart';

class CustomNetworkImageSqr extends StatelessWidget {
  const CustomNetworkImageSqr(
      {super.key,
      required this.imageUrl,
      required this.height,
      required this.width,
      this.fit,
      this.padding,
      this.borderRadius = 15,
      this.backgroundColor,
      });

  final String imageUrl;
  final double height;
  final double width;
  final BoxFit? fit;
  final double? padding;
  final double borderRadius;
  final Color ? backgroundColor;



  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      padding: EdgeInsets.all(padding ?? 7),
      decoration:   BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(borderRadius)
        // shape: BoxShape.circle,
        // image: DecorationImage(
        //     image: AssetImage('assets/images/accountOwner.png'))
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: fit ?? BoxFit.contain,
          placeholder: (context, url) => ShimmerLoader(
              content: Container(
            height: height,
            width: width,
            color: Colors.white,
          )),
          errorWidget: (context, url, error) => Container(
            height: height,
            width: width,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: borderColor,
              borderRadius: BorderRadius.circular(7),
            ),
            child: SvgPicture.asset(
              "assets/svgs/Bank_Image.svg",
              height: height - 10,
              width: width - 10,
            ),
          ),
        ),
      ),
    );
  }
}

// class CustomNetworkImageWithColor extends StatefulWidget {
//   const CustomNetworkImageWithColor({
//     super.key,
//     required this.imageUrl,
//     required this.radius,
//   });

//   final String imageUrl;
//   final double radius;

//   @override
//   _CustomNetworkImageWithColorState createState() =>
//       _CustomNetworkImageWithColorState();
// }

// class _CustomNetworkImageWithColorState
//     extends State<CustomNetworkImageWithColor> {
//   Color _containerColor = AppColors.primary.withOpacity(.2);

//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 1), () {
//       _generateContainerColor();
//     });
//   }

//   Future<void> _generateContainerColor() async {
//     final imageProvider = CachedNetworkImageProvider(widget.imageUrl);
//     final PaletteGenerator paletteGenerator =
//         await PaletteGenerator.fromImageProvider(imageProvider);

//     setState(() {
//       _containerColor = paletteGenerator.dominantColor!.color;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: widget.radius,
//       width: widget.radius,
//       decoration: BoxDecoration(
//         // shape: BoxShape.circle,
//         borderRadius: BorderRadius.circular(5),
//         color: _containerColor.withOpacity(0.5),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(6),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(5),
//           child: CachedNetworkImage(
//             imageUrl: widget.imageUrl,
//             fit: BoxFit.cover,
//             placeholder: (context, url) => ShimmerLoader(
//                 content: Container(
//               color: Colors.white,
//               width: widget.radius,
//               height: widget.radius,
//             )),
//             errorWidget: (context, url, error) => const Icon(Icons.error),
//           ),
//         ),
//       ),
//     );
//   }
// }
