import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ramda_rank.dart';
import 'settings_store.dart';

/// 解放条件と設定キーの対応（設定項目解放はON/OFF対象外）
final List<({String label, int condition, String prefsKey})> _featureConfig = [
  (label: '0～99の整数を設定', condition: 100, prefsKey: SettingsStore.keyRange0_99),
  (label: '被りの有無を設定', condition: 200, prefsKey: SettingsStore.keyAllowDuplicate),
  (label: '生成個数（1～5個）', condition: 300, prefsKey: SettingsStore.keyCount1_5),
  (label: '-99～99の範囲を設定', condition: 500, prefsKey: SettingsStore.keyRangeMinus99_99),
  (label: '3桁まで生成', condition: 1000, prefsKey: SettingsStore.keyThreeDigits),
  (label: '小数点第1位まで', condition: 5000, prefsKey: SettingsStore.keyOneDecimal),
  (label: '一度に5セット生成', condition: 10000, prefsKey: SettingsStore.keyFiveSets),
  (label: '生成個数（7個まで）', condition: 20000, prefsKey: SettingsStore.keyCount7),
  (label: 'ランダム素数', condition: 30000, prefsKey: SettingsStore.keyPrime),
];

/// 使用回数に応じた機能解放状況を表示し、解放済み機能のON/OFFができる設定画面
class SettingsPage extends StatefulWidget {
  const SettingsPage({
    super.key,
    required this.generateCount,
  });

  final int generateCount;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? _prefs;
  final Map<String, bool> _settings = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, bool>{};
    for (final f in _featureConfig) {
      map[f.prefsKey] = await SettingsStore.getBool(prefs, f.prefsKey);
    }
    if (mounted) {
      setState(() {
        _prefs = prefs;
        _settings.addAll(map);
        _loading = false;
      });
    }
  }

  Future<void> _setSetting(String key, bool value) async {
    final prefs = _prefs;
    if (prefs == null) return;
    await SettingsStore.setBool(prefs, key, value);
    if (mounted) setState(() => _settings[key] = value);
  }

  @override
  Widget build(BuildContext context) {
    final generateCount = widget.generateCount;
    final rank = RamdaRank.rankNameForCount(generateCount);
    final nextThreshold = RamdaRank.nextThresholdForCount(generateCount);
    final nextRank = RamdaRank.nextRankNameForCount(generateCount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定・解放状況'),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 現在のランク
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '現在のランク',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: Colors.grey,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              rank,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '（$generateCount 回使用）',
                              style:
                                  Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.grey,
                                      ),
                            ),
                          ],
                        ),
                        if (nextThreshold != null && nextRank != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '次: $nextRank まであと ${nextThreshold - generateCount} 回',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.indigo,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  '機能解放一覧',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                // 設定項目解放はON/OFFなし（解放表示のみ）
                _FeatureRow(
                  label: '設定項目解放',
                  condition: 10,
                  count: generateCount,
                ),
                // 解放済み機能はスイッチ付き
                ..._featureConfig.map((f) {
                  final unlocked = generateCount >= f.condition;
                  if (unlocked) {
                    return _FeatureRowWithSwitch(
                      label: f.label,
                      condition: f.condition,
                      count: generateCount,
                      value: _settings[f.prefsKey] ?? false,
                      onChanged: (v) => _setSetting(f.prefsKey, v),
                    );
                  }
                  return _FeatureRow(
                    label: f.label,
                    condition: f.condition,
                    count: generateCount,
                  );
                }),
              ],
            ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.label,
    required this.condition,
    required this.count,
  });

  final String label;
  final int condition;
  final int count;

  @override
  Widget build(BuildContext context) {
    final unlocked = count >= condition;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            unlocked ? Icons.check_circle : Icons.lock_outline,
            size: 20,
            color: unlocked ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: unlocked ? null : Colors.grey,
                fontWeight: unlocked ? FontWeight.w500 : null,
              ),
            ),
          ),
          Text(
            unlocked ? '解放済み' : '${condition}回で解放',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: unlocked ? Colors.green : Colors.grey,
                ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRowWithSwitch extends StatelessWidget {
  const _FeatureRowWithSwitch({
    required this.label,
    required this.condition,
    required this.count,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int condition;
  final int count;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 20,
            color: Colors.green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${value ? "ON" : "OFF"}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: value ? Colors.green : Colors.grey,
                ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
