import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/adaptive_icons.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/shared/sizeConfig.dart';
import 'package:greyfundr/shared/text_style.dart';

enum CurveCorner { topLeft, topRight, bottomLeft, bottomRight }

class WaveCornerClipper extends CustomClipper<Path> {
  final CurveCorner corner;

  WaveCornerClipper({this.corner = CurveCorner.bottomRight});

  @override
  Path getClip(Size size) {
    final w = size.width;
    final h = size.height;

    Path basePath = Path();

    // Mathematically matching the scoop curve in the reference image (bottomRight version).
    basePath.lineTo(0, h * 0.92);
    basePath.cubicTo(
      w * 0.35,
      h * 0.98, // Gentle dip starting from left
      w * 0.75,
      h * 1.05, // Deep belly towards the right
      w,
      h * 0.9, // Sharp swoop up to the right edge
    );
    basePath.lineTo(w, 0);
    basePath.close();

    final matrix = Matrix4.identity();

    switch (corner) {
      case CurveCorner.bottomRight:
        return basePath;
      case CurveCorner.bottomLeft:
        // ignore: deprecated_member_use
        matrix.translate(w, 0.0);
        // ignore: deprecated_member_use
        matrix.scale(-1.0, 1.0);
        return basePath.transform(matrix.storage);
      case CurveCorner.topRight:
        // ignore: deprecated_member_use
        matrix.translate(0.0, h);
        // ignore: deprecated_member_use
        matrix.scale(1.0, -1.0);
        return basePath.transform(matrix.storage);
      case CurveCorner.topLeft:
        // ignore: deprecated_member_use
        matrix.translate(w, h);
        // ignore: deprecated_member_use
        matrix.scale(-1.0, -1.0);
        return basePath.transform(matrix.storage);
    }
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class CurvedCornerContainer extends StatelessWidget {
  final Widget child;
  final CurveCorner corner;
  final Color backgroundColor;

  const CurvedCornerContainer({
    super.key,
    required this.child,
    this.corner = CurveCorner.bottomRight,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveCornerClipper(corner: corner),
      child: Container(color: backgroundColor, child: child),
    );
  }
}

// Example usage screen
class CustomEventImages extends StatelessWidget {
  const CustomEventImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background to observe the curve
      body: MediaQuery.removePadding(
        removeTop: true,
        context: context,
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CurvedCornerContainer(
                  child: Container(
                    height: SizeConfig.heightOf(50),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/couples.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: SizeConfig.widthOf(5),
                      top: SizeConfig.heightOf(5),
                    ),
                    child: SizedBox(
                      height: 40,
                      child: AdaptiveIcons(
                        onTap: () {
                          Get.close(1);
                        },
                        iconName: "arrow.left.circle",
                        iconData: Icons.arrow_back,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: Stack(
                children: [
                  SizedBox(
                    height: SizeConfig.heightOf(20),
                    child: Image.asset(
                      "assets/images/wedding_crest.png",
                      height: SizeConfig.heightOf(20),
                    ),
                  ),
                  Positioned(
                    top: SizeConfig.heightOf(8),
                    bottom: 0,
                    left: 30,
                    right: 0,
                    child: Text(
                      "BASHIR Weds John".toUpperCase(),
                      style: txStyle24SemiBold.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Gap(20),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.white)),
                ),
                child: Text(
                  "April 11, 2026",
                  style: txStyle24SemiBold.copyWith(color: Colors.white),
                ),
              ),
            ),
            Gap(20),
            CurvedCornerContainer(
              corner: CurveCorner.topLeft,
              child: Container(
                height: SizeConfig.heightOf(50),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/couples.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(color: Color(0xffceb9a9)),
                  height: SizeConfig.heightOf(45),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.widthOf(5),
                    vertical: 30,
                  ),
                  child: Text(
                    "We invite you to share in our joy as we exchange vows and begin our new life together.We invite you to share in our joy as we exchange vows and begin our new life together.We invite you to share in our joy as we exchange vows and begin our new life together.",
                    style: txStyle14wt.copyWith(
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: SizeConfig.heightOf(20)),
                  child: CurvedCornerContainer(
                    corner: CurveCorner.topRight,
                    child: Container(
                      height: SizeConfig.heightOf(50),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("assets/images/couples.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.widthOf(5),
                vertical: 20,
              ),
              decoration: const BoxDecoration(color: Color(0xffceb9a9)),
              child: Text(
                "We invite you to share in our joy as we exchange vows and begin our new life together.We invite you to share in our joy as we exchange vows and begin our new life together.We invite you to share in our joy as we exchange vows and begin our new life together.",
                style: txStyle14wt.copyWith(
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
