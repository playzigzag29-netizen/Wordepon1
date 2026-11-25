import 'campaign_word_banks.dart';
import 'monster.dart';
import 'word_pair.dart';

enum CampaignStage { forest, desert, city }

extension CampaignStageDetails on CampaignStage {
  String get title => switch (this) {
        CampaignStage.forest => 'Лес',
        CampaignStage.desert => 'Пустыня',
        CampaignStage.city => 'Город',
      };

  String get subtitle => switch (this) {
        CampaignStage.forest => 'Тропа зелёных чащ',
        CampaignStage.desert => 'Путь через пески',
        CampaignStage.city => 'Битва среди небоскрёбов',
      };

  int get enemyCount => switch (this) {
        CampaignStage.forest => 20,
        CampaignStage.desert => 30,
        CampaignStage.city => 35,
      };

  double get damageMultiplier => switch (this) {
        CampaignStage.forest => 0.6,
        CampaignStage.desert => 1,
        CampaignStage.city => 1.8,
      };

  int get enemyHealthGrowth => switch (this) {
        CampaignStage.forest => 2,
        CampaignStage.desert => 4,
        CampaignStage.city => 6,
      };

  MonsterTheme get monsterTheme => switch (this) {
        CampaignStage.forest => MonsterTheme.forest,
        CampaignStage.desert => MonsterTheme.desert,
        CampaignStage.city => MonsterTheme.city,
      };

  List<WordPair> get words => switch (this) {
        CampaignStage.forest => forestWordBank,
        CampaignStage.desert => desertWordBank,
        CampaignStage.city => cityWordBank,
      };

  List<Monster> buildEnemies() {
    final templates = switch (this) {
      CampaignStage.forest => [
          const _MonsterTemplate('Лесной слизень', MonsterAppearance.slime, 12),
          const _MonsterTemplate(
              'Гоблин-разведчик', MonsterAppearance.goblin, 14),
          const _MonsterTemplate(
              'Костяной страж', MonsterAppearance.skeleton, 16),
          const _MonsterTemplate('Корневой тролль', MonsterAppearance.orc, 18),
          const _MonsterTemplate(
              'Древесный дракон', MonsterAppearance.dragon, 20),
        ],
      CampaignStage.desert => [
          const _MonsterTemplate(
              'Песчаный скорпион', MonsterAppearance.slime, 22),
          const _MonsterTemplate('Разбойник дюн', MonsterAppearance.goblin, 24),
          const _MonsterTemplate(
              'Пустынная мумия', MonsterAppearance.skeleton, 26),
          const _MonsterTemplate('Каменный голем', MonsterAppearance.orc, 28),
          const _MonsterTemplate('Песчаный змей', MonsterAppearance.dragon, 30),
        ],
      CampaignStage.city => [
          const _MonsterTemplate('Сбойный дрон', MonsterAppearance.slime, 34),
          const _MonsterTemplate(
              'Уличный налётчик', MonsterAppearance.goblin, 36),
          const _MonsterTemplate(
              'Стальной скелет', MonsterAppearance.skeleton, 38),
          const _MonsterTemplate('Броневой громила', MonsterAppearance.orc, 40),
          const _MonsterTemplate(
              'Механический дракон', MonsterAppearance.dragon, 42),
        ],
    };

    return List.generate(enemyCount, (index) {
      final template = templates[index % templates.length];
      final round = index ~/ templates.length;
      return Monster(
        name: template.name,
        appearance: template.appearance,
        theme: monsterTheme,
        maxHp: template.baseHealth + round * enemyHealthGrowth,
      );
    });
  }
}

class _MonsterTemplate {
  final String name;
  final MonsterAppearance appearance;
  final int baseHealth;

  const _MonsterTemplate(this.name, this.appearance, this.baseHealth);
}
