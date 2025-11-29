import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'debug_log.dart';

class AppState extends ChangeNotifier {
      String? _reminderTime;
      String? get reminderTime => _reminderTime;
      Future<void> setReminderTime(String value) async {
        _reminderTime = value;
        notifyListeners();
      }

      String? _routine;
      String? get routine => _routine;
      Future<void> setRoutine(String value) async {
        _routine = value;
        notifyListeners();
      }
    // Returns true if the current user's email is verified
    bool get emailVerified => FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    Future<void> refreshEmailStatus() async {
    await FirebaseAuth.instance.currentUser?.reload();
    notifyListeners();
  }

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
    if (isNewUser) {
    } else {
    }
    _instance = AppState._(prefs, hasOnboarded: hasOnboarded, isLoggedIn: isLoggedIn, isNewUser: isNewUser);
    return _instance!;
  }

  void _attachAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      final newVal = user != null;

      // Prevent auto-login routing for new users (still verifying email)
      if (_isNewUser && user != null) {
        return;
      }

      if (newVal != _isLoggedIn) {
        _isLoggedIn = newVal;
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
    notifyListeners();
  }
}
