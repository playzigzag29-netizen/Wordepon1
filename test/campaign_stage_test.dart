import 'package:flutter_test/flutter_test.dart';
import 'package:word_fighter/domain/entities/campaign_stage.dart';

void main() {
  test('campaign stages have the requested enemy and vocabulary counts', () {
    expect(
      CampaignStage.values.map((stage) => stage.enemyCount).toList(),
      [20, 30, 35],
    );
    expect(
      CampaignStage.values.map((stage) => stage.words.length).toList(),
      [50, 100, 100],
    );
  });

  test('each campaign stage creates a full themed enemy roster', () {
    for (final stage in CampaignStage.values) {
      final enemies = stage.buildEnemies();
      expect(enemies, hasLength(stage.enemyCount));
      expect(
          enemies.every((enemy) => enemy.theme == stage.monsterTheme), isTrue);
      expect(enemies.map((enemy) => enemy.name).toSet().length, greaterThan(1));
    }
  });
}
