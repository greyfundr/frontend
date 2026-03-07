// lib/screens/campaign/components/campaign_title_field.dart
import 'package:flutter/material.dart';

class CampaignTitleField extends StatelessWidget {
  final TextEditingController controller;
  const CampaignTitleField({required this.controller, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8), // left & right only
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
       Padding(
  padding: const EdgeInsets.symmetric(horizontal: 4), // left & right only
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Campaign Title',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
      ),
      const SizedBox(height: 2),
      Text(
        'A name for your Campaign/Fundraiser',
        style: TextStyle(color: Colors.grey[600]),
      ),
    ],
  ),
),
      const SizedBox(height: 6),
     TextField(
  controller: controller,
  maxLength: 100,
  decoration: InputDecoration(
    hintText: 'e.g. Support for Kids in Borno',
    hintStyle: TextStyle(
      color: Colors.grey[500], // <-- grey hint text
      fontSize: 14,
    ),
    filled: true,
    fillColor: Colors.white,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

    // Default border (when not focused)
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 1.5),
    ),

    // Focused border
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 2),
    ),

    // If you want the general border too
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
)
    ],
  ),
);

  }
}