import 'package:flutter_test/flutter_test.dart';
import 'package:word_fighter/domain/services/speed_damage_calculator.dart';

void main() {
  group('damageWithSpeedBonus', () {
    test('doubles base damage for an immediate answer', () {
      expect(
        damageWithSpeedBonus(
          baseDamage: 12,
          answerTime: Duration.zero,
        ),
        24,
      );
    });

    test('grants half of the maximum bonus after five seconds', () {
      expect(
        damageWithSpeedBonus(
          baseDamage: 12,
          answerTime: const Duration(seconds: 5),
        ),
        18,
      );
    });

    test('returns base damage after the ten-second bonus window', () {
      expect(
        damageWithSpeedBonus(
          baseDamage: 12,
          answerTime: const Duration(seconds: 10),
        ),
        12,
      );
      expect(
        damageWithSpeedBonus(
          baseDamage: 12,
          answerTime: const Duration(seconds: 15),
        ),
        12,
      );
    });
  });
}
