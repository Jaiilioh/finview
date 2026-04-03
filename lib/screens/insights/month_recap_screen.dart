import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';

class MonthRecapScreen extends StatelessWidget {
  const MonthRecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final now = DateTime.now();
    final monthName = DateFormat.MMMM().format(now);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          '$monthName Recap',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w800,
            color: AppTheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppTheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Net Savings
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary,
                  AppTheme.primaryContainer,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NET SAVINGS',
                  style: GoogleFonts.publicSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppTheme.primaryFixed,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFmt.format(provider.netSavings),
                  style: GoogleFonts.manrope(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onPrimary,
                    letterSpacing: -1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  provider.netSavings >= 0
                      ? 'Great work! You saved money this month.'
                      : 'You overspent your budget this month.',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    color: AppTheme.onPrimary.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _RecapCard(
                  title: 'BEST CATEGORY',
                  value: provider.bestCategory ?? 'N/A',
                  icon: Icons.emoji_events_rounded,
                  iconColor: AppTheme.primaryFixedDim,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RecapCard(
                  title: 'WORST CATEGORY',
                  value: provider.worstCategory ?? 'N/A',
                  icon: Icons.warning_rounded,
                  iconColor: AppTheme.tertiaryFixed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Income vs Spent
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _RecapRow(
                  label: 'Monthly Income',
                  value: currencyFmt.format(provider.totalIncome),
                  color: AppTheme.primaryFixedDim,
                ),
                const SizedBox(height: 16),
                _RecapRow(
                  label: 'Total Spent',
                  value: currencyFmt.format(provider.totalSpent),
                  color: AppTheme.tertiaryFixed,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Divider(
                      color: AppTheme.outlineVariant.withValues(alpha: 0.2)),
                ),
                _RecapRow(
                  label: 'Transactions',
                  value: '${provider.currentMonthTransactions.length}',
                  color: AppTheme.onSurface,
                ),
                const SizedBox(height: 16),
                _RecapRow(
                  label: 'Budget Health',
                  value: '${provider.budgetHealthScore}/100',
                  color: provider.budgetHealthScore >= 70
                      ? AppTheme.primaryFixedDim
                      : AppTheme.tertiaryFixed,
                ),
                const SizedBox(height: 16),
                _RecapRow(
                  label: 'Streak',
                  value: '${provider.streakDays} days',
                  color: AppTheme.onSurface,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Category breakdown
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category Breakdown',
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ...provider.categories.map((cat) {
                  final spent = provider.getCategorySpent(cat.name);
                  final pct = cat.budgetLimit > 0
                      ? (spent / cat.budgetLimit * 100).round()
                      : 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            cat.name,
                            style: GoogleFonts.publicSans(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          currencyFmt.format(spent),
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 44,
                          child: Text(
                            '$pct%',
                            textAlign: TextAlign.right,
                            style: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: pct >= 100
                                  ? AppTheme.tertiaryFixed
                                  : AppTheme.primaryFixedDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _RecapCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.publicSans(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecapRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _RecapRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.publicSans(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
