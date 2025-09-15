import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/dashboard_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/outline_button.dart';

class POSDashboardCard extends StatefulWidget {
  const POSDashboardCard({super.key});

  @override
  State<POSDashboardCard> createState() => _POSDashboardCardState();
}

class _POSDashboardCardState extends State<POSDashboardCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardProvider>(context, listen: false)
          .fetchDashboardData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      transform: Matrix4.translationValues(0, -90, 0),
      height: MediaQuery.of(context).size.height * 0.22,
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 22.0),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor.withOpacity(0.9)
            : Theme.of(context).colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(25.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Consumer<DashboardProvider>(
        builder: (context, provider, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildHeaderRow(context, isDark),
              if (provider.isLoading)
                const Expanded(
                  child: Center(
                    child: LinearProgressIndicator(),
                  ),
                )
              else if (provider.errorMessage != null)
                Expanded(
                  child: Center(
                    child: Text(
                      provider.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                )
              else
                _buildStatsRow(provider.dashboardData, context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Text(
          'pos_summary'.tr(),
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const Spacer(),
        CustomOutlineButton(
          title: 'refund'.tr(),
          color: Theme.of(context).colorScheme.error,
          textColor: Theme.of(context).colorScheme.error,
          width: 150,
        ),
        const SizedBox(width: 16),
        CustomButton(
          title: 'new_sale'.tr(),
          color: Theme.of(context).colorScheme.primary,
          onPressed: () {},
          width: 150,
        ),
      ],
    );
  }

  Widget _buildStatsRow(DashboardData? data, BuildContext context) {
    final stats =
        data ?? DashboardData(sale: 0, purchase: 0, profit: 0, purchaseDue: 0);
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 300;
        return isWide
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _buildStatItems(stats, textColor),
              )
            : Column(
                children: [
                  Row(
                    children: _buildStatItems(stats, textColor).sublist(0, 2),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: _buildStatItems(stats, textColor).sublist(2, 4),
                  ),
                ],
              );
      },
    );
  }

  List<Widget> _buildStatItems(DashboardData stats, Color? textColor) {
    return [
      _buildStatBox(
        title: 'total_sales'.tr(),
        value: 'LKR ${stats.sale.toStringAsFixed(2)}',
        icon: Icons.point_of_sale,
        color: Colors.green,
        textColor: textColor,
      ),
      const SizedBox(width: 16),
      _buildStatBox(
        title: 'total_purchases'.tr(),
        value: 'LKR ${stats.purchase.toStringAsFixed(2)}',
        icon: Icons.shopping_cart,
        color: Colors.blue,
        textColor: textColor,
      ),
      const SizedBox(width: 16),
      _buildStatBox(
        title: 'profit_loss'.tr(),
        value: 'LKR ${stats.profit.toStringAsFixed(2)}',
        icon: Icons.trending_up,
        color: Colors.purple,
        textColor: textColor,
      ),
      const SizedBox(width: 16),
      _buildStatBox(
        title: 'purchase_due'.tr(),
        value: 'LKR ${stats.purchaseDue.toStringAsFixed(2)}',
        icon: Icons.payment,
        color: Colors.red,
        textColor: textColor,
      ),
    ];
  }

  Widget _buildStatBox({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color? textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor?.withOpacity(0.7),
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
