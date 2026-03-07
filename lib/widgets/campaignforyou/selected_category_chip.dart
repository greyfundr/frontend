// lib/screens/campaign/widgets/selected_category_chip.dart
import 'package:flutter/material.dart';

class SelectedCategoryChip extends StatelessWidget {
  final String category;
  final VoidCallback onRemove;

  const SelectedCategoryChip({required this.category, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF00A9A5), size: 28),
                const SizedBox(width: 12),
                Text(category, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          Positioned(
            right: -8,
            top: -8,
            child: GestureDetector(
              onTap: onRemove,
              child: const CircleAvatar(radius: 14, backgroundColor: Colors.red, child: Icon(Icons.close, size: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}