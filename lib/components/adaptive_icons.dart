import 'dart:io';

import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/app_colors.dart';

class AdaptiveIcons extends StatelessWidget {
  final String iconName;
  final IconData iconData;
  final VoidCallback? onTap;
  final Color? iconColor;
  const AdaptiveIcons({
    super.key,
    required this.iconName,
    required this.iconData,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? CNButton.icon(
            icon: CNSymbol(iconName, size: 17),
            onPressed: onTap,
            // tint: appPrimaryColor,
            // size: 30,
          )
        : InkWell(
            onTap: onTap,
            child: Container(
              padding: EdgeInsets.all(7),
              decoration: BoxDecoration(
                // border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                iconData,
                size: 25,
                color: iconColor ?? appPrimaryColor,
              ),
            ),
          );
  }
}
