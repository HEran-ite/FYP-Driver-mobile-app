library;

import 'dart:convert';

/// Client-side JWT expiry check (signature not verified — same as reading [exp] in DevTools).
/// Returns [false] for opaque/non-JWT tokens so the server remains the source of truth.
bool isJwtExpired(
  String? token, {
  Duration clockSkew = const Duration(seconds: 30),
}) {
  if (token == null || token.isEmpty) return true;
  final parts = token.split('.');
  if (parts.length != 3) return false;
  try {
    final bytes = _decodeBase64Url(parts[1]);
    final payload = jsonDecode(utf8.decode(bytes));
    if (payload is! Map) return false;
    final exp = payload['exp'];
    if (exp is! num) return false;
    final expiryMs = (exp * 1000).round();
    final now = DateTime.now().millisecondsSinceEpoch;
    return now >= expiryMs - clockSkew.inMilliseconds;
  } catch (_) {
    return false;
  }
}

List<int> _decodeBase64Url(String input) {
  var s = input.replaceAll('-', '+').replaceAll('_', '/');
  switch (s.length % 4) {
    case 2:
      s += '==';
      break;
    case 3:
      s += '=';
      break;
  }
  return base64.decode(s);
}
