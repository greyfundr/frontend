// lib/screens/campaign_review/widgets/action_buttons_row.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ActionButtonsRow extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onSubmit;

  const ActionButtonsRow({
    super.key,
    required this.onEdit,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      child: Column(
        children: [
          // ── Edit Campaign Button (Full Width) ──
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onEdit,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color.fromRGBO(0, 164, 175, 1),
                  width: 2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "EDIT CAMPAIGN",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: const Color.fromRGBO(0, 164, 175, 1),
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8), // Space between buttons

          // ── Submit for Approval Button (Full Width) ──
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(0, 164, 175, 1),
                padding: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "SUBMIT FOR APPROVAL",
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}