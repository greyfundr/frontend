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
  final List<Map<String, TextEditingController>> autoOffers = [];
  final List<Map<String, TextEditingController>> manualOffers = [];

  void _addOffer(List<Map<String, TextEditingController>> list) {
    setState(() {
      list.add({
        'condition': TextEditingController(),
        'reward': TextEditingController(),
      });
    });
  }

  @override
  void dispose() {
    for (var offer in [...autoOffers, ...manualOffers]) {
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

          // Auto Offers Section
          const Text('Auto Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('These can be verified automatically in the app', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),

          ...autoOffers.asMap().entries.map((entry) {
            return OfferInputCard(
              conditionCtrl: entry.value['condition']!,
              rewardCtrl: entry.value['reward']!,
              onRemove: () {
                entry.value['condition']!.dispose();
                entry.value['reward']!.dispose();
                setState(() => autoOffers.removeAt(entry.key));
              },
            );
          }),

          _addButton('Add Auto Offer', () => _addOffer(autoOffers)),
          const SizedBox(height: 24),

          // Manual Offers Section
          const Text('Manual Offers', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('You will verify these manually', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 12),

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

          _addButton('Add Manual Offer', () => _addOffer(manualOffers)),
          const SizedBox(height: 32),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final auto = autoOffers
                    .map((e) => {
                          'condition': e['condition']!.text.trim(),
                          'reward': e['reward']!.text.trim(),
                        })
                    .where((e) => e['condition']!.isNotEmpty || e['reward']!.isNotEmpty)
                    .toList();

                final manual = manualOffers
                    .map((e) => {
                          'condition': e['condition']!.text.trim(),
                          'reward': e['reward']!.text.trim(),
                        })
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
