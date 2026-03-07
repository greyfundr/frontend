// lib/screens/campaign/modals/edit_budget_modal.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greyfundr/core/models/budget_model.dart';

void showEditBudgetModal(
  BuildContext context,
  List<Expense> currentBudget,
  Function(List<Expense>) onSave,
) {
  List<Expense> temp = List.from(currentBudget);

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
                  Text("Edit Budget", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
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
                    Expense item = e.value;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: Color.fromRGBO(247, 247, 249, 1), borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          Expanded(flex: 3, child: Text(item.name)),
                          Expanded(child: Text("₦${item.cost}", textAlign: TextAlign.right, style: const TextStyle(color: Color.fromRGBO(0, 164, 175, 1), fontWeight: FontWeight.w600))),
                          IconButton(icon: Icon(Icons.delete, color: Colors.red), onPressed: () => setModalState(() => temp.removeAt(i))),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      final nameCtrl = TextEditingController();
                      final costCtrl = TextEditingController();
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Add Item"),
                          content: Column(mainAxisSize: MainAxisSize.min, children: [
                            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Expense")),
                            TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Cost (₦)")),
                          ]),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                            ElevatedButton(
                              onPressed: () {
                                if (nameCtrl.text.isNotEmpty && costCtrl.text.isNotEmpty) {
                                  setModalState(() {
                                    temp.add(Expense(name: nameCtrl.text, cost: double.parse(costCtrl.text)));
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
                    label: const Text("Add Budget Item"),
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
                child: const Text("Save Budget", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}