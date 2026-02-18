 
import 'package:greyfundr/components/custom_circular_progress_indicator.dart';
import 'package:greyfundr/shared/app_colors.dart';
import 'package:greyfundr/shared/text_style.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback onTap;
  final Color? color;
  final String label;
  final bool isTransparent;
  final bool borderless;
  final bool enabled;
  final double width;
  final double? height;
  final int fontSize;
  final double borderRadius;
  final Color backgroundColor;
  final bool loading;
  final Color? borderColor;
  final Widget? icon;

  const CustomButton({
    super.key,
    required this.onTap,
    this.color,
    this.height,
    this.fontSize = 16,
    this.borderRadius = 10.0,
    this.isTransparent = false,
    this.enabled = true,
    this.width = double.infinity,
    this.backgroundColor = appPrimaryColor,
    required this.label,
    this.borderless = false,
    this.loading = false,
    this.borderColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: width,
      child: Opacity(
        opacity: (enabled || loading) ? 1 : 0.4,
        child: InkWell(
          onTap: enabled ? onTap : () {},
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: borderColor ?? appPrimaryColor),
            ),
            child: Center(
              child: loading
                  ? CustomCircularProgressIndicator(strokeWidth: 5, color: Colors.white,)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          textAlign: TextAlign.center,
                          style: txStyle14SemiBold.copyWith(
                            color: color ?? Colors.white,
                            fontSize: fontSize.toDouble(),
                          ),
                        ),
                        if (icon != null) ...[SizedBox(width: 10), icon!],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
