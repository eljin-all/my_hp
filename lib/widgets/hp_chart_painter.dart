import 'package:flutter/material.dart';

class HpChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> history;
  final int currentHp;
  final int maxHp;
  final int? hoveredIndex;
  final Color lineColor;
  final Color pointColor;
  final Color gridColor;
  final Color textColor;
  final List<Color> fillGradientColors;

  HpChartPainter({
    required this.history,
    required this.currentHp,
    required this.maxHp,
    this.hoveredIndex,
    required this.lineColor,
    required this.pointColor,
    required this.gridColor,
    required this.textColor,
    required this.fillGradientColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.length < 2) return;

    const paddingLeft = 50.0;
    const paddingRight = 20.0;
    const paddingTop = 10.0;
    const paddingBottom = 40.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;

    final bgPaint = Paint()..color = Colors.transparent;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final times = history.map((e) => DateTime.parse(e['time'])).toList();
    final minTime = times.first.millisecondsSinceEpoch;
    final maxTime = times.last.millisecondsSinceEpoch;
    final timeRange = (maxTime - minTime).toDouble();
    if (timeRange == 0) return;

    // Горизонтальная сетка
    for (int i = 0; i <= 5; i++) {
      final value = i * (maxHp / 5).ceil();
      final y = paddingTop + chartHeight - (value / maxHp) * chartHeight;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );
      textPainter.text = TextSpan(
        text: value.toString(),
        style: TextStyle(fontSize: 11, color: textColor),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(paddingLeft - 25, y - 7));
    }

    // Вертикальная сетка и метки
    int step = (times.length / 5).ceil();
    if (step < 1) step = 1;
    for (int i = 0; i < times.length; i += step) {
      final t = times[i];
      final x = paddingLeft + ((t.millisecondsSinceEpoch - minTime) / timeRange) * chartWidth;
      if (x <= size.width - paddingRight) {
        canvas.drawLine(
          Offset(x, paddingTop),
          Offset(x, size.height - paddingBottom),
          gridPaint,
        );
        final label = "${t.day}.${t.month}";
        textPainter.text = TextSpan(
          text: label,
          style: TextStyle(fontSize: 11, color: textColor),
        );
        textPainter.layout();
        textPainter.paint(canvas, Offset(x - 15, size.height - paddingBottom + 5));
      }
    }

    // Линия графика — ПРЯМЫЕ ЛИНИИ МЕЖДУ ТОЧКАМИ
    final path = Path();
    final points = <Offset>[];
    for (int i = 0; i < history.length; i++) {
      final hp = history[i]['hp'] as int;
      final t = times[i].millisecondsSinceEpoch;
      final x = paddingLeft + ((t - minTime) / timeRange) * chartWidth;
      final y = paddingTop + chartHeight - (hp / maxHp) * chartHeight;
      points.add(Offset(x, y));
    }

    // Рисуем прямые линии
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, linePaint);

    // Точки
    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      final isHovered = hoveredIndex == i;
      canvas.drawCircle(
        point,
        isHovered ? 6 : 4,
        pointPaint..color = isHovered ? Colors.blue : pointColor,
      );
    }

    // Градиент под графиком
    final fillPath = Path.from(path);
    fillPath.lineTo(points.last.dx, size.height - paddingBottom);
    fillPath.lineTo(points.first.dx, size.height - paddingBottom);
    fillPath.close();
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: fillGradientColors,
      ).createShader(Rect.fromLTWH(0, paddingTop, size.width, chartHeight))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant HpChartPainter oldDelegate) {
    return oldDelegate.hoveredIndex != hoveredIndex ||
        oldDelegate.currentHp != currentHp ||
        oldDelegate.maxHp != maxHp ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.pointColor != pointColor ||
        oldDelegate.gridColor != gridColor ||
        oldDelegate.textColor != textColor;
  }
}