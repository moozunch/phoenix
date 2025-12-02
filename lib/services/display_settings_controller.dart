import 'package:flutter/foundation.dart';
import 'display_settings_service.dart';

class DisplaySettingsController {
  // ValueNotifiers untuk realtime update
  static final ValueNotifier<bool> startSunday = ValueNotifier<bool>(true);
  static final ValueNotifier<bool> addFromTop = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> show24Hour = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> showSmallPhoto = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> showSmallMemo = ValueNotifier<bool>(false);
  static final ValueNotifier<bool> theme = ValueNotifier<bool>(false); // false = light, true = dark

  // Panggil sekali di main() sebelum runApp
  static Future<void> init() async {
    startSunday.value = await DisplaySettingsService.loadBool(
      DisplaySettingsService.startSundayKey,
      defaultValue: true,
    );
    addFromTop.value = await DisplaySettingsService.loadBool(
      DisplaySettingsService.addFromTopKey,
    );
    show24Hour.value = await DisplaySettingsService.loadBool(
      DisplaySettingsService.show24HourKey,
    );
    showSmallPhoto.value = await DisplaySettingsService.loadBool(
      DisplaySettingsService.showSmallPhotoKey,
    );
    showSmallMemo.value = await DisplaySettingsService.loadBool(
      DisplaySettingsService.showSmallMemoKey,
    );
    theme.value = await DisplaySettingsService.loadBool(
      DisplaySettingsService.themeKey,
    );
  }

  // Helper: update both notifier & SharedPreferences
  static Future<void> updateStartSunday(bool v) async {
    startSunday.value = v;
    await DisplaySettingsService.saveBool(DisplaySettingsService.startSundayKey, v);
  }

  static Future<void> updateAddFromTop(bool v) async {
    addFromTop.value = v;
    await DisplaySettingsService.saveBool(DisplaySettingsService.addFromTopKey, v);
  }

  static Future<void> updateShow24Hour(bool v) async {
    show24Hour.value = v;
    await DisplaySettingsService.saveBool(DisplaySettingsService.show24HourKey, v);
  }

  static Future<void> updateShowSmallPhoto(bool v) async {
    showSmallPhoto.value = v;
    await DisplaySettingsService.saveBool(DisplaySettingsService.showSmallPhotoKey, v);
  }

  static Future<void> updateShowSmallMemo(bool v) async {
    showSmallMemo.value = v;
    await DisplaySettingsService.saveBool(DisplaySettingsService.showSmallMemoKey, v);
  }

  static Future<void> updateTheme(bool v) async {
    theme.value = v;
    await DisplaySettingsService.saveBool(DisplaySettingsService.themeKey, v);
  }
}
