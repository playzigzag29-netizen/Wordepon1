const speedDamageBonusWindow = Duration(seconds: 10);

int damageWithSpeedBonus({
  required int baseDamage,
  required Duration answerTime,
}) {
  final remainingTime =
      (speedDamageBonusWindow.inMilliseconds - answerTime.inMilliseconds)
          .clamp(0, speedDamageBonusWindow.inMilliseconds);
  final bonusDamage =
      (baseDamage * remainingTime / speedDamageBonusWindow.inMilliseconds)
          .round();
  return baseDamage + bonusDamage;
}
