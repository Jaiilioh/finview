import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import '../../widgets/category_progress_bar.dart';
import '../../widgets/spending_chart.dart';
import '../transactions/add_transaction_sheet.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/logo.png',
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Finview',
                  style: GoogleFonts.manrope(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryFixed,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              // Streak Badge
              if (provider.streakDays > 0)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          color: Color(0xFFFFB4A9), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '${provider.streakDays}d',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryFixed,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Hero Balance Card ──
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TOTAL LIQUID WEALTH',
                        style: GoogleFonts.publicSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currencyFmt.format(provider.remainingBalance),
                        style: GoogleFonts.manrope(
                          fontSize: 44,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.onSurface,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  provider.remainingBalance >= 0
                                      ? Icons.trending_up_rounded
                                      : Icons.trending_down_rounded,
                                  color: provider.remainingBalance >= 0
                                      ? AppTheme.primaryFixedDim
                                      : AppTheme.tertiaryFixed,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  provider.totalIncome > 0
                                      ? '${((provider.remainingBalance / provider.totalIncome) * 100).toStringAsFixed(1)}% remaining'
                                      : 'Set income in settings',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryFixedDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddTransaction(context),
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: Text('Quick Add Transaction',
                              style: GoogleFonts.publicSans(
                                  fontWeight: FontWeight.w700, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: AppTheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Monthly Outflow Card ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MONTHLY OUTFLOW',
                        style: GoogleFonts.publicSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AppTheme.onPrimary.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currencyFmt.format(provider.totalSpent),
                        style: GoogleFonts.manrope(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SAFE TO SPEND',
                            style: GoogleFonts.publicSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color:
                                  AppTheme.onPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                          Text(
                            '${currencyFmt.format(provider.remainingBalance.clamp(0, double.infinity))} LEFT',
                            style: GoogleFonts.publicSans(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color:
                                  AppTheme.onPrimary.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: provider.totalIncome > 0
                              ? (provider.totalSpent / provider.totalIncome)
                                  .clamp(0.0, 1.0)
                              : 0.0,
                          minHeight: 6,
                          backgroundColor: AppTheme.primaryContainer,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryFixed),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Budget Health Score ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: provider.budgetHealthScore / 100,
                                strokeWidth: 6,
                                backgroundColor:
                                    AppTheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  provider.budgetHealthScore >= 70
                                      ? AppTheme.primaryFixedDim
                                      : provider.budgetHealthScore >= 40
                                          ? const Color(0xFFFFB4A9)
                                          : AppTheme.tertiaryFixed,
                                ),
                              ),
                            ),
                            Text(
                              '${provider.budgetHealthScore}',
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Budget Health',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.budgetHealthScore >= 70
                                  ? 'You\'re on track this month'
                                  : provider.budgetHealthScore >= 40
                                      ? 'Some categories need attention'
                                      : 'Budget overspending detected',
                              style: GoogleFonts.publicSans(
                                fontSize: 12,
                                color: AppTheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Allocations ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Allocations',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          const Icon(Icons.more_horiz_rounded,
                              color: AppTheme.onSurfaceVariant),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...provider.categories.map((cat) {
                        return CategoryProgressBar(
                          name: cat.name,
                          iconName: cat.iconName,
                          spent: provider.getCategorySpent(cat.name),
                          limit: cat.budgetLimit,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Spending Insight (Donut Chart) ──
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
                        'Spending Breakdown',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SpendingChart(
                        categorySpending: provider.categorySpendingMap,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Weekly Nudge ──
                if (provider.weeklyNudge != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryContainer,
                          AppTheme.primary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppTheme.primaryFixed, size: 28),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SPENDING INSIGHT',
                                style: GoogleFonts.publicSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                  color: AppTheme.primaryFixed,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                provider.weeklyNudge!,
                                style: GoogleFonts.publicSans(
                                  fontSize: 13,
                                  color: AppTheme.onPrimary
                                      .withValues(alpha: 0.9),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Recent Activity ──
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Journal of Activity',
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'VIEW ALL',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: AppTheme.primaryFixedDim,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_rounded,
                                    size: 14,
                                    color: AppTheme.primaryFixedDim),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (provider.recentTransactions.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No transactions yet.\nTap "Quick Add" above to get started.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.publicSans(
                                fontSize: 13,
                                color: AppTheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ),
                        )
                      else
                        ...provider.recentTransactions.map((t) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceContainerLowest,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: t.isIncome
                                        ? AppTheme.primary
                                            .withValues(alpha: 0.2)
                                        : AppTheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    t.isIncome
                                        ? Icons.payments_rounded
                                        : CategoryIcons.getIcon(
                                            _getIconForCategory(
                                                t.category,
                                                provider.categories)),
                                    color: t.isIncome
                                        ? AppTheme.primaryFixedDim
                                        : AppTheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        t.label,
                                        style: GoogleFonts.publicSans(
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.onSurface,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${t.category} • ${DateFormat.MMMd().format(t.date)}',
                                        style: GoogleFonts.publicSans(
                                          fontSize: 11,
                                          color: AppTheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${t.isIncome ? '+' : '-'}${currencyFmt.format(t.amount)}',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: t.isIncome
                                        ? AppTheme.primaryFixedDim
                                        : AppTheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),

                // ── Goal Progress (if any) ──
                if (provider.goals.isNotEmpty) ...[
                  const SizedBox(height: 16),
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
                          'Savings Goals',
                          style: GoogleFonts.manrope(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...provider.goals.take(2).map((goal) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      goal.name,
                                      style: GoogleFonts.publicSans(
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.onSurface,
                                      ),
                                    ),
                                    Text(
                                      '${(goal.progress * 100).round()}%',
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryFixedDim,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                TweenAnimationBuilder<double>(
                                  tween: Tween(begin: 0, end: goal.progress),
                                  duration: const Duration(milliseconds: 800),
                                  curve: Curves.easeOutCubic,
                                  builder: (context, value, _) {
                                    return ClipRRect(
                                      borderRadius:
                                          BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: value,
                                        minHeight: 8,
                                        backgroundColor: AppTheme
                                            .surfaceContainerHighest,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                                AppTheme.primaryFixedDim),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${currencyFmt.format(goal.currentAmount)} of ${currencyFmt.format(goal.targetAmount)}',
                                  style: GoogleFonts.publicSans(
                                    fontSize: 11,
                                    color: AppTheme.onSurfaceVariant,
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
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconForCategory(
      String categoryName, List<dynamic> categories) {
    for (final cat in categories) {
      if (cat.name == categoryName) return cat.iconName;
    }
    return 'more_horiz';
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }
}
