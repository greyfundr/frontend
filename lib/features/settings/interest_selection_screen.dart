import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/components/custom_button.dart';
import 'package:greyfundr/shared/sizeConfig.dart';

class InterestSelectionScreen extends StatefulWidget {
  final List<String> initialInterests;
  const InterestSelectionScreen({super.key, required this.initialInterests});

  @override
  State<InterestSelectionScreen> createState() => _InterestSelectionScreenState();
}

class _InterestSelectionScreenState extends State<InterestSelectionScreen> {
  late List<String> selectedInterests;

  final List<Map<String, String>> availableInterests = [
    {"name": "Technology", "emoji": "💻"},
    {"name": "Art", "emoji": "🎨"},
    {"name": "Music", "emoji": "🎵"},
    {"name": "Sports", "emoji": "⚽"},
    {"name": "Cooking", "emoji": "🍳"},
    {"name": "Travel", "emoji": "✈️"},
    {"name": "Reading", "emoji": "📚"},
    {"name": "Gaming", "emoji": "🎮"},
    {"name": "Photography", "emoji": "📷"},
    {"name": "Writing", "emoji": "📝"},
    {"name": "Fitness", "emoji": "💪"},
    {"name": "Business", "emoji": "💼"},
    {"name": "Finance", "emoji": "💰"},
    {"name": "Education", "emoji": "🎓"},
  ];

  @override
  void initState() {
    super.initState();
    selectedInterests = List.from(widget.initialInterests);
  }

  void _toggleInterest(String name) {
    setState(() {
      if (selectedInterests.contains(name)) {
        selectedInterests.remove(name);
      } else {
        selectedInterests.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Select Interests"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.widthOf(5),
                vertical: 20,
              ),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 12.0,
                children: availableInterests.map((interest) {
                  final name = interest["name"]!;
                  final emoji = interest["emoji"]!;
                  final isSelected = selectedInterests.contains(name);

                  return InkWell(
                    onTap: () => _toggleInterest(name),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.withOpacity(0.1) : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey.shade300,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 16)),
                          const Gap(8),
                          Text(
                            name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.green : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.widthOf(5),
              vertical: 20,
            ),
            child: CustomButton(
              onTap: () {
                Get.back(result: selectedInterests);
              },
              label: "Done",
            ),
          ),
        ],
      ),
    );
  }
}
