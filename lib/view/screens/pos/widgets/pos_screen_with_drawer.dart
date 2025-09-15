import 'package:flutter/material.dart';
import 'awesome_drawer_bar.dart';
import 'menu_screen.dart';
import '../pos_screen.dart';
import '../refund_screen.dart';
import '../hold_bill_screen.dart';
import '../customers_screen.dart';

class PosScreenWithDrawer extends StatefulWidget {
  const PosScreenWithDrawer({super.key});

  @override
  State<PosScreenWithDrawer> createState() => _PosScreenWithDrawerState();
}

class _PosScreenWithDrawerState extends State<PosScreenWithDrawer> {
  final drawerController = AwesomeDrawerBarController();
  String _selectedRoute = 'pos';

  final List<String> _routes = ['pos', 'refund', 'hold_bill', 'customers'];

  int _getSelectedIndex(String route) => _routes.indexOf(route);

  Widget _getScreen(String route) {
    switch (route) {
      case 'refund':
        return RefundScreen(drawerController: drawerController);
      case 'hold_bill':
        return HoldBillScreen(drawerController: drawerController);
      case 'customers':
        return POSCustomersScreen(drawerController: drawerController);
      case 'pos':
      default:
        return PosScreen(drawerController: drawerController);
    }
  }

  void _handleMenuSelect(String route) {
    setState(() {
      _selectedRoute = route;
    });
    drawerController.close?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AwesomeDrawerBar(
      controller: drawerController,
      type: StyleState.scaleRotate,
      slideWidth: 270,
      borderRadius: 20,
      angle: 8,
      showShadow: true,
      backgroundColor: const Color.fromARGB(255, 8, 8, 8),
      disableOnCickOnMainScreen: true,
      menuScreen: MenuScreen(onSelect: _handleMenuSelect),

      // Main screen shown on top with animation
      mainScreen: _getScreen(_selectedRoute),

      // Background layer: show all screens faintly behind main screen & drawer
      otherScreens: Opacity(
        opacity: 1,
        child: IndexedStack(
          index: _getSelectedIndex(_selectedRoute),
          children: [
            PosScreen(drawerController: drawerController),
            RefundScreen(drawerController: drawerController),
            HoldBillScreen(drawerController: drawerController),
            POSCustomersScreen(drawerController: drawerController),
          ],
        ),
      ),
    );
  }
}
