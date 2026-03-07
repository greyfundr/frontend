// lib/screens/campaign/widgets/offer_item_tile.dart
import 'package:flutter/material.dart';

class OfferItemTile extends StatelessWidget {
  final Map<String, String> offer;
  final bool isAuto;
  final int index;
  final VoidCallback onDelete;

  const OfferItemTile({required this.offer, required this.isAuto, required this.index, required this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: ListTile(
        title: Text(offer['condition'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(offer['reward'] ?? ''),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: onDelete),
      ),
    );
  }
}