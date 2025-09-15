import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../widgets/header.dart';
import '../../providers/product_provider.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const _InventoryPageContent(),
    );
  }
}

class _InventoryPageContent extends StatefulWidget {
  const _InventoryPageContent();

  @override
  State<_InventoryPageContent> createState() => _InventoryPageContentState();
}

class _InventoryPageContentState extends State<_InventoryPageContent> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;
  String? _selectedCategory;
  List<ProductRecord> _filteredInventoryItems = [];
  
  get endIndex => null;
  
  get startIndex => null;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterInventory);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _filterInventory());
  }

  void _filterInventory() {
    final productProvider = context.read<ProductProvider>();
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredInventoryItems = productProvider.products.where((item) {
        final searchMatch = item.name.toLowerCase().contains(query) ||
            item.code.toLowerCase().contains(query);
        final categoryMatch =
            _selectedCategory == null || item.category == _selectedCategory;
        return searchMatch && categoryMatch;
      }).toList();
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInventory);
    _searchController.dispose();
    super.dispose();
  }

  void _showItemDetails(ProductRecord item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'item_details'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildItemHeader(item),
                    const SizedBox(height: 24),
                    _buildItemDetails(item),
                    const SizedBox(height: 24),
                    _buildStockHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemHeader(ProductRecord item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          
        )),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${'sku'.tr()}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    item.code,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    '${'category'.tr()}: ',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    item.category,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItemDetails(ProductRecord item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'details'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1),
              3: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'price'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'LKR${item.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'cost'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'LKR${item.code.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'stock'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      item.qty.toString(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: item.qty < 20 
                          ? Colors.orange 
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'alert_qty'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '20',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'tax'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${item.taxRate}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'unit'.tr(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      item.unit,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
    ],
    );
  }

  Widget _buildStockHistory() {
    // Placeholder for stock history
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'stock_history'.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              'no_stock_history_available'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (!productProvider.isLoading &&
            _filteredInventoryItems.isEmpty &&
            productProvider.products.isNotEmpty &&
            _searchController.text.isEmpty) {
          _filteredInventoryItems = productProvider.products;
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                      _buildHeader(theme),
                      const SizedBox(height: 20),
                      if (productProvider.isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        _buildSummarySection(productProvider.products, theme),
                      const SizedBox(height: 20),
                      _buildFilterSection(productProvider.products, theme),
                      const SizedBox(height: 20),
                      if (productProvider.isLoading)
                        const SizedBox.shrink()
                      else if (productProvider.errorMessage != null)
                        Center(
                          child: Text(
                            productProvider.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error, fontSize: 16),
                          ),
                        )
                      else if (_filteredInventoryItems.isEmpty)
                        Center(
                          child: Text(
                            "no_inventory_items_found".tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        _buildModernInventoryList(theme),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'inventory_list'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: Text('add_item'.tr()),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummarySection(List<ProductRecord> items, ThemeData theme) {
    final totalItems = items.length;
    final lowStockItems = items.where((item) => item.qty < 20 && item.qty > 0).length;
    final outOfStockItems = items.where((item) => item.qty == 0).length;
    final totalValue = items.fold(0.0, (sum, item) => sum + (item.price * item.qty));

    return SizedBox(
      height: 150,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildSummaryCard(
            title: 'total_items'.tr(),
            value: '$totalItems',
            icon: Icons.inventory_2,
            color: theme.colorScheme.primary,
            theme: theme,
          ),
          _buildSummaryCard(
            title: 'low_stock'.tr(),
            value: '$lowStockItems',
            icon: Icons.warning,
            color: Colors.orange,
            theme: theme,
          ),
          _buildSummaryCard(
            title: 'out_of_stock'.tr(),
            value: '$outOfStockItems',
            icon: Icons.error,
            color: theme.colorScheme.error,
            theme: theme,
          ),
          _buildSummaryCard(
            title: 'total_value'.tr(),
            value: 'LKR${totalValue.toStringAsFixed(2)}',
            icon: Icons.attach_money,
            color: Colors.green,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14
                  )),
              const SizedBox(height: 5),
              Text(value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold
                  )),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterSection(List<ProductRecord> allItems, ThemeData theme) {
    final categories = allItems.map((item) => item.category).toSet().toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'search_by_name_or_sku'.tr(),
                    prefixIcon: Icon(Icons.search, color: theme.hintColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('all_categories'.tr(), 
                    style: TextStyle(color: theme.hintColor)),
                  icon: Icon(Icons.arrow_drop_down, color: theme.hintColor),
                  elevation: 2,
                  underline: const SizedBox(),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  items: categories
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue;
                      _filterInventory();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_filteredInventoryItems.length} ${'results_found'.tr()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<int>(
                  value: _rowsPerPage,
                  underline: const SizedBox(),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  items: [10, 25, 50, 100].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value ${'per_page'.tr()}'),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    setState(() {
                      _rowsPerPage = newValue!;
                      _currentPage = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInventoryList(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    final int totalEntries = _filteredInventoryItems.length;
    final int totalPages =
        totalEntries > 0 ? (totalEntries / _rowsPerPage).ceil() : 1;
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = min(startIndex + _rowsPerPage, totalEntries);
    final List<ProductRecord> pagedItems =
        _filteredInventoryItems.sublist(startIndex, endIndex);

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: pagedItems.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = pagedItems[index];
            final isLowStock = item.qty < 20;
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: theme.dividerColor.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showItemDetails(item),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: item.imageUrl != null 
                          ? Image.network(item.imageUrl!, fit: BoxFit.cover)
                          : Icon(Icons.inventory, color: theme.hintColor),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.code,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  '${'stock'.tr()}: ',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  item.qty.toString(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isLowStock 
                                      ? Colors.orange 
                                      : colorScheme.onSurface,
                                    fontWeight: isLowStock 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'LKR${item.price.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildStatusChip(item.category, theme),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        _buildPaginationControls(theme, totalEntries, totalPages),
      ],
    );
  }

  Widget _buildPaginationControls(
      ThemeData theme, int totalEntries, int totalPages) {
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${"showing".tr()} ${totalEntries > 0 ? (_currentPage - 1) * _rowsPerPage + 1 : 0} '
          '${"to".tr()} ${min(_currentPage * _rowsPerPage, totalEntries)} '
          '${"of".tr()} $totalEntries ${"entries".tr()}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
              onPressed: _currentPage > 1
                  ? () => setState(() => _currentPage--)
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: _currentPage > 1
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$_currentPage',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${"of".tr()} $totalPages',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
              onPressed: _currentPage < totalPages
                  ? () => setState(() => _currentPage++)
                  : null,
              style: IconButton.styleFrom(
                backgroundColor: _currentPage < totalPages
                    ? colorScheme.primary.withOpacity(0.1)
                    : Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String category, ThemeData theme) {
    return Chip(
      label: Text(
        category,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: 12,
        ),
      ),
      backgroundColor: theme.colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }
}

extension on String {
  toStringAsFixed(int i) {}
}