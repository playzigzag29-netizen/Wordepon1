/// Сложность игры влияет на урон, наносимый монстрами.
enum Difficulty { easy, normal, hard }

extension DifficultyX on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy:
        return 'Лёгкая';
      case Difficulty.normal:
        return 'Средняя';
      case Difficulty.hard:
        return 'Сложная';
    }
  }

  /// Множитель урона по игроку при неверном ответе.
  double get damageMultiplier {
    switch (this) {
      case Difficulty.easy:
        return 0.6;
      case Difficulty.normal:
        return 1.0;
      case Difficulty.hard:
        return 1.8;
    }
  }
}
