import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:word_fighter/data/repositories/campaign_progress_repository_impl.dart';
import 'package:word_fighter/domain/entities/campaign_stage.dart';

void main() {
  late CampaignProgressRepositoryImpl repository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    repository = CampaignProgressRepositoryImpl.instance;
    repository.debugReset();
  });

  test('starts with only the Forest unlocked and unlocks stages in order',
      () async {
    await repository.load();

    expect(repository.isUnlocked(CampaignStage.forest), isTrue);
    expect(repository.isUnlocked(CampaignStage.desert), isFalse);
    expect(repository.isUnlocked(CampaignStage.city), isFalse);

    await repository.unlockNextStage(CampaignStage.desert);
    expect(repository.isUnlocked(CampaignStage.desert), isFalse);

    await repository.unlockNextStage(CampaignStage.forest);
    expect(repository.isUnlocked(CampaignStage.desert), isTrue);
    expect(repository.isUnlocked(CampaignStage.city), isFalse);

    await repository.unlockNextStage(CampaignStage.desert);
    expect(repository.isUnlocked(CampaignStage.city), isTrue);
  });

  test('keeps unlocked stages after reload', () async {
    await repository.load();
    await repository.unlockNextStage(CampaignStage.forest);

    repository.debugReset();
    await repository.load();

    expect(repository.isUnlocked(CampaignStage.desert), isTrue);
    expect(repository.isUnlocked(CampaignStage.city), isFalse);
  });

  test('saves defeated counts for campaign stages and the tower', () async {
    await repository.load();
    await repository.saveDefeatedEnemies(CampaignStage.forest, 7);
    await repository.saveTowerDefeatedEnemies(13);

    repository.debugReset();
    await repository.load();

    expect(repository.defeatedEnemies(CampaignStage.forest), 7);
    expect(repository.towerDefeatedEnemies, 13);

    await repository.unlockNextStage(CampaignStage.forest);
    expect(repository.defeatedEnemies(CampaignStage.forest), 0);
  });
}
