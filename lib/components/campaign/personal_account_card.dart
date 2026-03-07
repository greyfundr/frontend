// lib/screens/campaign/components/personal_account_card.dart
import 'package:flutter/material.dart';

class PersonalAccountCard extends StatelessWidget {
  const PersonalAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
  elevation: 0,                         // No default elevation shadow
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(6),
    side: BorderSide(color: const Color.fromARGB(255, 216, 216, 216), width: 1), // Light border instead of shadow
  ),
  child: Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: const Color.fromARGB(255, 204, 204, 204),
          blurRadius: 10,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        Image.asset('assets/images/personal.png', width: 56, height: 56),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Campaign For You',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Set up your personal campaign you want people to donate to',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
);
  }
}