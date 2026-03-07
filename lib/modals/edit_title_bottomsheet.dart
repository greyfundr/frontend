// lib/screens/campaign/modals/edit_title_bottomsheet.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

void showEditTitleBottomSheet(
  BuildContext context,
  String currentTitle,
  Function(String) onSave,
) {
  final controller = TextEditingController(text: currentTitle);
  final focusNode = FocusNode();

  WidgetsBinding.instance.addPostFrameCallback((_) => focusNode.requestFocus());

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.transparent,
    clipBehavior: Clip.antiAlias,
    builder: (context) {
      return ClipPath(
        clipper: CurvedTopClipper(),
        child: Container(
          color: Colors.white,
          // This makes the bottom sheet taller – adjust fraction as needed
          height: MediaQuery.of(context).size.height * 0.70, // Takes 70% of screen height
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 50, // Space for the curve
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Still allows content to shrink if needed
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Campaign Title",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _saveAndClose(context, controller, onSave),
                  decoration: InputDecoration(
                    hintText: "Enter new title",
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(0, 164, 175, 1),
                        width: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          "Cancel",
                          style: GoogleFonts.inter(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _saveAndClose(context, controller, onSave),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromRGBO(0, 164, 175, 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "Save",
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Optional: Add extra space at the bottom to fill the taller sheet
                const Spacer(), // Pushes content to top, adds empty space below
              ],
            ),
          ),
        ),
      );
    },
  ).whenComplete(() {
    controller.dispose();
    focusNode.dispose();
  });
}

void _saveAndClose(
  BuildContext context,
  TextEditingController controller,
  Function(String) onSave,
) {
  final text = controller.text.trim();
  if (text.isNotEmpty) {
    onSave(text);
  }
  Navigator.pop(context);
}