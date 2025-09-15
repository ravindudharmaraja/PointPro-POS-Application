import 'package:dashboard_template_dribbble/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/media_query_values.dart';
import '../../utils/colors.dart';
import 'line_chart.dart';
import '../../providers/analytics_provider.dart'; // Import the analytics provider

class POSOverviewStatistic extends StatefulWidget {
  const POSOverviewStatistic({super.key});

  @override
  State<POSOverviewStatistic> createState() => _POSOverviewStatisticState();
}

class _POSOverviewStatisticState extends State<POSOverviewStatistic> {
  final List<String> _timePeriods = [
    'Today',
    'Week',
    'Month',
    'Quarter',
    'Year'
  ];
  int _selectedPeriod = 2;

  @override
  void initState() {
    super.initState();
    // Fetch analytics data when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyticsProvider>(context, listen: false).fetchAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final analyticsProvider = Provider.of<AnalyticsProvider>(context);
    final isLoading = analyticsProvider.isLoading;
    final analyticsData = analyticsProvider.analyticsData;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      width: context.width * 0.70,
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
      transform: Matrix4.translationValues(0, -70, 0),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with title and action icons
          Row(
            children: [
              Text(
                'Sales Overview',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              _buildIconButton(
                icon: Icons.insert_drive_file_rounded,
                color: colorScheme.onSurfaceVariant,
                onPressed: _exportReport,
              ),
              _buildIconButton(
                icon: Icons.star,
                color: primaryColor,
                onPressed: _toggleFavorite,
              ),
              _buildIconButton(
                icon: Icons.settings,
                color: colorScheme.onSurfaceVariant,
                onPressed: _openSettings,
              ),
            ],
          ),

          SizedBox(height: context.height * 0.028),

          // Sales summary with icon and amount
          Row(
            children: [
              Container(
                width: context.width * 0.05,
                height: context.height * 0.09,
                decoration: BoxDecoration(
                  color: chocolateMelange.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: const Icon(
                  Icons.point_of_sale,
                  color: primaryColor,
                  size: 34,
                ),
              ),
              SizedBox(width: context.width * 0.015),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Main Store Location (Downtown)',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: context.height * 0.012),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'LKR',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: context.width * 0.003),
                      Text(
                        isLoading
                            ? 'Loading...'
                            : analyticsData?.salesTotal.toStringAsFixed(2) ?? '0.00',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(width: context.width * 0.01),
                      const Icon(Icons.keyboard_arrow_up,
                          color: Colors.green, size: 18),
                      SizedBox(width: context.width * 0.003),
                      Text(
                        '+18%',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),

              // Time Period Selector
              Container(
                width: context.width * 0.31,
                height: context.height * 0.1,
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(18.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _timePeriods.asMap().entries.map((entry) {
                    final index = entry.key;
                    final period = entry.value;
                    return _timePeriodWidget(context, index, period);
                  }).toList(),
                ),
              ),
            ],
          ),

          SizedBox(height: context.height * 0.028),

          // Line chart for sales data
          if (analyticsData != null)
  SizedBox(
    height: context.height * 0.25,
    child: LineChartWidget(
      salesTrend: analyticsData.salesMonthlyTrend,
      purchasesTrend: analyticsData.purchasesMonthlyTrend,
    ),
  ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: IconButton(
        icon: Icon(icon, size: 22),
        color: color,
        onPressed: onPressed,
        splashRadius: 22,
        tooltip: icon.toString(),
      ),
    );
  }

  Widget _timePeriodWidget(BuildContext context, int index, String period) {
    final bool isSelected = _selectedPeriod == index;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = index;
          // Convert the selected index to the period string expected by the provider
          String periodParam;
          switch (index) {
            case 0:
              periodParam = 'today';
              break;
            case 1:
              periodParam = 'this_week';
              break;
            case 2:
              periodParam = 'this_month';
              break;
            case 3:
              periodParam = 'this_quarter';
              break;
            case 4:
              periodParam = 'this_year';
              break;
            default:
              periodParam = 'this_month';
          }
          Provider.of<AnalyticsProvider>(context, listen: false)
              .setSelectedPeriod(periodParam);
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        width: context.width * 0.056,
        height: context.height * 0.09,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14.0),
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.bottomRight,
                  end: Alignment.topLeft,
                  colors: [primaryColor, secondPrimaryColor],
                )
              : null,
          color: isSelected ? null : colorScheme.surfaceContainerHighest,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          period,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
        ),
      ),
    );
  }

  void _exportReport() {
    // TODO: Implement export
  }

  void _toggleFavorite() {
    // TODO: Implement favorite toggle
  }

  void _openSettings() {
    // TODO: Implement settings
  }
}