import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:greyfundr/shared/utils.dart';

class FundraisingTargetSection extends StatelessWidget {
  final TextEditingController controller;

  const FundraisingTargetSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Fundraising Target', 
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 4),
        const Text('How much are you trying to fundraise?', style: TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [NumberTextInputFormatter()], // move formatter to utils if shared
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'e.g. 10,000,000',
                  hintStyle: TextStyle(
      color: Colors.grey[500], // <-- grey hint text
      fontSize: 14,
    ),
            prefixText: '₦ ',
                  prefixStyle: TextStyle(
      color: const Color.fromARGB(255, 77, 77, 77), // <-- grey hint text
      fontSize: 14,
    ),
            filled: true,
            fillColor: Colors.white,
           enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 1.5),
    ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF00A9A5), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
        ),
        const SizedBox(height: 8),

        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            final clean = value.text.replaceAll(',', '');
            final target = clean.isEmpty ? 0.0 : (double.tryParse(clean) ?? 0.0);
            final serviceCharge = target * 0.20;
            final youReceive = target - serviceCharge;

            if (target == 0) {
              return const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('20% service charge will be applied to total amount raised', style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 194, 86, 19))),
              );
            }

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 12, color: Color.fromARGB(255, 103, 103, 103)),
                  children: [
                    const TextSpan(text: 'Fee(20%): '),
                    TextSpan(text: '₦ ${NumberFormat('#,###').format(serviceCharge)}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
                    const TextSpan(text: ' • You will receive: '),
                    TextSpan(text: '₦ ${NumberFormat('#,###').format(youReceive)}', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}