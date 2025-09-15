import 'package:flutter/material.dart';

// Assuming these are in your project
import '../widgets/header.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/overview_statistic_widget.dart';
import '../widgets/stock_widget.dart';

// No provider imports are needed here because this widget only consumes them.

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This widget will now use the providers created by its parent (MainScreen).
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Header(),
            Padding(
              padding: EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main content area
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        POSDashboardCard(),
                        SizedBox(height: 10),
                        POSOverviewStatistic(),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  // Inventory/Side content area
                  Expanded(
                    flex: 1,
                    child: POSInventoryWidget(),
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
