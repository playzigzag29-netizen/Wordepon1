import '../entities/campaign_stage.dart';

abstract class CampaignProgressRepository {
  int get highestUnlockedStageIndex;
  int get towerDefeatedEnemies;

  bool isUnlocked(CampaignStage stage);
  int defeatedEnemies(CampaignStage stage);

  Future<void> load();
  Future<void> unlockNextStage(CampaignStage completedStage);
  Future<void> saveDefeatedEnemies(CampaignStage stage, int count);
  Future<void> saveTowerDefeatedEnemies(int count);
}
