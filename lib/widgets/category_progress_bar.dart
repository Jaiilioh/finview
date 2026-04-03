import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class CategoryProgressBar extends StatelessWidget {
  final String name;
  final String iconName;
  final double spent;
  final double limit;

  const CategoryProgressBar({
    super.key,
    required this.name,
    required this.iconName,
    required this.spent,
    required this.limit,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = limit > 0 ? (spent / limit).clamp(0.0, 1.5) : 0.0;
    final pct = (ratio * 100).round();
    final isOver = ratio >= 1.0;
    final isCritical = ratio >= 0.9;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                CategoryIcons.getIcon(iconName),
                color: AppTheme.primaryFixedDim,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$pct%',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isOver
                      ? AppTheme.tertiaryFixed
                      : isCritical
                          ? const Color(0xFFFFB4A9)
                          : AppTheme.primaryFixedDim,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const SizedBox(width: 26),
              Expanded(
                child: Text(
                  '\$${spent.toStringAsFixed(0)} of \$${limit.toStringAsFixed(0)} spent',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0).toDouble(),
                backgroundColor: AppTheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver
                      ? AppTheme.tertiary
                      : isCritical
                          ? const Color(0xFFFFB4A9)
                          : AppTheme.primaryFixedDim,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
