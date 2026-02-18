import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/app_colors.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  final double strokeWidth;
  final double radius;
  final Color? color;

  const CustomCircularProgressIndicator({
    super.key,
    this.strokeWidth = 2.0,
    this.radius = 20,
    this.color,
  }); 

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return SizedBox(
        height: radius,
        width: radius,
        child: CupertinoActivityIndicator(
          color: color,
          radius: strokeWidth * 2, // Convert strokeWidth to radius
        ),
      );
    } else {
      return SizedBox(
        height: radius,
        width: radius,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          backgroundColor: appPrimaryColor.withOpacity(.2),
          valueColor: AlwaysStoppedAnimation<Color>(color ?? appPrimaryColor),
        ),
      );
    }
  }
}
