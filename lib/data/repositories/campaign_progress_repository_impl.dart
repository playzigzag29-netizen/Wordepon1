import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/campaign_stage.dart';
import '../../domain/repositories/campaign_progress_repository.dart';

class CampaignProgressRepositoryImpl implements CampaignProgressRepository {
  CampaignProgressRepositoryImpl._();

  static final CampaignProgressRepositoryImpl instance =
      CampaignProgressRepositoryImpl._();

  static const _highestUnlockedStageKey = 'campaign_highest_unlocked_stage';
  static const _towerDefeatedEnemiesKey = 'tower_defeated_enemies';

  int _highestUnlockedStageIndex = CampaignStage.forest.index;
  int _towerDefeatedEnemies = 0;
  final Map<CampaignStage, int> _defeatedEnemies = {};
  bool _loaded = false;

  @override
  int get highestUnlockedStageIndex => _highestUnlockedStageIndex;

  @override
  int get towerDefeatedEnemies => _towerDefeatedEnemies;

  @override
  bool isUnlocked(CampaignStage stage) =>
      stage.index <= _highestUnlockedStageIndex;

  @override
  int defeatedEnemies(CampaignStage stage) => _defeatedEnemies[stage] ?? 0;

  @override
  Future<void> load() async {
    if (_loaded) return;
    final preferences = await SharedPreferences.getInstance();
    final savedIndex = preferences.getInt(_highestUnlockedStageKey) ??
        CampaignStage.forest.index;
    _highestUnlockedStageIndex =
        savedIndex.clamp(0, CampaignStage.values.length - 1).toInt();
    _towerDefeatedEnemies = (preferences.getInt(_towerDefeatedEnemiesKey) ?? 0)
        .clamp(0, 1 << 30)
        .toInt();
    for (final stage in CampaignStage.values) {
      final savedCount =
          preferences.getInt(_stageDefeatedEnemiesKey(stage)) ?? 0;
      _defeatedEnemies[stage] =
          savedCount.clamp(0, stage.enemyCount - 1).toInt();
    }
    _loaded = true;
  }

  @override
  Future<void> unlockNextStage(CampaignStage completedStage) async {
    final preferences = await SharedPreferences.getInstance();
    if (completedStage.index == _highestUnlockedStageIndex &&
        completedStage.index < CampaignStage.values.length - 1) {
      final nextStageIndex = completedStage.index + 1;
      await preferences.setInt(_highestUnlockedStageKey, nextStageIndex);
      _highestUnlockedStageIndex = nextStageIndex;
    }
    await preferences.remove(_stageDefeatedEnemiesKey(completedStage));
    _defeatedEnemies[completedStage] = 0;
  }

  @override
  Future<void> saveDefeatedEnemies(CampaignStage stage, int count) async {
    final savedCount = count.clamp(0, stage.enemyCount - 1).toInt();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_stageDefeatedEnemiesKey(stage), savedCount);
    _defeatedEnemies[stage] = savedCount;
  }

  @override
  Future<void> saveTowerDefeatedEnemies(int count) async {
    final savedCount = count.clamp(0, 1 << 30).toInt();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_towerDefeatedEnemiesKey, savedCount);
    _towerDefeatedEnemies = savedCount;
  }

  void debugReset() {
    _highestUnlockedStageIndex = CampaignStage.forest.index;
    _towerDefeatedEnemies = 0;
    _defeatedEnemies.clear();
    _loaded = false;
  }

  String _stageDefeatedEnemiesKey(CampaignStage stage) =>
      'campaign_${stage.name}_defeated_enemies';
}
