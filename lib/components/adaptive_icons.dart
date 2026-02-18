import 'dart:io';

import 'package:cupertino_native/components/button.dart';
import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/app_colors.dart';

class AdaptiveIcons extends StatelessWidget {
  final String iconName;
  final IconData iconData;
  final VoidCallback? onTap;
  const AdaptiveIcons({
    super.key,
    required this.iconName,
    required this.iconData,
    this.onTap,
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
          child: Icon(iconData, size: 17, color: appPrimaryColor));
  }
}
