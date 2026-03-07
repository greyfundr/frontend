import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greyfundr/core/models/budget_model.dart';

class CampaignTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final String description;
  final List<Expense> budgetItems;
  final List<Map<String, String>> offers;
  final VoidCallback onEditAbout;
  final VoidCallback onEditBudget;
  final VoidCallback onEditOffers;

  const CampaignTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabChanged,
    required this.description,
    required this.budgetItems,
    required this.offers,
    required this.onEditAbout,
    required this.onEditBudget,
    required this.onEditOffers,
  });

  Widget _tab(String label, int index, VoidCallback? onEdit) {
    final selected = selectedIndex == index;
    return GestureDetector(
      onTap: () => onTabChanged(index),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected ? Colors.black87 : Colors.grey[600],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  icon: const Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: Color.fromRGBO(130, 176, 171, 1),
                  ),
                  onPressed: onEdit,
                ),
            ],
          ),
          Container(
            height: 3,
            width: 40,
            color: selected
                ? const Color.fromRGBO(0, 164, 175, 1)
                : Colors.transparent,
          ),
        ],
      ),
    );
  }


// icon: const Icon(Icons.edit_note_rounded, color: Colors.teal),

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Header with White Background
        Container(
         
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
              ],
            ), // White background for header
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _tab("ABOUT", 0, onEditAbout),
              _tab("BUDGETING", 1, onEditBudget),
              _tab("OFFERS", 2, onEditOffers),
            ],
          ),
        ),

        // Tab Content with Grey Background
        Container(
          width: double.infinity,
          height: 190,
          color: const Color.fromARGB(255, 229, 229, 229), // Grey background for content
          child: IndexedStack(
            index: selectedIndex,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  description,
                  style: GoogleFonts.inter(fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: budgetItems.isEmpty
                    ? const Text("No budget items")
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: budgetItems
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e.name),
                                      Text(
                                        "₦${e.cost}",
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                0, 164, 175, 1)),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: offers.isEmpty
                    ? const Text("No offers")
                    : Column(
                        children: offers
                            .map((o) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Condition: ${o['condition'] ?? ''}"),
                                      Text(
                                        "Reward: ${o['reward'] ?? ''}",
                                        style: const TextStyle(
                                            color: Color.fromRGBO(
                                                0, 164, 175, 1)),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}