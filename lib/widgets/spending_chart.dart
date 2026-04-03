import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SpendingChart extends StatelessWidget {
  final Map<String, double> categorySpending;

  const SpendingChart({super.key, required this.categorySpending});

  static const List<Color> _chartColors = [
    AppTheme.primary,
    AppTheme.primaryContainer,
    Color(0xFF006C4A),
    AppTheme.primaryFixedDim,
    AppTheme.primaryFixed,
    Color(0xFF545F73),
    AppTheme.onSurfaceVariant,
  ];

  @override
  Widget build(BuildContext context) {
    final entries = categorySpending.entries
        .where((e) => e.value > 0)
        .toList();

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No spending data yet',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final total = entries.fold(0.0, (sum, e) => sum + e.value);

    return Row(
      children: [
        SizedBox(
          width: 140,
          height: 140,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 36,
              sections: entries.asMap().entries.map((entry) {
                final idx = entry.key;
                final e = entry.value;
                final pct = (e.value / total * 100);
                return PieChartSectionData(
                  color: _chartColors[idx % _chartColors.length],
                  value: e.value,
                  title: '${pct.round()}%',
                  radius: 28,
                  titleStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: entries.asMap().entries.map((entry) {
              final idx = entry.key;
              final e = entry.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _chartColors[idx % _chartColors.length],
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${e.value.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
