import 'dart:ui';
import 'package:dashboard_template_dribbble/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../providers/product_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/outline_button.dart';

class POSInventoryWidget extends StatelessWidget {
  const POSInventoryWidget({super.key});

  static const int lowStockThreshold = 20;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        final allItems = productProvider.products;
        final totalItems = allItems.length;
        final lowStockItems =
            allItems.where((item) => item.qty < lowStockThreshold && item.qty > 0).length;
        final outOfStockItems = allItems.where((item) => item.qty == 0).length;
        final totalValue =
            allItems.fold(0.0, (sum, item) => sum + (item.price * item.qty));

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 24.0),
          transform: Matrix4.translationValues(0, -90, 0),
          decoration: BoxDecoration(
            color: isDark
                ? theme.cardColor.withOpacity(0.9)
                : colorScheme.surface.withOpacity(0.9),
            borderRadius: BorderRadius.circular(25.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 12,
                spreadRadius: 3,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Store Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                    child: Icon(Icons.store,
                        color: colorScheme.primary, size: 32.0),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'main_store_location'.tr(),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'downtown_branch'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              // Inventory Value Summary with blur effect
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'inventory_value'.tr(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.55),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'LKR',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface.withOpacity(0.6),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              totalValue.toStringAsFixed(2),
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Admin Portal Link styled
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'admin_portal'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.75),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.arrow_outward_outlined,
                      color: colorScheme.secondary, size: 20.0),
                ],
              ),
              const SizedBox(height: 20),

              // Pie Chart Placeholder
              // const PieChartWidget(categories: [], dataMap: {}),
              // const SizedBox(height: 20),

              // Time Period Filter with subtle styling
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 18.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14.0,
                        color: colorScheme.onSurface.withOpacity(0.65)),
                    const SizedBox(width: 14),
                    Text(
                      'this_month'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.65),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Inventory Metrics with color-coded highlights
              _buildInventoryMetric(context, 'low_stock_items'.tr(), lowStockItems.toString(),
                  icon: Icons.warning_amber_rounded,
                  iconColor: Colors.orange.shade400),
              _buildInventoryMetric(context, 'out_of_stock'.tr(), outOfStockItems.toString(),
                  icon: Icons.error_outline, iconColor: Colors.red.shade400, isAlert: true),
              _buildInventoryMetric(context, 'new_arrivals'.tr(), '12',
                  icon: Icons.new_releases_rounded, iconColor: Colors.blue.shade400),
              _buildInventoryMetric(context, 'total_products'.tr(), totalItems.toString(),
                  icon: Icons.inventory_2_rounded, iconColor: colorScheme.primary),
              const SizedBox(height: 20),

              // Action Buttons styled with custom buttons
              CustomOutlineButton(
                title: 'order_stock'.tr(),
                color: Colors.orange.shade400,
                textColor: Colors.orange.shade400,
                width: 300,
              ),
              const SizedBox(height: 14),
              CustomButton(
                title: 'add_product'.tr(),
                color: Colors.green.shade400,
                onPressed: () {},
                width: 300,
              ),
              const SizedBox(height: 14),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryMetric(
    BuildContext context,
    String title,
    String value, {
    bool isAlert = false,
    IconData? icon,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 22,
              color: isAlert ? colorScheme.error : iconColor ?? colorScheme.onSurface.withOpacity(0.7),
            ),
          if (icon != null) const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isAlert ? colorScheme.error : colorScheme.onSurface.withOpacity(0.9),
              fontWeight: isAlert ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
