import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  AppState._(this._prefs, {required bool hasOnboarded, required bool isLoggedIn})
      : _hasOnboarded = hasOnboarded,
        _isLoggedIn = isLoggedIn;

  final SharedPreferences _prefs;

  static const _kHasOnboarded = 'has_onboarded';
  static const _kIsLoggedIn = 'is_logged_in';

  bool _hasOnboarded;
  bool get hasOnboarded => _hasOnboarded;

  bool _isLoggedIn;
  bool get isLoggedIn => _isLoggedIn;

  static AppState? _instance;
  static Future<AppState> create() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool(_kHasOnboarded) ?? false;
    final isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
    _instance = AppState._(prefs, hasOnboarded: hasOnboarded, isLoggedIn: isLoggedIn);
    return _instance!;
  }

  Future<void> setHasOnboarded(bool value) async {
    if (_hasOnboarded == value) return;
    _hasOnboarded = value;
    await _prefs.setBool(_kHasOnboarded, value);
    notifyListeners();
  }

  Future<void> setLoggedIn(bool value) async {
    if (_isLoggedIn == value) return;
    _isLoggedIn = value;
    await _prefs.setBool(_kIsLoggedIn, value);
    notifyListeners();
  }

  Future<void> signOut() async {
    await setLoggedIn(false);
  }
}
