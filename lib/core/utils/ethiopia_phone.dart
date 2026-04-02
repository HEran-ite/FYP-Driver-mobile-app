library;

import 'package:flutter/services.dart';

/// Normalizes Ethiopian mobile input for the API.
///
/// Accepts common forms: `+251 9X XXX XXXX`, `2519XXXXXXXX`, `09XXXXXXXX`.
/// Returns E.164-style `+251` + 9-digit mobile (starting with 9), or null if invalid.
String? normalizeEthiopiaPhone(String raw) {
  final t = raw.trim();
  if (t.isEmpty) return null;

  final digits = t.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;

  String? nsn;

  if (digits.startsWith('251')) {
    final rest = digits.substring(3);
    if (rest.length == 9 && rest.startsWith('9')) nsn = rest;
  } else if (digits.startsWith('09') && digits.length == 10) {
    nsn = digits.substring(1);
  } else if (digits.length == 9 && digits.startsWith('9')) {
    nsn = digits;
  }

  if (nsn == null) return null;
  return '+251$nsn';
}

/// True if [raw] can be normalized to a valid Ethiopia mobile.
bool isValidEthiopiaPhone(String raw) => normalizeEthiopiaPhone(raw) != null;

/// Allows `+`, digits, and spaces only (typical phone typing).
class EthiopiaPhoneInputFormatter extends TextInputFormatter {
  const EthiopiaPhoneInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final t = newValue.text;
    if (t.isEmpty) return newValue;
    if (!RegExp(r'^[\d+ ]*$').hasMatch(t)) {
      return oldValue;
    }
    if (t.contains('+') && t.indexOf('+') != 0) {
      return oldValue;
    }
    if (RegExp(r'\+').allMatches(t).length > 1) {
      return oldValue;
    }
    if (t.length > 18) {
      return oldValue;
    }
    return newValue;
  }
}
