// lib/screens/campaign/components/campaign_description_field.dart
import 'package:flutter/material.dart';

class CampaignDescriptionField extends StatelessWidget {
  final TextEditingController controller;
  const CampaignDescriptionField({required this.controller, super.key});

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
     const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
      const SizedBox(height: 2),
       Text('Tell your story so donors understand your goal', style: TextStyle(color: Colors.grey[600])),
    ],
  ),
),


        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Why do you need help? How will the money be used?',
            hintStyle: TextStyle(
      color: Colors.grey[500], // <-- grey hint text
      fontSize: 14,
    ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            // Default border (when not focused)
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 1.5),
    ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 2),
            ),
          ),
        ),
      ],
    )
    );
  }
}