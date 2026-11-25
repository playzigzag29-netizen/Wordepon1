import 'package:flutter/material.dart';

import '../../domain/entities/monster.dart';

class MonsterFigure extends StatelessWidget {
  final MonsterAppearance appearance;
  final MonsterTheme theme;

  const MonsterFigure({
    super.key,
    required this.appearance,
    this.theme = MonsterTheme.forest,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 120,
      child: CustomPaint(painter: _MonsterPainter(appearance, theme)),
    );
  }
}

class _MonsterPainter extends CustomPainter {
  final MonsterAppearance appearance;
  final MonsterTheme theme;

  const _MonsterPainter(this.appearance, this.theme);

  Color get _creatureColor => switch (theme) {
        MonsterTheme.forest => const Color(0xFF55D68B),
        MonsterTheme.desert => const Color(0xFFD49A45),
        MonsterTheme.city => const Color(0xFF6886A3),
        MonsterTheme.tower => const Color(0xFF8255DD),
      };

  Color get _secondaryColor => switch (theme) {
        MonsterTheme.forest => const Color(0xFF375E42),
        MonsterTheme.desert => const Color(0xFF765035),
        MonsterTheme.city => const Color(0xFF35465B),
        MonsterTheme.tower => const Color(0xFF51358F),
      };

  Color get _boneColor => switch (theme) {
        MonsterTheme.forest => const Color(0xFFE2D9C5),
        MonsterTheme.desert => const Color(0xFFEAD4A5),
        MonsterTheme.city => const Color(0xFFD8E1EA),
        MonsterTheme.tower => const Color(0xFFE0D4F5),
      };

  @override
  void paint(Canvas canvas, Size size) {
    switch (appearance) {
      case MonsterAppearance.slime:
        _paintSlime(canvas, size);
      case MonsterAppearance.goblin:
        _paintGoblin(canvas, size);
      case MonsterAppearance.skeleton:
        _paintSkeleton(canvas, size);
      case MonsterAppearance.orc:
        _paintOrc(canvas, size);
      case MonsterAppearance.dragon:
        _paintDragon(canvas, size);
    }
  }

  void _paintSlime(Canvas canvas, Size size) {
    final body = Paint()..color = _creatureColor;
    final detail = Paint()..color = const Color(0xFF183B31);
    final path = Path()
      ..moveTo(size.width * 0.12, size.height * 0.88)
      ..cubicTo(
        size.width * 0.14,
        size.height * 0.61,
        size.width * 0.27,
        size.height * 0.38,
        size.width * 0.47,
        size.height * 0.34,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.29,
        size.width * 0.87,
        size.height * 0.57,
        size.width * 0.88,
        size.height * 0.88,
      )
      ..close();
    canvas.drawPath(path, body);
    canvas.drawCircle(_point(size, 0.36, 0.25), size.width * 0.08, body);
    canvas.drawCircle(_point(size, 0.66, 0.29), size.width * 0.05, body);
    canvas.drawCircle(_point(size, 0.38, 0.64), size.width * 0.035, detail);
    canvas.drawCircle(_point(size, 0.62, 0.64), size.width * 0.035, detail);
    _drawLine(canvas, size, 0.43, 0.73, 0.57, 0.73, detail.color, 2.5);
  }

  void _paintGoblin(Canvas canvas, Size size) {
    final skin = Paint()..color = _creatureColor;
    final clothes = Paint()..color = _secondaryColor;
    final dark = Paint()..color = const Color(0xFF26311C);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.31, 0.36),
          const Offset(0.04, 0.24),
          const Offset(0.22, 0.53),
        ],
        skin);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.69, 0.36),
          const Offset(0.96, 0.24),
          const Offset(0.78, 0.53),
        ],
        skin);
    canvas.drawOval(_rect(size, 0.25, 0.20, 0.75, 0.58), skin);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.31, 0.56),
          const Offset(0.69, 0.56),
          const Offset(0.82, 0.88),
          const Offset(0.18, 0.88),
        ],
        clothes);
    _drawLine(canvas, size, 0.28, 0.63, 0.12, 0.83, skin.color, 7);
    _drawLine(canvas, size, 0.72, 0.63, 0.88, 0.83, skin.color, 7);
    _drawLine(canvas, size, 0.38, 0.86, 0.34, 0.98, dark.color, 7);
    _drawLine(canvas, size, 0.62, 0.86, 0.66, 0.98, dark.color, 7);
    canvas.drawCircle(_point(size, 0.40, 0.39), size.width * 0.035, dark);
    canvas.drawCircle(_point(size, 0.60, 0.39), size.width * 0.035, dark);
    _drawLine(canvas, size, 0.44, 0.49, 0.56, 0.49, dark.color, 2);
  }

  void _paintSkeleton(Canvas canvas, Size size) {
    final bone = Paint()..color = _boneColor;
    final dark = Paint()..color = const Color(0xFF282631);
    canvas.drawCircle(_point(size, 0.5, 0.24), size.width * 0.23, bone);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        _rect(size, 0.32, 0.30, 0.68, 0.47),
        Radius.circular(size.width * 0.05),
      ),
      bone,
    );
    canvas.drawCircle(_point(size, 0.40, 0.23), size.width * 0.07, dark);
    canvas.drawCircle(_point(size, 0.60, 0.23), size.width * 0.07, dark);
    _drawLine(canvas, size, 0.50, 0.29, 0.50, 0.35, dark.color, 2);
    _drawLine(canvas, size, 0.39, 0.40, 0.61, 0.40, dark.color, 2);
    _drawLine(canvas, size, 0.50, 0.48, 0.50, 0.80, bone.color, 8);
    _drawLine(canvas, size, 0.28, 0.55, 0.72, 0.55, bone.color, 7);
    _drawLine(canvas, size, 0.32, 0.64, 0.68, 0.64, bone.color, 6);
    _drawLine(canvas, size, 0.35, 0.74, 0.65, 0.74, bone.color, 5);
    _drawLine(canvas, size, 0.50, 0.54, 0.29, 0.77, bone.color, 6);
    _drawLine(canvas, size, 0.50, 0.54, 0.71, 0.77, bone.color, 6);
    _drawLine(canvas, size, 0.44, 0.80, 0.34, 0.98, bone.color, 7);
    _drawLine(canvas, size, 0.56, 0.80, 0.66, 0.98, bone.color, 7);
  }

  void _paintOrc(Canvas canvas, Size size) {
    final skin = Paint()..color = _creatureColor;
    final armor = Paint()..color = _secondaryColor;
    final tooth = Paint()..color = const Color(0xFFF4E8C9);
    final dark = Paint()..color = const Color(0xFF3A211F);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.27, 0.29),
          const Offset(0.15, 0.06),
          const Offset(0.43, 0.21),
        ],
        tooth);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.73, 0.29),
          const Offset(0.85, 0.06),
          const Offset(0.57, 0.21),
        ],
        tooth);
    canvas.drawOval(_rect(size, 0.22, 0.17, 0.78, 0.53), skin);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.23, 0.52),
          const Offset(0.77, 0.52),
          const Offset(0.91, 0.85),
          const Offset(0.09, 0.85),
        ],
        armor);
    _drawLine(canvas, size, 0.25, 0.61, 0.08, 0.82, skin.color, 10);
    _drawLine(canvas, size, 0.75, 0.61, 0.92, 0.82, skin.color, 10);
    _drawLine(canvas, size, 0.37, 0.83, 0.34, 0.98, dark.color, 9);
    _drawLine(canvas, size, 0.63, 0.83, 0.66, 0.98, dark.color, 9);
    canvas.drawCircle(_point(size, 0.39, 0.35), size.width * 0.04, dark);
    canvas.drawCircle(_point(size, 0.61, 0.35), size.width * 0.04, dark);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.34, 0.43),
          const Offset(0.43, 0.44),
          const Offset(0.40, 0.59),
        ],
        tooth);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.66, 0.43),
          const Offset(0.57, 0.44),
          const Offset(0.60, 0.59),
        ],
        tooth);
  }

  void _paintDragon(Canvas canvas, Size size) {
    final body = Paint()..color = _creatureColor;
    final wing = Paint()..color = _secondaryColor;
    final eye = Paint()..color = const Color(0xFFFFD166);
    final tail = Path()
      ..moveTo(size.width * 0.59, size.height * 0.69)
      ..cubicTo(
        size.width * 0.97,
        size.height * 0.65,
        size.width * 0.87,
        size.height * 0.97,
        size.width * 0.99,
        size.height * 0.98,
      )
      ..lineTo(size.width * 0.78, size.height * 0.91)
      ..close();
    canvas.drawPath(tail, body);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.40, 0.51),
          const Offset(0.03, 0.22),
          const Offset(0.11, 0.57),
          const Offset(0.05, 0.70),
          const Offset(0.40, 0.72),
        ],
        wing);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.60, 0.51),
          const Offset(0.97, 0.22),
          const Offset(0.89, 0.57),
          const Offset(0.95, 0.70),
          const Offset(0.60, 0.72),
        ],
        wing);
    canvas.drawOval(_rect(size, 0.34, 0.45, 0.68, 0.83), body);
    canvas.drawOval(_rect(size, 0.54, 0.34, 0.89, 0.56), body);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.62, 0.38),
          const Offset(0.60, 0.19),
          const Offset(0.72, 0.36),
        ],
        body);
    _drawPolygon(
        canvas,
        size,
        [
          const Offset(0.77, 0.37),
          const Offset(0.87, 0.22),
          const Offset(0.85, 0.42),
        ],
        body);
    _drawLine(canvas, size, 0.41, 0.76, 0.34, 0.94, body.color, 8);
    _drawLine(canvas, size, 0.58, 0.76, 0.63, 0.94, body.color, 8);
    canvas.drawCircle(_point(size, 0.78, 0.42), size.width * 0.035, eye);
    _drawLine(canvas, size, 0.83, 0.50, 0.90, 0.50, wing.color, 2);
  }

  Offset _point(Size size, double x, double y) =>
      Offset(size.width * x, size.height * y);

  Rect _rect(Size size, double left, double top, double right, double bottom) =>
      Rect.fromLTRB(
        size.width * left,
        size.height * top,
        size.width * right,
        size.height * bottom,
      );

  void _drawPolygon(
      Canvas canvas, Size size, List<Offset> points, Paint paint) {
    final path = Path()
      ..moveTo(size.width * points.first.dx, size.height * points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(size.width * point.dx, size.height * point.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    double x1,
    double y1,
    double x2,
    double y2,
    Color color,
    double strokeWidth,
  ) {
    canvas.drawLine(
      _point(size, x1, y1),
      _point(size, x2, y2),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _MonsterPainter oldDelegate) =>
      oldDelegate.appearance != appearance || oldDelegate.theme != theme;
}
