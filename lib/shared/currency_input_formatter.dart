// lib/utils/currency_input_formatter.dart
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If empty, allow clearing the field
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Clean input: remove commas and any unwanted characters
    String cleanText = newValue.text.replaceAll(',', '');

    // Allow only digits and one decimal point
    if (!RegExp(r'^\d*\.?\d{0,2}$').hasMatch(cleanText)) {
      // If invalid (more than one decimal or more than 2 after decimal), revert to old value
      return oldValue;
    }

    // Split into integer and decimal parts
    final parts = cleanText.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    // Format integer part with commas
    final formattedInteger = NumberFormat.decimalPattern('en_US').format(
      int.tryParse(integerPart) ?? 0,
    );

    // Combine with decimal if present
    final formatted = decimalPart.isEmpty
        ? formattedInteger
        : '$formattedInteger.$decimalPart';

    // Calculate new cursor position (accounting for added commas)
    int selectionOffset = newValue.selection.end;
    final addedCommas = formatted.length - cleanText.length;
    selectionOffset += addedCommas;

    // Prevent cursor from going before the number
    selectionOffset = selectionOffset.clamp(0, formatted.length);

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: selectionOffset),
      composing: TextRange.empty,
    );
  }
}