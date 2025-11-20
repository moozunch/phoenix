import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'debug_log.dart';

class AppState extends ChangeNotifier {
  AppState._(
    this._prefs, {
    required bool hasOnboarded,
    required bool isLoggedIn,
    required bool isNewUser,
  })  : _hasOnboarded = hasOnboarded,
        _isLoggedIn = isLoggedIn,
        _isNewUser = isNewUser {
    _attachAuthListener();
  }

  final SharedPreferences _prefs;

  static const _kHasOnboarded = 'has_onboarded';
  static const _kIsLoggedIn = 'is_logged_in';
  static const _kIsNewUser = 'is_new_user';

  bool _hasOnboarded;
  bool get hasOnboarded => _hasOnboarded;

  bool _isLoggedIn;
  bool get isLoggedIn => _isLoggedIn; // Backed by FirebaseAuth listener; persistence deprecated.

  bool _isNewUser;
  bool get isNewUser => _isNewUser;

  static AppState? _instance;
  static Future<AppState> create() async {
    if (_instance != null) return _instance!;
    final prefs = await SharedPreferences.getInstance();
    final hasOnboarded = prefs.getBool(_kHasOnboarded) ?? false;
    // Deprecated persisted login flag replaced by FirebaseAuth currentUser
    final persistedLoggedIn = prefs.getBool(_kIsLoggedIn) ?? false;
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLoggedIn = currentUser != null; // authoritative source
    final isNewUser = prefs.getBool(_kIsNewUser) ?? false;
    _instance = AppState._(prefs, hasOnboarded: hasOnboarded, isLoggedIn: isLoggedIn, isNewUser: isNewUser);
    DebugLog.d('AppState', 'Loaded prefs => hasOnboarded=$hasOnboarded, persistedLoggedIn=$persistedLoggedIn, authLoggedIn=$isLoggedIn, isNewUser=$isNewUser');
    return _instance!;
  }

  void _attachAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      final newVal = user != null;
      if (newVal != _isLoggedIn) {
        _isLoggedIn = newVal;
        DebugLog.d('AppState', 'AuthStateChanged => isLoggedIn=$newVal');
        // Do not persist login state anymore (deprecated); keep prefs key for backward compatibility if needed.
        notifyListeners();
      }
    });
  }

  Future<void> setHasOnboarded(bool value) async {
    if (_hasOnboarded == value) return;
    _hasOnboarded = value;
    await _prefs.setBool(_kHasOnboarded, value);
    notifyListeners();
  }

  Future<void> setLoggedIn(bool value) async {
    // Deprecated manual login flag setter; FirebaseAuth listener drives state.
    DebugLog.d('AppState', 'setLoggedIn($value) deprecated - no direct effect');
    // For backward compatibility we still update persisted key (optional).
    await _prefs.setBool(_kIsLoggedIn, value);
    // Do not mutate _isLoggedIn; await auth event instead.
    notifyListeners();
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } finally {
      // Listener will update state; we also mark persisted key.
      await _prefs.setBool(_kIsLoggedIn, false);
      notifyListeners();
    }
  }

  Future<void> setIsNewUser(bool value) async {
    if (_isNewUser == value) return;
    _isNewUser = value;
    await _prefs.setBool(_kIsNewUser, value);
    DebugLog.d('AppState', 'setIsNewUser($value)');
    notifyListeners();
  }
}
