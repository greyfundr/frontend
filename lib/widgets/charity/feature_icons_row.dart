// lib/screens/charity/widgets/feature_icons_row.dart
import 'package:flutter/material.dart';

class FeatureIconsRow extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const FeatureIconsRow({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
  {'label': 'All', 'icon': Icons.refresh, 'color': Colors.grey},
  {'label': 'Medical', 'icon': Icons.medical_services, 'color': Colors.amber},
  {'label': 'Education', 'icon': Icons.school, 'color': Colors.pink},
  {'label': 'Travel', 'icon': Icons.travel_explore, 'color': Colors.green},
  {'label': 'Nature', 'icon': Icons.nature, 'color': Colors.orange},
  {'label': 'Animal', 'icon': Icons.pets, 'color': Colors.blue},
  {'label': 'Social', 'icon': Icons.group, 'color': Color.fromARGB(255, 69, 78, 16)},
  {'label': 'Disaster', 'icon': Icons.warning, 'color': Colors.red},
  {'label': 'Religion', 'icon': Icons.church, 'color': Colors.purple},
  {'label': 'Business', 'icon': Icons.business, 'color': Colors.indigo},
];

  Widget _featureIcon(Map<String, dynamic> cat) {
    final label = cat['label'] as String;
    final isSelected = label == selectedCategory;

    return GestureDetector(
      onTap: () => onCategorySelected(label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cat['color'] as Color,
              shape: BoxShape.circle,
              border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
            ),
            child: Icon(
              cat['icon'] as IconData,
              color: Colors.white,
              size: isSelected ? 30 : 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.black : Colors.black87,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 16),
            ..._categories.map((cat) => [
                  _featureIcon(cat),
                  const SizedBox(width: 20),
                ]).expand((e) => e).toList()
              ..removeLast(), // Remove trailing spacer
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}