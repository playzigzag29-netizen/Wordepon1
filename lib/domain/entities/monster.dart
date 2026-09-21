/// Монстр в бою: имя, эмодзи-спрайт и запас здоровья.
class Monster {
  final String name;
  final String emoji;
  final int maxHp;
  int hp;

  Monster({required this.name, required this.emoji, required this.maxHp})
      : hp = maxHp;
}

/// Стандартная волна монстров, появляющихся по очереди.
List<Monster> buildMonsterWave() => [
      Monster(name: 'ХУЙ', emoji: '𓀓𓂸', maxHp: 1),
      Monster(name: 'SIXSEVEEEEEEEN', emoji: '✞67𒀱67✞', maxHp: 67),
      Monster(name: 'HEREICOMEEE', emoji: '', maxHp: 11),
      Monster(name: 'BRUH', emoji: '𓃟𓍿𓀏', maxHp: 1),
      Monster(name: 'YOURFRIEND', emoji: 'Mikro penis', maxHp: 1),
    ];
