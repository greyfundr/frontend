// lib/screens/campaign_review/widgets/campaign_tabs_section.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greyfundr/core/models/budget_model.dart';

class CampaignTabsSection extends StatelessWidget {
  final int selectedTab;
  final Function(int) onTabChanged;
  final String description;
  final List<Expense> budgetItems;
  final List<Map<String, String>> offers;

  const CampaignTabsSection({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
    required this.description,
    required this.budgetItems,
    required this.offers,
  });

  static const List<String> tabs = [
    "ABOUT",
    "BUDGETING",
    "OFFERS",
  ];

  static const double contentHeight = 190.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(241, 241, 247, 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // ── Tab Bar ──
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ),
            child: Row(
              children: tabs.asMap().entries.map((e) {
                final index = e.key;
                final label = e.value;
                final isSelected = selectedTab == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.black87 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 3,
                          width: 28,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.black87 : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Divider
          Container(height: 1, color: Colors.grey[300]),

          // ── Scrollable Content Area ──
          SizedBox(
            height: contentHeight,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (selectedTab) {
      case 0: // ABOUT
        return Text(
          description,
          textAlign: TextAlign.start,
          style: GoogleFonts.inter(fontSize: 13.5, height: 1.7),
        );

      case 1: // BUDGETING
        if (budgetItems.isEmpty) {
          return const Text(
            "No budget items",
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.grey),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: budgetItems.map((e) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      e.name,
                      style: GoogleFonts.inter(fontSize: 14),
                    ),
                  ),
                  Text(
                    "₦${e.cost}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      case 2: // OFFERS
        if (offers.isEmpty) {
          return const Text(
            "No offers yet",
            textAlign: TextAlign.start,
            style: TextStyle(color: Colors.grey),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: offers.map((o) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Condition:", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(o['condition'] ?? '', style: GoogleFonts.inter()),
                  const SizedBox(height: 12),
                  Text("Reward:", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    o['reward'] ?? '',
                    style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          }).toList(),
        );

      // This default return fixes the "body might complete normally" error
      default:
        return const Text(
          "Invalid tab",
          textAlign: TextAlign.start,
          style: TextStyle(color: Colors.red),
        );
    }
  }
}