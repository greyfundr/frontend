// lib/screens/campaign/widgets/expense_section.dart
import 'package:flutter/material.dart';

class ExpenseSection extends StatelessWidget {
  final List<dynamic> expenses;
  final VoidCallback onAddPressed;

  const ExpenseSection({
    super.key,
    required this.expenses,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // makes button full width
      children: [
        // The button itself
        expenses.isEmpty
            ? ElevatedButton(
                onPressed: onAddPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12), // increased from 8 → 16 for consistency
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'ADD BILL LISTING',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : OutlinedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.receipt_long, size: 20),
                label: Text(
                  '${expenses.length} Expense${expenses.length > 1 ? 's' : ''} Added • Add More',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Colors.deepOrange, width: 2),
                  foregroundColor: Colors.deepOrange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

        // This adds the spacing you want below the button
        const SizedBox(height: 20), // adjust this value as needed (16, 24, 32…)
      ],
    );
  }
}