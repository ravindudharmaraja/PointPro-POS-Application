import 'package:dashboard_template_dribbble/providers/analytics_provider.dart';
import 'package:dashboard_template_dribbble/providers/pos_provider.dart';
import 'package:dashboard_template_dribbble/providers/settings_provider.dart';
import 'package:dashboard_template_dribbble/view/screens/pos/widgets/pos_screen_with_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import all necessary providers and screens
import '../widgets/side_bar.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'sales_screen.dart';
import 'orders_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'people/customers_screen.dart';
import 'people/suppliers_screen.dart';
import 'shop/products_screen.dart';
import 'shop/categories_screen.dart';
import 'print_barcode_screen.dart';
import 'auth/login.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/purchase_provider.dart';
import '../../providers/customer_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String _selectedRouteName = '/dashboard';
  bool _isSidebarExpanded = true;

  // Use Widget instances directly (no function)
  final Map<String, Widget> _pageRoutes = {
    '/dashboard': const DashboardScreen(),
    '/inventory': const InventoryPage(),
    '/sales': const SalesScreen(),
    '/orders': const OrdersScreen(),
    '/analytics': const AnalyticsScreen(),
    '/people/customers': const CustomersScreen(),
    '/people/suppliers': const SuppliersScreen(),
    '/shop/products': const ProductsScreen(),
    '/shop/categories': const CategoriesScreen(),
    '/settings': const SettingsScreen(),
    '/print-barcode': const PrintBarcodeScreen(),
    '/pos': const PosScreenWithDrawer(), // <-- widget instance, not function
    '/login': const LoginScreen(),
  };

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = _pageRoutes.values.toList();
  }

  void _onItemSelected(String routeName) {
    if (_pageRoutes.containsKey(routeName)) {
      setState(() {
        _selectedRouteName = routeName;
      });
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarExpanded = !_isSidebarExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _pageRoutes.keys.toList().indexOf(_selectedRouteName);
    final screenWidth = MediaQuery.of(context).size.width;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => SaleProvider()),
        ChangeNotifierProvider(create: (_) => PurchaseProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
      ],
      child: Scaffold(
        body: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              width: _isSidebarExpanded ? screenWidth * 0.16 : 80,
              child: SideBar(
                isExpanded: _isSidebarExpanded,
                selectedRouteName: _selectedRouteName,
                onItemSelected: _onItemSelected,
                onToggle: _toggleSidebar,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: selectedIndex != -1 ? selectedIndex : 0,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
