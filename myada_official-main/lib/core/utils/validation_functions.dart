/// Checks if string is email.
bool isValidEmail(
  String? inputString, {
  bool isRequired = false,
}) {
  if (isRequired && (inputString == null || inputString.isEmpty)) {
    return false;
  }
  if (inputString != null && inputString.isNotEmpty) {
    final RegExp emailRegExp = RegExp(
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
    return emailRegExp.hasMatch(inputString);
  }
  return true;
}

/// Checks if string is password.
bool isValidPassword(
  String? inputString, {
  bool isRequired = false,
}) {
  if (isRequired && (inputString == null || inputString.isEmpty)) {
    return false;
  }
  if (inputString != null && inputString.isNotEmpty) {
    // Min 8 characters, at least one letter and one number
    final RegExp passwordRegExp =
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    return passwordRegExp.hasMatch(inputString);
  }
  return true;
}
