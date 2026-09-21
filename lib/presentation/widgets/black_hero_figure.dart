import 'package:flutter/material.dart';

/// Рисует персонажа как чёрный силуэт через CustomPainter —
/// спрайты/картинки не нужны.
class BlackHeroFigure extends StatelessWidget {
  const BlackHeroFigure({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 90,
      height: 120,
      child: CustomPaint(painter: _HeroPainter()),
    );
  }
}

class _HeroPainter extends CustomPainter {
  const _HeroPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Голова
    canvas.drawCircle(Offset(w / 2, h * 0.15), w * 0.16, paint);

    // Тело
    final bodyPath = Path()
      ..moveTo(w * 0.5, h * 0.28)
      ..lineTo(w * 0.25, h * 0.65)
      ..lineTo(w * 0.35, h * 0.68)
      ..lineTo(w * 0.5, h * 0.45)
      ..lineTo(w * 0.65, h * 0.68)
      ..lineTo(w * 0.75, h * 0.65)
      ..close();
    canvas.drawPath(bodyPath, paint);

    // Ноги
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.32, h * 0.65, w * 0.12, h * 0.32),
        const Radius.circular(4),
      ),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.65, w * 0.12, h * 0.32),
        const Radius.circular(4),
      ),
      paint,
    );

    // "Меч" в руке
    final swordPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(w * 0.78, h * 0.45),
      Offset(w * 0.98, h * 0.15),
      swordPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
