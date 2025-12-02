import 'package:shared_preferences/shared_preferences.dart';

class DisplaySettingsService {
  static const String _startSundayKey = "startSunday";
  static const String _addFromTopKey = "addFromTop";
  static const String _show24HourKey = "show24Hour";
  static const String _showSmallPhotoKey = "showSmallPhoto";
  static const String _showSmallMemoKey = "showSmallMemo";
  static const String _themeKey = "theme";


  static String get startSundayKey => _startSundayKey;
  static String get addFromTopKey => _addFromTopKey;
  static String get show24HourKey => _show24HourKey;
  static String get showSmallPhotoKey => _showSmallPhotoKey;
  static String get showSmallMemoKey => _showSmallMemoKey;
  static String get themeKey => _themeKey;

  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // LOAD
  static Future<bool> loadBool(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
}
