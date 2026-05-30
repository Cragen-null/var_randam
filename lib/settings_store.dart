import 'package:shared_preferences/shared_preferences.dart';

/// 解放された機能のON/OFF設定を永続化するキーとデフォルト値
class SettingsStore {
  SettingsStore._();

  // 各機能のSharedPreferencesキー（OFF = 未使用、ON = その機能を有効にしている）
  static const String keyRange0_99 = 'ramda_setting_range_0_99';
  static const String keyAllowDuplicate = 'ramda_setting_allow_duplicate';
  static const String keyCount1_5 = 'ramda_setting_count_1_5';
  static const String keyRangeMinus99_99 = 'ramda_setting_range_minus99_99';
  static const String keyThreeDigits = 'ramda_setting_three_digits';
  static const String keyOneDecimal = 'ramda_setting_one_decimal';
  static const String keyFiveSets = 'ramda_setting_five_sets';
  static const String keyCount7 = 'ramda_setting_count_7';
  static const String keyPrime = 'ramda_setting_prime';

  static Future<bool> getBool(SharedPreferences prefs, String key,
      {bool defaultValue = false}) async {
    return prefs.getBool(key) ?? defaultValue;
  }

  static Future<void> setBool(
      SharedPreferences prefs, String key, bool value) async {
    await prefs.setBool(key, value);
  }
}
