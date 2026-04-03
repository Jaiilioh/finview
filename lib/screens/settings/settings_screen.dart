import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../models/budget_category.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppTheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONFIGURATION',
                  style: GoogleFonts.publicSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Budget Controls',
                  style: GoogleFonts.manrope(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.onSurface,
                  ),
                ),
              ],
            ),
            toolbarHeight: 70,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text(
                  'Precision management for your capital. Architect your monthly spending with granular controls.',
                  style: GoogleFonts.publicSans(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 24),

                // ── Monthly Income ──
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.account_balance_rounded,
                            color: AppTheme.primaryFixed, size: 22),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Monthly Income',
                              style: GoogleFonts.publicSans(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                            Text(
                              currencyFmt.format(provider.totalIncome),
                              style: GoogleFonts.manrope(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryFixedDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _editIncome(context, provider),
                        icon: const Icon(Icons.edit_rounded,
                            color: AppTheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Active Allocations ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ACTIVE ALLOCATIONS',
                      style: GoogleFonts.publicSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppTheme.onSurfaceVariant,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () =>
                          _showAddCategory(context, provider),
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: Text('New Category',
                          style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: AppTheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ...provider.categories.map((cat) {
                  final spent = provider.getCategorySpent(cat.name);
                  final pct = cat.budgetLimit > 0
                      ? (spent / cat.budgetLimit * 100).round()
                      : 0;
                  final isCritical = pct >= 90;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isCritical
                          ? AppTheme.tertiaryContainer
                              .withValues(alpha: 0.2)
                          : AppTheme.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                CategoryIcons.getIcon(cat.iconName),
                                color: AppTheme.primaryFixedDim,
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
                                    cat.name,
                                    style: GoogleFonts.publicSans(
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                  Text(
                                    '${currencyFmt.format(spent)} / ${currencyFmt.format(cat.budgetLimit)}',
                                    style: GoogleFonts.manrope(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isCritical
                                    ? AppTheme.tertiaryFixed
                                    : AppTheme.primaryFixedDim,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (pct / 100).clamp(0.0, 1.0).toDouble(),
                            minHeight: 8,
                            backgroundColor:
                                AppTheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation(
                              isCritical
                                  ? AppTheme.tertiary
                                  : AppTheme.primaryFixedDim,
                            ),
                          ),
                        ),
                        if (isCritical) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.warning_rounded,
                                  size: 14,
                                  color: AppTheme.tertiaryFixed),
                              const SizedBox(width: 6),
                              Text(
                                'CRITICAL THRESHOLD REACHED',
                                style: GoogleFonts.publicSans(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.2,
                                  color: AppTheme.tertiaryFixed,
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          const SizedBox(height: 6),
                          Text(
                            'REMAINING: ${currencyFmt.format((cat.budgetLimit - spent).clamp(0, double.infinity))}',
                            style: GoogleFonts.publicSans(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () =>
                                  _editCategory(context, provider, cat),
                              child: Text(
                                'Edit',
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryFixedDim,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () =>
                                  provider.deleteCategory(cat.id),
                              child: Text(
                                'Delete',
                                style: GoogleFonts.publicSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // ── Month Recap ──
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month-End Recap',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Review your best and worst spending categories.',
                        style: GoogleFonts.publicSans(
                          fontSize: 13,
                          color: AppTheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => context.push('/recap'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryFixed,
                            foregroundColor: AppTheme.primary,
                            padding: const EdgeInsets.symmetric(
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                            elevation: 0,
                          ),
                          child: Text(
                            'See Analysis',
                            style: GoogleFonts.publicSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _editIncome(BuildContext context, AppProvider provider) {
    final controller = TextEditingController(
        text: provider.totalIncome.toStringAsFixed(0));
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Edit Monthly Income',
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: GoogleFonts.manrope(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
                decoration: InputDecoration(
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.manrope(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryFixedDim,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final val =
                        double.tryParse(controller.text) ?? 0;
                    provider.updateIncome(val);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: Text('Save',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCategory(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController();
    final limitCtrl = TextEditingController();
    String selectedIcon = 'shopping_bag';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSt) {
          return Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Category',
                    style: GoogleFonts.manrope(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.onSurface)),
                const SizedBox(height: 16),
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.publicSans(
                      color: AppTheme.onSurface),
                  decoration:
                      const InputDecoration(hintText: 'Category name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: limitCtrl,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.publicSans(
                      color: AppTheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Budget limit',
                    prefixText: '\$ ',
                    prefixStyle: GoogleFonts.publicSans(
                        color: AppTheme.primaryFixedDim),
                  ),
                ),
                const SizedBox(height: 12),
                Text('ICON',
                    style: GoogleFonts.publicSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppTheme.onSurfaceVariant)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CategoryIcons.allNames.map((iconName) {
                    final isSelected = selectedIcon == iconName;
                    return GestureDetector(
                      onTap: () => setSt(() => selectedIcon = iconName),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          CategoryIcons.getIcon(iconName),
                          color: isSelected
                              ? AppTheme.primaryFixed
                              : AppTheme.onSurfaceVariant,
                          size: 18,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      final limit =
                          double.tryParse(limitCtrl.text) ?? 0;
                      if (name.isEmpty) return;
                      provider.addCategory(BudgetCategory(
                        id: const Uuid().v4(),
                        name: name,
                        iconName: selectedIcon,
                        budgetLimit: limit,
                      ));
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      elevation: 0,
                    ),
                    child: Text('Add Category',
                        style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _editCategory(
      BuildContext context, AppProvider provider, BudgetCategory cat) {
    final nameCtrl = TextEditingController(text: cat.name);
    final limitCtrl =
        TextEditingController(text: cat.budgetLimit.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit ${cat.name}',
                  style: GoogleFonts.manrope(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style:
                    GoogleFonts.publicSans(color: AppTheme.onSurface),
                decoration:
                    const InputDecoration(hintText: 'Category name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: limitCtrl,
                keyboardType: TextInputType.number,
                style:
                    GoogleFonts.publicSans(color: AppTheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Budget limit',
                  prefixText: '\$ ',
                  prefixStyle: GoogleFonts.publicSans(
                      color: AppTheme.primaryFixedDim),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final updated = BudgetCategory(
                      id: cat.id,
                      name: nameCtrl.text.trim().isEmpty
                          ? cat.name
                          : nameCtrl.text.trim(),
                      iconName: cat.iconName,
                      budgetLimit:
                          double.tryParse(limitCtrl.text) ??
                              cat.budgetLimit,
                      colorValue: cat.colorValue,
                    );
                    provider.updateCategory(updated);
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: AppTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                    elevation: 0,
                  ),
                  child: Text('Save Changes',
                      style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
