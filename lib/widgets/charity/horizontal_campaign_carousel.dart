// lib/screens/charity/widgets/horizontal_campaign_carousel.dart
import 'package:flutter/material.dart';

class HorizontalCampaignCarousel extends StatelessWidget {
  final bool isVisible;

  const HorizontalCampaignCarousel({super.key, required this.isVisible});

  Widget _horizontalCard({
    required String name,
    required String subtitle,
    required String amount,
  }) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10), // Reduced from 12
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 232, 232, 232),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16, // Reduced from 20
            backgroundImage: AssetImage('assets/images/personal.png'),
          ),
          const SizedBox(width: 8), // Reduced from 10
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5), // Slightly smaller
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 9.5), // Reduced
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color.fromARGB(179, 37, 60, 48),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Smaller padding
              minimumSize: const Size(60, 28), // Ensures button doesn't collapse
            ),
            child: const Text(
              "Donate",
              style: TextStyle(fontSize: 9.5), // Reduced from 10
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      child: AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, -0.5),
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
        child: Offstage(
          offstage: !isVisible,
          child: Container(
            height: 80, // Reduced from 100 → much more compact
            margin: const EdgeInsets.only(left: 16, bottom: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _horizontalCard(
                  name: "Hip Replacement",
                  subtitle: "Angel needs hip replacement",
                  amount: "24 million naira",
                ),
                _horizontalCard(
                  name: "Sandra's Wedding",
                  subtitle: "My Wedding is coming soon",
                  amount: "85 million",
                ),
                // Add more cards as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}