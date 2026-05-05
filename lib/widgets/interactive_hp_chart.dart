import 'package:flutter/material.dart';
import 'hp_chart_painter.dart';

class InteractiveHpChart extends StatefulWidget {
  final List<Map<String, dynamic>> history;
  final int currentHp;
  final int maxHp;
  final ValueChanged<int>? onPointSelected;

  const InteractiveHpChart({
    super.key,
    required this.history,
    required this.currentHp,
    required this.maxHp,
    this.onPointSelected,
  });

  @override
  State<InteractiveHpChart> createState() => _InteractiveHpChartState();
}

class _InteractiveHpChartState extends State<InteractiveHpChart> {
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.history.length < 2) {
      return const Center(child: Text("Недостаточно данных"));
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTapUp: (details) => _handleTap(details.localPosition),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: CustomPaint(
          painter: HpChartPainter(
            history: widget.history,
            currentHp: widget.currentHp,
            maxHp: widget.maxHp,
            hoveredIndex: _hoveredIndex,
            lineColor: colorScheme.error, // красный из темы
            pointColor: colorScheme.error,
            gridColor: colorScheme.onSurface.withOpacity(0.3),
            textColor: colorScheme.onSurface.withOpacity(0.6),
            fillGradientColors: [
              colorScheme.error.withOpacity(0.2),
              colorScheme.error.withOpacity(0.0),
            ],
          ),
          child: Container(),
        ),
      ),
    );
  }

  void _handleTap(Offset localPosition) {
    final size = context.size;
    if (size == null) return;

    const paddingLeft = 50.0;
    const paddingRight = 20.0;
    final chartWidth = size.width - paddingLeft - paddingRight;

    final times = widget.history.map((e) => DateTime.parse(e['time'])).toList();
    final minTime = times.first.millisecondsSinceEpoch;
    final maxTime = times.last.millisecondsSinceEpoch;
    final timeRange = (maxTime - minTime).toDouble();

    int? closestIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < widget.history.length; i++) {
      final t = times[i].millisecondsSinceEpoch;
      final x = paddingLeft + ((t - minTime) / timeRange) * chartWidth;
      final distance = (x - localPosition.dx).abs();
      if (distance < minDistance && distance < 20) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    setState(() => _hoveredIndex = closestIndex);
    if (closestIndex != null) {
      widget.onPointSelected?.call(closestIndex);
    }
  }
}