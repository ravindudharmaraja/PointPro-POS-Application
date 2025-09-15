import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/theme_provider.dart';
import '../widgets/header.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch data when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false)
          .fetchAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final dividerColor = Theme.of(context).dividerColor;

    if (analyticsProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('loading_data'.tr()),
            ],
          ),
        ),
      );
    }

    if (analyticsProvider.errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('error_loading_data'.tr()),
              Text(analyticsProvider.errorMessage!),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => analyticsProvider.fetchAnalyticsData(),
                child: Text('retry'.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (analyticsProvider.analyticsData == null) {
      return Scaffold(
        body: Center(child: Text('no_data_available'.tr())),
      );
    }

    final data = analyticsProvider.analyticsData!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            const Header(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(context, analyticsProvider),
                  const SizedBox(height: 20),
                  _buildKpiCards(context, data),
                  const SizedBox(height: 20),
                  _buildChartsSection(
                      context, isDarkMode, textColor, dividerColor, data),
                  const SizedBox(height: 20),
                  _buildDetailedStatsSection(context, data),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, AnalyticsProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'analytics_reports'.tr(),
          style: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        // _buildPeriodDropdown(provider),
      ],
    );
  }

  // Widget _buildPeriodDropdown(AnalyticsProvider provider) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     decoration: BoxDecoration(
  //       color: Theme.of(context).cardColor,
  //       borderRadius: BorderRadius.circular(8),
  //       border: Border.all(color: Theme.of(context).dividerColor),
  //     ),
  //     child: DropdownButtonHideUnderline(
  //       child: DropdownButton<String>(
  //         value: provider.selectedPeriod,
  //         dropdownColor: Theme.of(context).cardColor,
  //         style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
  //         items: ['today', 'this_week', 'this_month', 'this_year']
  //             .map((String value) {
  //           return DropdownMenuItem<String>(
  //             value: value,
  //             child: Text(value.tr()),
  //           );
  //         }).toList(),
  //         onChanged: (newValue) {
  //           provider.setSelectedPeriod(newValue!);
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildKpiCards(BuildContext context, AnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 700
            ? 4
            : constraints.maxWidth > 500
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          childAspectRatio: constraints.maxWidth > 500 ? 2.5 : 1.8,
          children: [
            _buildKpiCard(
              context: context,
              title: 'total_sales'.tr(),
              value: 'LKR ${_formatNumber(data.salesTotal)}',
              icon: Icons.point_of_sale,
              color: Colors.blue,
              trend: _calculateTrend(data.salesMonthlyTrend),
            ),
            _buildKpiCard(
              context: context,
              title: 'total_purchases'.tr(),
              value: 'LKR ${_formatNumber(data.purchasesTotal)}',
              icon: Icons.shopping_cart,
              color: Colors.green,
              trend: _calculateTrend(data.purchasesMonthlyTrend),
            ),
            _buildKpiCard(
              context: context,
              title: 'net_profit'.tr(),
              value: 'LKR ${_formatNumber(data.profit)}',
              icon: Icons.trending_up,
              color: data.profit >= 0 ? Colors.purple : Colors.red,
              trend: data.profit >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            _buildKpiCard(
              context: context,
              title: 'outstanding_due'.tr(),
              value: 'LKR ${_formatNumber(data.purchasesDue)}',
              icon: Icons.payment,
              color: Colors.orange,
              trend: data.purchasesDue > 0 ? Icons.warning : Icons.check_circle,
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpiCard({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required dynamic trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
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
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        value,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trend is IconData)
                      Icon(trend, color: color, size: 20)
                    else if (trend is double)
                      Row(
                        children: [
                          Icon(
                            trend >= 0
                                ? Icons.trending_up
                                : Icons.trending_down,
                            color: trend >= 0 ? Colors.green : Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trend.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: trend >= 0 ? Colors.green : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartsSection(BuildContext context, bool isDarkMode,
      Color? textColor, Color dividerColor, AnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildSalesTrendChart(
                    context, isDarkMode, textColor, dividerColor, data),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // _buildPaymentMethodsChart(context, data),
                    // const SizedBox(height: 20),
                    _buildTopProductsChart(context, data),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildSalesTrendChart(
                  context, isDarkMode, textColor, dividerColor, data),
              const SizedBox(height: 20),
              _buildPaymentMethodsChart(context, data),
              const SizedBox(height: 20),
              _buildTopProductsChart(context, data),
            ],
          );
        }
      },
    );
  }

  Widget _buildSalesTrendChart(BuildContext context, bool isDarkMode,
      Color? textColor, Color dividerColor, AnalyticsData data) {
    final maxValue = [...data.salesMonthlyTrend, ...data.purchasesMonthlyTrend]
        .reduce((a, b) => a > b ? a : b);

    return _buildChartContainer(
      context: context,
      title: 'monthly_sales_trend'.tr(),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxValue * 1.1,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: maxValue / 5,
            getDrawingHorizontalLine: (value) => FlLine(
              color: dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (value) => FlLine(
              color: dividerColor.withOpacity(0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  const months = [
                    'Jan',
                    'Feb',
                    'Mar',
                    'Apr',
                    'May',
                    'Jun',
                    'Jul',
                    'Aug',
                    'Sep',
                    'Oct',
                    'Nov',
                    'Dec'
                  ];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      months[value.toInt()],
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 4.0),
                    child: Text(
                      'LKR ${_formatCompact(value)}',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                      ),
                    ),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: dividerColor.withOpacity(0.3), width: 1),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: data.salesMonthlyTrend
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.3),
                    Colors.blue.withOpacity(0.0)
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            LineChartBarData(
              spots: data.purchasesMonthlyTrend
                  .asMap()
                  .entries
                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                  .toList(),
              isCurved: true,
              color: Colors.green,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsChart(BuildContext context, AnalyticsData data) {
    final total = data.paymentReceivedCash + data.paymentReceivedBank;

    return _buildChartContainer(
      context: context,
      title: 'payment_methods'.tr(),
      child: total <= 0
          ? Center(
              child: Text(
                'no_payment_data'.tr(),
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            )
          : PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    value: data.paymentReceivedCash,
                    color: Colors.green,
                    title:
                        '${(data.paymentReceivedCash / total * 100).toStringAsFixed(0)}%',
                    radius: 24,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).cardColor,
                    ),
                    badgeWidget:
                        _paymentMethodBadge(Icons.attach_money, 'Cash'),
                    badgePositionPercentageOffset: 0.98,
                  ),
                  PieChartSectionData(
                    value: data.paymentReceivedBank,
                    color: Colors.blue,
                    title:
                        '${(data.paymentReceivedBank / total * 100).toStringAsFixed(0)}%',
                    radius: 24,
                    titleStyle: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).cardColor,
                    ),
                    badgeWidget:
                        _paymentMethodBadge(Icons.account_balance, 'Bank'),
                    badgePositionPercentageOffset: 0.98,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                startDegreeOffset: 180,
              ),
            ),
    );
  }

  Widget _paymentMethodBadge(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildTopProductsChart(BuildContext context, AnalyticsData data) {
    return _buildChartContainer(
      context: context,
      title: 'top_selling_products'.tr(),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final product = data.topProducts[groupIndex];
                return BarTooltipItem(
                  '${product.name}\n',
                  TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: 'LKR ${_formatNumber(product.sales)}\n',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextSpan(
                      text: '${product.quantity} sold',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final product = data.topProducts[value.toInt()];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: data.topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: product.sales,
                  color: _getProductColor(index),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getProductColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  Widget _buildChartContainer({
    required BuildContext context,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsSection(BuildContext context, AnalyticsData data) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use row layout for wider screens, column for narrow screens
        final useRowLayout = constraints.maxWidth > 600;

        return useRowLayout
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      context,
                      title: 'sales_statistics'.tr(),
                      items: [
                        _buildStatRow('total_sales'.tr(),
                            'LKR ${_formatNumber(data.salesTotal)}'),
                        _buildStatRow('tax_collected'.tr(),
                            'LKR ${_formatNumber(data.salesTax)}'),
                        _buildStatRow('discount_given'.tr(),
                            'LKR ${_formatNumber(data.salesDiscount)}'),
                        _buildStatRow('products_sold'.tr(),
                            _formatNumber(data.sellingProducts.toDouble())),
                        _buildStatRow('products_available'.tr(),
                            _formatNumber(data.availableProducts.toDouble())),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatsCard(
                      context,
                      title: 'purchase_statistics'.tr(),
                      items: [
                        _buildStatRow('total_purchases'.tr(),
                            'LKR ${_formatNumber(data.purchasesTotal)}'),
                        _buildStatRow('amount_paid'.tr(),
                            'LKR ${_formatNumber(data.purchasesPaid)}'),
                        _buildStatRow('outstanding_due'.tr(),
                            'LKR ${_formatNumber(data.purchasesDue)}'),
                        _buildStatRow('tax_paid'.tr(),
                            'LKR ${_formatNumber(data.purchasesTax)}'),
                        _buildStatRow('total_products'.tr(),
                            _formatNumber(data.purchasesProducts.toDouble())),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  _buildStatsCard(
                    context,
                    title: 'sales_statistics'.tr(),
                    items: [
                      _buildStatRow('total_sales'.tr(),
                          'LKR ${_formatNumber(data.salesTotal)}'),
                      _buildStatRow('tax_collected'.tr(),
                          'LKR ${_formatNumber(data.salesTax)}'),
                      _buildStatRow('discount_given'.tr(),
                          'LKR ${_formatNumber(data.salesDiscount)}'),
                      _buildStatRow('products_sold'.tr(),
                          _formatNumber(data.sellingProducts.toDouble())),
                      _buildStatRow('products_available'.tr(),
                          _formatNumber(data.availableProducts.toDouble())),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildStatsCard(
                    context,
                    title: 'purchase_statistics'.tr(),
                    items: [
                      _buildStatRow('total_purchases'.tr(),
                          'LKR ${_formatNumber(data.purchasesTotal)}'),
                      _buildStatRow('amount_paid'.tr(),
                          'LKR ${_formatNumber(data.purchasesPaid)}'),
                      _buildStatRow('outstanding_due'.tr(),
                          'LKR ${_formatNumber(data.purchasesDue)}'),
                      _buildStatRow('tax_paid'.tr(),
                          'LKR ${_formatNumber(data.purchasesTax)}'),
                      _buildStatRow('total_products'.tr(),
                          _formatNumber(data.purchasesProducts.toDouble())),
                    ],
                  ),
                ],
              );
      },
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatNumber(double number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toStringAsFixed(number % 1 == 0 ? 0 : 2);
  }

  String _formatCompact(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}K';
    }
    return value.toStringAsFixed(value % 1 == 0 ? 0 : 0);
  }

  double _calculateTrend(List<double> monthlyData) {
    if (monthlyData.length < 2) return 0.0;
    final current = monthlyData.last;
    final previous = monthlyData[monthlyData.length - 2];
    return ((current - previous) / previous * 100);
  }
}
