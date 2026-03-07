// lib/screens/campaign/bottom_sheets/expense_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:greyfundr/shared/utils.dart';
import 'package:greyfundr/core/models/budget_model.dart';

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

class ExpenseBottomSheet extends StatefulWidget {
  final List<Expense> expenses;
  final ValueChanged<List<Expense>> onExpensesChanged;

  const ExpenseBottomSheet({
    super.key,
    required this.expenses,
    required this.onExpensesChanged,
  });

  @override
  State<ExpenseBottomSheet> createState() => _ExpenseBottomSheetState();
}

class _ExpenseBottomSheetState extends State<ExpenseBottomSheet> {
  late List<Expense> _localExpenses;
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _costControllers = [];

  @override
  void initState() {
    super.initState();
    _localExpenses = widget.expenses.map((e) => e.copyWith()).toList();
    for (var expense in _localExpenses) {
      _addControllersFor(expense);
    }
  }

  void _addControllersFor(Expense expense) {
    final nameCtrl = TextEditingController(text: expense.name);
    final costCtrl = TextEditingController(
      text: expense.cost > 0 ? NumberFormat('#,###.##').format(expense.cost) : '',
    );

    nameCtrl.addListener(() => expense.name = nameCtrl.text);
    costCtrl.addListener(() {
      final clean = costCtrl.text.replaceAll(',', '');
      final value = double.tryParse(clean) ?? 0;
      expense.cost = value;
      if (value > 0) {
        final formatted = NumberFormat('#,###.##').format(value);
        if (costCtrl.text != formatted) {
          costCtrl.text = formatted;
          costCtrl.selection = TextSelection.fromPosition(TextPosition(offset: costCtrl.text.length));
        }
      }
    });

    _nameControllers.add(nameCtrl);
    _costControllers.add(costCtrl);
  }

  void _addRow() {
    setState(() {
      _localExpenses.add(Expense(name: '', cost: 0));
      _addControllersFor(_localExpenses.last);
    });
  }

  void _removeRow(int index) {
    setState(() {
      _localExpenses.removeAt(index);
      _nameControllers[index].dispose();
      _costControllers[index].dispose();
      _nameControllers.removeAt(index);
      _costControllers.removeAt(index);
    });
  }

  Future<void> _pickFile(int index) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
        withData: true,
      );

     if (!mounted || result == null || result.files.isEmpty) return;

final file = result.files.single;
final ext = file.extension?.toLowerCase();

if (ext == null || !['jpg', 'jpeg', 'png', 'webp', 'pdf'].contains(ext)) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Only images and PDFs allowed')),
  );
  return;
}

setState(() {
  _localExpenses[index].file = file;
});

    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return ClipPath(
          clipper: CurvedTopClipper(),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              top: 20,
              left: 16,
              right: 16,
            ),







            child: ListView(
              controller: scrollController,
              shrinkWrap: true,
              children: [
                 Center(
      child: Container(
        width: 40,
        height: 5,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      
    ),
    

                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    
                    const Text(
                      'Campaign Budget list',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 13, 13, 13)),
                    ),
                    // IconButton(
                    //     icon: const Icon(Icons.close),
                    //     onPressed: () => Navigator.pop(context)),
                  ],
                ),
                
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.45,
                  child: ListView.builder(
                    itemCount: _localExpenses.length,


                    itemBuilder: (_, i) {
  final expense = _localExpenses[i];

  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Expense Name – full width
          TextField(
            controller: _nameControllers[i],
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp(r'[0-9]')),
            ],
            decoration: InputDecoration(
              labelText: 'Expense Name',
              hintText: 'e.g. Hospital Bill, Drugs',
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 2.5),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 1.8),
              ),
              labelStyle: const TextStyle(color: Colors.teal),
              floatingLabelStyle: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. Cost – full width
          TextField(
            controller: _costControllers[i],
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              FilteringTextInputFormatter.singleLineFormatter,
              NumberTextInputFormatter(),
            ],
            decoration: InputDecoration(
              labelText: 'Cost',
              hintText: '0',
              prefixText: '₦ ',
              prefixStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontSize: 15,
              ),
              isDense: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 1.8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 2.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: Colors.teal, width: 1.6),
              ),
              labelStyle: const TextStyle(color: Colors.teal, fontSize: 15),
              floatingLabelStyle: const TextStyle(
                color: Colors.teal,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),

          // 3. Upload button + Delete button in the same row
          Row(
            children: [
              // Upload / File preview
             Expanded(
  child: expense.file == null
      ? FilledButton.icon(
          onPressed: () => _pickFile(i),
          icon: const Icon(Icons.upload_file, size: 18, color: Colors.white),
          label: const Text(
            'Upload Proof',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white, // ensures text is white even if theme changes
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.teal,               // solid teal background
            foregroundColor: Colors.white,              // ripple color
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            minimumSize: const Size(0, 44),
          ),
        )
      : _buildFilePreview(expense),
),

              const SizedBox(width: 12),

              // Delete button
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 28),
                tooltip: 'Delete expense',
                onPressed: () => _removeRow(i),
              ),
            ],
          ),
        ],
      ),
    ),
  );
},
                  ),


                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _addRow,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text(
                    'Add Another Expense',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.teal,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: const BorderSide(color: Colors.teal, width: 1.5),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: () {
                      final valid = _localExpenses
                          .where((e) =>
                              e.name.trim().isNotEmpty && e.cost > 0)
                          .toList();
                      widget.onExpensesChanged(valid);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'FINISHED LISTING',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 70),
              ],
            ),















          ),
        );
      },
    );
  }

  Widget _buildFilePreview(Expense expense) {
    final file = expense.file!;
    final isImage =
        ['jpg', 'jpeg', 'png', 'webp'].contains(file.extension?.toLowerCase());
    final isPdf = file.extension?.toLowerCase() == 'pdf';

    return Container(
      height: 80,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: isImage && file.bytes != null
                ? Image.memory(file.bytes!, width: 64, height: 64, fit: BoxFit.cover)
                : isPdf
                    ? Container(
                        width: 64,
                        height: 64,
                        color: Colors.red.shade50,
                        child: const Icon(Icons.picture_as_pdf,
                            color: Colors.red, size: 36),
                      )
                    : Container(
                        width: 64,
                        height: 64,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.insert_drive_file, size: 36),
                      ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(file.name,
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
