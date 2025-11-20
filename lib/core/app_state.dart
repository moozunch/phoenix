import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'debug_log.dart';

class AppState extends ChangeNotifier {
  AppState._(
      this._prefs, {
        required bool hasOnboarded,
        required bool isLoggedIn,
        required bool isNewUser,
      })  : _hasOnboarded = hasOnboarded,
        _isLoggedIn = isLoggedIn,
        _isNewUser = isNewUser;

  final SharedPreferences _prefs;

  static const _kHasOnboarded = 'has_onboarded';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kIsNewUser = 'is_new_user';

  bool _hasOnboarded;
  bool get hasOnboarded => _hasOnboarded;

  bool _isLoggedIn;
  bool get isLoggedIn => _isLoggedIn;

  bool _isNewUser;
  bool get isNewUser => _isNewUser;

  static AppState? _instance;
  static Future<AppState> create() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool(_kHasOnboarded) ?? false;
    final isLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
    final isNewUser = prefs.getBool(_kIsNewUser) ?? false;
    _instance = AppState._(prefs, hasOnboarded: hasOnboarded, isLoggedIn: isLoggedIn,  isNewUser: isNewUser,);
    DebugLog.d('AppState', 'Loaded prefs => hasOnboarded=$hasOnboarded, isLoggedIn=$isLoggedIn, isNewUser=$isNewUser');
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

  Future<void> setIsNewUser(bool value) async {
    if (_isNewUser == value) return;
    _isNewUser = value;
    await _prefs.setBool(_kIsNewUser, value);
    DebugLog.d('AppState', 'setIsNewUser($value)');
    notifyListeners();
  }
}
