import 'package:flutter/services.dart';

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow backspace
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    StringBuffer newText = StringBuffer();

    // Insert `:` after the first two digits if not already present
    for (int i = 0; i < text.length; i++) {
      if (i == 2 && !text.contains(':')) {
        newText.write(':');
      }
      newText.write(text[i]);
    }

    // Enforce maximum length (5 characters -> HH:mm)
    if (newText.length > 5) {
      newText = StringBuffer(newText.toString().substring(0, 5));
    }

    return TextEditingValue(
      text: newText.toString(),
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
