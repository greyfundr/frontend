// lib/screens/campaign/modals/edit_offers_modal.dart
import 'package:flutter/material.dart';
import 'package:greyfundr/shared/text_style.dart';
 
void showEditOffersModal(
  BuildContext context,
  List<Map<String, String>> currentOffers,
  Function(List<Map<String, String>>) onSave,
) {
  List<Map<String, String>> temp = List.from(currentOffers);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: StatefulBuilder(
        builder: (context, setModalState) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit Offers", style: txStyle20.copyWith(fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ...temp.asMap().entries.map((e) {
                    int i = e.key;
                    var offer = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 249, 1), borderRadius: BorderRadius.circular(8)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Expanded(child: Text("Condition: ${offer['condition'] ?? ''}")),
                          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setModalState(() => temp.removeAt(i))),
                        ]),
                        Text("Reward: ${offer['reward'] ?? ''}", style: TextStyle(color: Color.fromRGBO(0, 164, 175, 1))),
                      ]),
                    );
                  }).toList(),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      final condCtrl = TextEditingController();
                      final rewardCtrl = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Add Offer"),
                          content: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextField(controller: condCtrl, decoration: const InputDecoration(labelText: "Condition")),
                            TextField(controller: rewardCtrl, decoration: const InputDecoration(labelText: "Reward")),
                          ]),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                            ElevatedButton(
                              onPressed: () {
                                if (condCtrl.text.isNotEmpty && rewardCtrl.text.isNotEmpty) {
                                  setModalState(() {
                                    temp.add({'condition': condCtrl.text, 'reward': rewardCtrl.text, 'type': 'manual'});
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text("Add Offer"),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () {
                  onSave(temp);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromRGBO(0, 164, 175, 1), minimumSize: const Size(double.infinity, 56)),
                child: const Text("Save Offers", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}