import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

 
class ShimmerLoader extends StatelessWidget {
  final Widget content;
  final EdgeInsetsGeometry? padding;
  const ShimmerLoader({
    super.key,
    required this.content,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface,
      highlightColor: Colors.grey.withOpacity(0.8),
      child: content,
    );
  }
}
