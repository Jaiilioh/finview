import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/transaction.dart';
import '../../providers/app_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/constants.dart';
import 'add_transaction_sheet.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  String? _selectedCategoryFilter;
  final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    var filtered = provider.transactions.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!t.label.toLowerCase().contains(q) &&
            !t.category.toLowerCase().contains(q)) {
          return false;
        }
      }
      if (_selectedCategoryFilter != null &&
          t.category != _selectedCategoryFilter) {
        return false;
      }
      return true;
    }).toList();

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
                  'MONTHLY ACTIVITY',
                  style: GoogleFonts.publicSans(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Activity',
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
                // Search
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.publicSans(
                        color: AppTheme.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search merchants...',
                      prefixIcon: const Icon(Icons.search_rounded,
                          color: AppTheme.onSurfaceVariant),
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Filter chips
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedCategoryFilter == null,
                        onTap: () => setState(
                            () => _selectedCategoryFilter = null),
                      ),
                      ...provider.categories.map((c) {
                        return _FilterChip(
                          label: c.name,
                          isSelected:
                              _selectedCategoryFilter == c.name,
                          onTap: () => setState(
                              () => _selectedCategoryFilter = c.name),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // New Entry button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddTransaction(context),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('New Entry',
                        style: GoogleFonts.publicSans(
                            fontWeight: FontWeight.w700, fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: AppTheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Transaction list
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_rounded,
                              color: AppTheme.onSurfaceVariant
                                  .withValues(alpha: 0.3),
                              size: 48),
                          const SizedBox(height: 12),
                          Text(
                            'No transactions found',
                            style: GoogleFonts.publicSans(
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...filtered.map((t) => _TransactionItem(
                        transaction: t,
                        currencyFmt: currencyFmt,
                        categories: provider.categories,
                        onEdit: () => _showEditTransaction(context, t),
                        onDelete: () => provider.deleteTransaction(t.id),
                      )),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionSheet(),
    );
  }

  void _showEditTransaction(BuildContext context, Transaction t) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddTransactionSheet(existing: t),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final NumberFormat currencyFmt;
  final List<dynamic> categories;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TransactionItem({
    required this.transaction,
    required this.currencyFmt,
    required this.categories,
    required this.onEdit,
    required this.onDelete,
  });

  String _getIconForCategory(String categoryName) {
    for (final cat in categories) {
      if (cat.name == categoryName) return cat.iconName;
    }
    return 'more_horiz';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppTheme.primaryContainer,
              foregroundColor: AppTheme.primaryFixed,
              icon: Icons.edit_rounded,
              borderRadius: BorderRadius.circular(16),
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppTheme.tertiaryContainer,
              foregroundColor: AppTheme.tertiaryFixed,
              icon: Icons.delete_rounded,
              borderRadius: BorderRadius.circular(16),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: onEdit,
          child: Container(
            padding: const EdgeInsets.all(16),
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
                    color: transaction.isIncome
                        ? AppTheme.primary.withValues(alpha: 0.2)
                        : AppTheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    transaction.isIncome
                        ? Icons.payments_rounded
                        : CategoryIcons.getIcon(
                            _getIconForCategory(transaction.category)),
                    color: transaction.isIncome
                        ? AppTheme.primaryFixedDim
                        : AppTheme.onSurfaceVariant,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.label,
                        style: GoogleFonts.publicSans(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.onSurface,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            '${transaction.category} • ${DateFormat.MMMd().format(transaction.date)}',
                            style: GoogleFonts.publicSans(
                              fontSize: 11,
                              color: AppTheme.onSurfaceVariant,
                            ),
                          ),
                          if (transaction.isRecurring) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.autorenew_rounded,
                              size: 12,
                              color: AppTheme.primaryFixedDim,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '${transaction.isIncome ? '+' : '-'}${currencyFmt.format(transaction.amount)}',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: transaction.isIncome
                        ? AppTheme.primaryFixedDim
                        : AppTheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primary
                : AppTheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.publicSans(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppTheme.onPrimary
                    : AppTheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
