/// Вариант рисованного облика монстра.
enum MonsterAppearance { slime, goblin, skeleton, orc, dragon }

enum MonsterTheme { forest, desert, city, tower }

/// Монстр в бою: имя, облик и запас здоровья.
class Monster {
  final String name;
  final MonsterAppearance appearance;
  final MonsterTheme theme;
  final int maxHp;
  int hp;

  Monster({
    required this.name,
    required this.appearance,
    required this.theme,
    required this.maxHp,
  }) : hp = maxHp;
}

List<Monster> buildTowerWave(int round) => [
      Monster(
        name: 'Слизень-ученик',
        appearance: MonsterAppearance.slime,
        theme: MonsterTheme.tower,
        maxHp: 18 + round * 4,
      ),
      Monster(
        name: 'Гоблин-переписчик',
        appearance: MonsterAppearance.goblin,
        theme: MonsterTheme.tower,
        maxHp: 22 + round * 4,
      ),
      Monster(
        name: 'Костяной маг',
        appearance: MonsterAppearance.skeleton,
        theme: MonsterTheme.tower,
        maxHp: 26 + round * 4,
      ),
      Monster(
        name: 'Голем-хранитель',
        appearance: MonsterAppearance.orc,
        theme: MonsterTheme.tower,
        maxHp: 30 + round * 4,
      ),
      Monster(
        name: 'Дракон башни',
        appearance: MonsterAppearance.dragon,
        theme: MonsterTheme.tower,
        maxHp: 34 + round * 4,
      ),
    ];
