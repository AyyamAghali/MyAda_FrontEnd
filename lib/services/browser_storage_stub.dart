class BrowserStorage {
  BrowserStorage._();

  static final Map<String, String> _session = <String, String>{};
  static final Map<String, String> _cookies = <String, String>{};

  static String? getSessionValue(String key) => _session[key];

  static void setSessionValue(String key, String value) {
    _session[key] = value;
  }

  static void removeSessionValue(String key) {
    _session.remove(key);
  }

  static String? getCookie(String name) => _cookies[name];

  static void setCookie(
    String name,
    String value, {
    int maxAgeSeconds = 2592000,
    String path = '/',
    bool secure = true,
    String sameSite = 'Lax',
  }) {
    _cookies[name] = value;
  }

  static void removeCookie(String name, {String path = '/'}) {
    _cookies.remove(name);
  }
}
