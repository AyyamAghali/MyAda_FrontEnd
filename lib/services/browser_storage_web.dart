import 'dart:html' as html;

class BrowserStorage {
  BrowserStorage._();

  static String? getSessionValue(String key) => html.window.sessionStorage[key];

  static void setSessionValue(String key, String value) {
    html.window.sessionStorage[key] = value;
  }

  static void removeSessionValue(String key) {
    html.window.sessionStorage.remove(key);
  }

  static String? getCookie(String name) {
    final raw = html.document.cookie;
    if (raw == null || raw.isEmpty) return null;

    for (final entry in raw.split(';')) {
      final trimmed = entry.trim();
      if (!trimmed.startsWith('$name=')) continue;
      return Uri.decodeComponent(trimmed.substring(name.length + 1));
    }
    return null;
  }

  static void setCookie(
    String name,
    String value, {
    int maxAgeSeconds = 2592000,
    String path = '/',
    bool secure = true,
    String sameSite = 'Lax',
  }) {
    final encoded = Uri.encodeComponent(value);
    final securePart = secure ? '; Secure' : '';
    html.document.cookie =
        '$name=$encoded; Max-Age=$maxAgeSeconds; Path=$path; SameSite=$sameSite$securePart';
  }

  static void removeCookie(String name, {String path = '/'}) {
    html.document.cookie =
        '$name=; Max-Age=0; Expires=Thu, 01 Jan 1970 00:00:00 GMT; Path=$path';
  }
}
