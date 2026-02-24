import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class MoneyInputFormatter extends TextInputFormatter {
  final int maxDecimals;

  MoneyInputFormatter({this.maxDecimals = 2});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    if (newValue.text == '0') {
      return newValue;
    }

    String newText = newValue.text;
    
    // Allow only one decimal point
    if (oldValue.text.contains('.') && newText.split('.').length > 2) {
      return oldValue;
    }

    // Remove all commas
    String cleanText = newText.replaceAll(',', '');

    // Allow digits and a single dot
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(cleanText)) {
      return oldValue;
    }

    // Limit decimal places
    if (cleanText.contains('.')) {
      List<String> parts = cleanText.split('.');
      if (parts.length > 1 && parts[1].length > maxDecimals) {
        return oldValue;
      }
    }

    // Format the number
    String formattedText = _formatNumber(cleanText);

    // Calculate cursor position
    int cursorPosition = _getCursorPosition(newValue, formattedText);

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  String _formatNumber(String s) {
    if (s.isEmpty) return '';
    if (s == '.') return '0.';

    List<String> parts = s.split('.');
    String integerPart = parts[0];
    String decimalPart = parts.length > 1 ? parts[1] : '';

    // Remove leading zeros
    if (integerPart.length > 1 && integerPart.startsWith('0')) {
      integerPart = int.parse(integerPart).toString();
    } else if (integerPart.isEmpty) {
      integerPart = "0";
    }

    // Format with commas using NumberFormat if available, else Regex
    // Using NumberFormat for robustness
    final formatter = NumberFormat("#,###");
    String formattedInteger = formatter.format(int.parse(integerPart));

    if (parts.length > 1 || s.endsWith('.')) {
      return '$formattedInteger.$decimalPart';
    }
    return formattedInteger;
  }

  int _getCursorPosition(TextEditingValue newValue, String formattedText) {
    // Count digits (and dot) before cursor in the new input (unformatted)
    int cursor = newValue.selection.end;
    int significantCharsBeforeCursor = 0;
    
    for (int i = 0; i < cursor && i < newValue.text.length; i++) {
      if (RegExp(r'[0-9.]').hasMatch(newValue.text[i])) {
        significantCharsBeforeCursor++;
      }
    }

    // Find the position in the formatted string where we encounter the same number of significant chars
    int newCursorObj = 0;
    int significantCharsSeen = 0;
    
    for (int i = 0; i < formattedText.length; i++) {
        if (significantCharsSeen >= significantCharsBeforeCursor) {
            break;
        }
        if (RegExp(r'[0-9.]').hasMatch(formattedText[i])) {
            significantCharsSeen++;
        }
        newCursorObj++;
    }
    
    return newCursorObj;
  }
}

