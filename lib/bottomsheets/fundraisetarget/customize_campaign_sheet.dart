// lib/screens/campaign/bottom_sheets/customize_campaign_sheet.dart
import 'package:flutter/material.dart';

class CustomizeCampaignSheet extends StatelessWidget {
  final VoidCallback onThankYouPressed; // Optional callback if needed

  const CustomizeCampaignSheet({super.key, this.onThankYouPressed = _default});

  static void _default() {}

  @override
  Widget build(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setModalState) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.81,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Center(
                        child: Text('Customise Campaign',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                      ),
                    ),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView(
                    children: [
                      _buildOption(icon: '💰', title: 'Suggest Donation amount', subtitle: "Enter the amount you'd like others to consider giving.", hasToggle: false),
                      _buildOption(icon: '🌐', title: 'Show Contributions', hasToggle: true),
                      _buildOption(icon: '💬', title: 'Allow Comments', hasToggle: true),
                      _buildOption(icon: '👥', title: 'Allow Co-Campaigning', subtitle: 'Supporters can start a mini campaign under yours to rally more donations.', hasToggle: true),
                      _buildOption(icon: '🌐', title: 'Make Discoverable', subtitle: 'Your listing will appear in search results...', hasToggle: true),
                      _buildOption(icon: '📣', title: 'Allow Champions', subtitle: 'Allow others to champion your campaign...', hasToggle: true),
                      _buildOption(icon: '⭐', title: 'Set Conditions & Rewards', subtitle: 'Encourage donations by offering special rewards...', hasToggle: false),
                      _buildOption(
                        icon: '❤️',
                        title: 'Set "Thank You" Message',
                        subtitle: 'Send a personal message to thank supporters after they contribute.',
                        hasToggle: false,
                        onTap: onThankYouPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOption({
    required String icon,
    required String title,
    String? subtitle,
    bool hasToggle = false,
    bool toggleValue = true,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: hasToggle ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ],
              ),
            ),
            if (hasToggle)
              Switch(value: toggleValue, onChanged: (_) {}, activeThumbColor: Colors.teal),
          ],
        ),
      ),
    );
  }
}