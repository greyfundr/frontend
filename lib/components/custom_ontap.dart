
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/utils.dart';

class CustomOnTap extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final Color? highlightColor;
  final Color? splashColor;

  const CustomOnTap({
    super.key,
    required this.onTap,
    required this.child,
    this.highlightColor = Colors.transparent,
    this.splashColor = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      highlightColor: highlightColor,
      splashColor: splashColor,
      onTap: () async {
        doHepticFeedback();

        onTap!();
      },
      child: child,
    );
  }
}
