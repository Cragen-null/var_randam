/// 使用回数に応じたランクと機能解放の定義
/// 構想: 段階的に機能が解放されていく構造

class RamdaRank {
  RamdaRank._();

  /// ランク表示名の昇順しきい値（この回数以上でそのランク）
  static const List<int> rankThresholds = [
    0,    // F
    10,   // E-
    100,  // E+
    200,  // D-
    300,  // D
    500,  // D+
    1000, // C-
    5000, // C
    10000, // C+
    20000, // B-
    30000, // B
  ];

  static const List<String> rankNames = [
    'F', 'E-', 'E+', 'D-', 'D', 'D+', 'C-', 'C', 'C+', 'B-', 'B',
  ];

  /// 現在の使用回数に対するランク名
  static String rankNameForCount(int count) {
    int index = 0;
    for (int i = rankThresholds.length - 1; i >= 0; i--) {
      if (count >= rankThresholds[i]) {
        index = i;
        break;
      }
    }
    return rankNames[index];
  }

  /// 次のランクに必要な使用回数（既に最大なら null）
  static int? nextThresholdForCount(int count) {
    for (final t in rankThresholds) {
      if (t > count) return t;
    }
    return null;
  }

  /// 次のランク名（既に最大なら null）
  static String? nextRankNameForCount(int count) {
    final next = nextThresholdForCount(count);
    if (next == null) return null;
    final idx = rankThresholds.indexOf(next);
    return idx >= 0 && idx < rankNames.length ? rankNames[idx] : null;
  }

  // --- 機能解放条件（構想に準拠） ---

  /// Lv1: 設定項目解放（10回で E- と同時）
  static bool isSettingsUnlocked(int count) => count >= 10;

  /// 0～99 の整数を設定可能（100回で E+）
  static bool isRange0_99Unlocked(int count) => count >= 100;

  /// 被りあり/なしを設定可能（200回で D-）
  static bool isDuplicateSettingUnlocked(int count) => count >= 200;

  /// ランダム生成数を 1～5 個に設定可能（300回で D）
  static bool isCount1_5Unlocked(int count) => count >= 300;

  /// -99～99 の範囲を設定可能（500回で D+）
  static bool isRangeMinus99_99Unlocked(int count) => count >= 500;

  /// 3桁まで生成可能（1000回で C-）
  static bool isThreeDigitsUnlocked(int count) => count >= 1000;

  /// 小数点第1位まで扱える（5000回で C）
  static bool isOneDecimalUnlocked(int count) => count >= 5000;

  /// 一度に5セット生成可能（10000回で C+）
  static bool isFiveSetsUnlocked(int count) => count >= 10000;

  /// ランダム生成数を 7個まで設定可能（20000回で B-）
  static bool isCountUpTo7Unlocked(int count) => count >= 20000;

  /// ランダム素数の実装（30000回で B）
  static bool isPrimeUnlocked(int count) => count >= 30000;

  /// 解放条件の説明（設定画面の「○○回で解放」表示用）
  static const Map<String, int> featureCondition = {
    '設定項目': 10,
    '0～99の範囲': 100,
    '被りの有無': 200,
    '生成個数(1～5)': 300,
    '-99～99の範囲': 500,
    '3桁の数': 1000,
    '小数点第1位': 5000,
    '5セット生成': 10000,
    '生成個数(7個まで)': 20000,
    'ランダム素数': 30000,
  };
}
