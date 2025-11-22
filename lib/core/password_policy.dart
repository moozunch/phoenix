class PasswordPolicy {
  // Returns null if valid, otherwise an English error message.
  static String? validate(String password) {
    if (password.length < 8) {
      return 'Password must be at least 8 characters.';
    }
    final upper = RegExp(r'[A-Z]');
    final lower = RegExp(r'[a-z]');
    final digit = RegExp(r'\d');
    final symbol = RegExp(r'[!@#\$%^&*(),.?":{}|<>]');
    if (!upper.hasMatch(password)) {
      return 'Include at least one uppercase letter.';
    }
    if (!lower.hasMatch(password)) {
      return 'Include at least one lowercase letter.';
    }
    if (!digit.hasMatch(password)) {
      return 'Include at least one number.';
    }
    if (!symbol.hasMatch(password)) {
      return 'Include at least one symbol.';
    }
    return null;
  }
}
