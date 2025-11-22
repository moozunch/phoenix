/// Simple opt-in debug logger for development.
class DebugLog {
  // Toggle this to false (or gate with kDebugMode) before release.
  static bool enabled = true;

  static void d(String tag, String message) {
    if (!enabled) return;
    // ignore: avoid_print
    print('[DEBUG][$tag] $message');
  }
}
