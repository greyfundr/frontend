// lib/screens/campaign/widgets/offers_bottom_sheet.dart
import 'package:flutter/material.dart';

// If you already have CurvedTopClipper in another file, remove the class below
// and import it instead:
// import 'package:your_app/widgets/curved_top_clipper.dart';

class CurvedTopClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 20);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 1);
    var secondControlPoint = Offset(3 * size.width / 4, 0);
    var secondEndPoint = Offset(size.width, 30);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Future<void> showOffersBottomSheet(
  BuildContext context, {
  required Function(List<Map<String, String>>, List<Map<String, String>>) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ClipPath(
            clipper: CurvedTopClipper(),
            child: Container(
              color: Colors.white, // use color directly; curve replaces borderRadius
              child: OffersBottomSheetContent(
                scrollController: scrollController,
                onSave: onSave,
              ),
            ),
          );
        },
      );
    },
  );
}

class OffersBottomSheetContent extends StatefulWidget {
  final ScrollController scrollController;
  final Function(List<Map<String, String>>, List<Map<String, String>>) onSave;

  const OffersBottomSheetContent({
    required this.scrollController,
    required this.onSave,
    super.key,
  });

  @override
  State<OffersBottomSheetContent> createState() => _OffersBottomSheetContentState();
}

class _OffersBottomSheetContentState extends State<OffersBottomSheetContent> {
  // Auto offers will hold plain string maps (condition + reward)
  final List<Map<String, String>> autoOffers = [];
  // Manual offers use controllers so user can edit them inline
  final List<Map<String, TextEditingController>> manualOffers = [];

  // Quick manual add controllers (for the add-row when type=manual)
  final TextEditingController _manualConditionCtrl = TextEditingController();
  final TextEditingController _manualRewardCtrl = TextEditingController();

  // Offer type selection
  bool _isAutoType = true;

  // Auto-presets (8 standard conditions + fixed rewards)
  final List<Map<String, String>> _autoPresets = [
    {'condition': 'Donate ₦500 or more', 'reward': 'Thank you message'},
    {'condition': 'Donate ₦1,000 or more', 'reward': 'Personal shoutout'},
    {'condition': 'Donate ₦2,500 or more', 'reward': 'Social media mention'},
    {'condition': 'Donate ₦5,000 or more', 'reward': 'Early access update'},
    {'condition': 'Donate ₦10,000 or more', 'reward': 'Behind-the-scenes video'},
    {'condition': 'Donate ₦20,000 or more', 'reward': 'Signed thank you card'},
    {'condition': 'Share campaign 5x', 'reward': 'Bonus entry prize'},
    {'condition': 'Refer 3 donors', 'reward': 'Special recognition'},
  ];

  int? _selectedPresetIndex;

  void _addManualOfferFromInputs() {
    final cond = _manualConditionCtrl.text.trim();
    final rew = _manualRewardCtrl.text.trim();
    if (cond.isEmpty && rew.isEmpty) return;
    setState(() {
      manualOffers.add({
        'condition': TextEditingController(text: cond),
        'reward': TextEditingController(text: rew),
      });
      _manualConditionCtrl.clear();
      _manualRewardCtrl.clear();
    });
  }

  void _addSelectedAutoPreset() {
    if (_selectedPresetIndex == null) return;
    final preset = _autoPresets[_selectedPresetIndex!];
    setState(() => autoOffers.add({'condition': preset['condition']!, 'reward': preset['reward']!}));
  }

  @override
  void dispose() {
    _manualConditionCtrl.dispose();
    _manualRewardCtrl.dispose();
    for (var offer in manualOffers) {
      offer['condition']?.dispose();
      offer['reward']?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _DragHandle()), // Now defined below
          const SizedBox(height: 12),
          const Text(
            'Add Offers & Rewards',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const Text(
            'Reward donors who complete certain tasks',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          // Offer Type Selector
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: const Text('Auto'),
                  selected: _isAutoType,
                  onSelected: (v) => setState(() => _isAutoType = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ChoiceChip(
                  label: const Text('Manual'),
                  selected: !_isAutoType,
                  onSelected: (v) => setState(() => _isAutoType = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Auto type UI: preset dropdown + add button
          if (_isAutoType) ...[
            const Text('Auto Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select a standard condition to auto-verify', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _selectedPresetIndex,
              items: _autoPresets.asMap().entries.map((e) {
                return DropdownMenuItem<int>(
                  value: e.key,
                  child: Text(e.value['condition']!),
                );
              }).toList(),
              onChanged: (v) => setState(() => _selectedPresetIndex = v),
              decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
            ),
            const SizedBox(height: 8),
            _addButton('Add Selected Auto Offer', _addSelectedAutoPreset),
            const SizedBox(height: 18),
            // show existing auto offers
            ...autoOffers.asMap().entries.map((entry) {
              return AutoOfferCard(
                condition: entry.value['condition']!,
                reward: entry.value['reward']!,
                onRemove: () => setState(() => autoOffers.removeAt(entry.key)),
              );
            }),
          ] else ...[
            // Manual type UI: inline inputs for new manual offer
            const Text('Manual Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('You will verify these manually', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _manualConditionCtrl,
                    decoration: InputDecoration(hintText: 'Condition', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _manualRewardCtrl,
                    decoration: InputDecoration(hintText: 'Reward', border: OutlineInputBorder(borderRadius: BorderRadius.circular(6))),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(onPressed: _addManualOfferFromInputs, child: const Text('Add')),
              ],
            ),
            const SizedBox(height: 12),
            // show existing manual offers (editable)
            ...manualOffers.asMap().entries.map((entry) {
              return OfferInputCard(
                conditionCtrl: entry.value['condition']!,
                rewardCtrl: entry.value['reward']!,
                onRemove: () {
                  entry.value['condition']!.dispose();
                  entry.value['reward']!.dispose();
                  setState(() => manualOffers.removeAt(entry.key));
                },
              );
            }),
          ],
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final auto = autoOffers
                    .map((e) => {'condition': e['condition']!.trim(), 'reward': e['reward']!.trim()})
                    .where((e) => e['condition']!.isNotEmpty || e['reward']!.isNotEmpty)
                    .toList();

                final manual = manualOffers
                    .map((e) => {'condition': e['condition']!.text.trim(), 'reward': e['reward']!.text.trim()})
                    .where((e) => e['condition']!.isNotEmpty || e['reward']!.isNotEmpty)
                    .toList();

                widget.onSave(auto, manual);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A9A5),
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
             child: const Text(
  'ADD OFFERS',
  style: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: Colors.white, // 👈 TEXT COLOR CHANGED TO WHITE
  ),
),
            ),
          ),
          const SizedBox(height: 100), // Safe area for keyboard
        ],
      ),
    );
  }

  Widget _addButton(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Color(0xFF00A9A5), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF00A9A5))),
          ],
        ),
      ),
    );
  }
}

// Reusable drag handle
class _DragHandle extends StatelessWidget {
  const _DragHandle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 5,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.grey[400],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

// Reusable offer input card
class OfferInputCard extends StatelessWidget {
  final TextEditingController conditionCtrl;
  final TextEditingController rewardCtrl;
  final VoidCallback onRemove;

  const OfferInputCard({
    required this.conditionCtrl,
    required this.rewardCtrl,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: conditionCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Donate \$50 or more',
                      labelText: 'Condition',
                                        labelStyle: const TextStyle(
      color: Colors.teal, // 👈 CHANGE LABEL COLOR HERE
      fontWeight: FontWeight.w500,
    ),
                     
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
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: rewardCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Personal thank you video',
                      labelText: 'Reward',
                       labelStyle: const TextStyle(
      color: Colors.teal, // 👈 CHANGE LABEL COLOR HERE
      fontWeight: FontWeight.w500,
    ),
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
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Simple card for displaying auto offers (read-only with delete)
class AutoOfferCard extends StatelessWidget {
  final String condition;
  final String reward;
  final VoidCallback onRemove;

  const AutoOfferCard({required this.condition, required this.reward, required this.onRemove, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: Text(condition, style: const TextStyle(fontWeight: FontWeight.w600))),
                const SizedBox(width: 12),
                Expanded(child: Text(reward, style: const TextStyle(color: Colors.grey))),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Remove', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
