import 'package:flutter/material.dart';

class FormSectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;

  const FormSectionTitle(
    this.title, {
    super.key,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
        const SizedBox(height: 3),
      ],
    );
  }
}