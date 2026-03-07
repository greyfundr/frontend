import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:greyfundr/core/models/participants_model.dart';

void showEditParticipantsModal(
  BuildContext context,
  List<Participant> currentParticipants,
  Function(List<Participant>) onSave,
) {
  List<Participant> temp = List.from(currentParticipants);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (_) => Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: StatefulBuilder(
        builder: (context, setModalState) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Manage Participants", style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: temp.length,
                itemBuilder: (context, i) {
                  final p = temp[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundImage: NetworkImage(p.imageUrl)),
                    title: Text(p.name),
                    subtitle: Text(p.username),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setModalState(() => temp.removeAt(i)),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Add participant coming soon")),
                ),
                icon: const Icon(Icons.person_add),
                label: const Text("Add Participant"),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: Color.fromRGBO(0, 164, 175, 1))),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: ElevatedButton(
                onPressed: () {
                  onSave(temp);
                  Navigator.pop(context);
                },
                child: const Text("Save"),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}