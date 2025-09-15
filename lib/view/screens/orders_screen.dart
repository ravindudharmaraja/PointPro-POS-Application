import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/header.dart';
import '../../providers/purchase_provider.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PurchaseProvider(),
      child: const _OrdersScreenContent(),
    );
  }
}

class _OrdersScreenContent extends StatefulWidget {
  const _OrdersScreenContent();

  @override
  State<_OrdersScreenContent> createState() => _OrdersScreenContentState();
}

class _OrdersScreenContentState extends State<_OrdersScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;
  String? _selectedSupplier;
  String? _selectedStatus;
  get startIndex => null;
  get endIndex => null;
  List<PurchaseRecord> _filteredOrders = [];
  
 

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterOrders);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _filterOrders());
  }

  void _filterOrders() {
    final purchaseProvider = context.read<PurchaseProvider>();
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredOrders = purchaseProvider.purchases.where((order) {
        final searchMatch = order.referenceNo.toLowerCase().contains(query) ||
            order.supplier.toLowerCase().contains(query);
        final supplierMatch =
            _selectedSupplier == null || order.supplier == _selectedSupplier;
        final statusMatch =
            _selectedStatus == null || order.purchaseStatus == _selectedStatus;
        return searchMatch && supplierMatch && statusMatch;
      }).toList();
      _currentPage = 1;
    });
  }

  void _showOrderDetails(PurchaseRecord order) {
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
                  'order_details'.tr(),
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
                    _buildOrderHeader(order),
                    const SizedBox(height: 24),
                    _buildOrderItemsTable(order),
                    const SizedBox(height: 24),
                    _buildOrderSummary(order),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader(PurchaseRecord order) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'reference_number'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              order.referenceNo,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'date'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              order.date,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'supplier'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              order.supplier,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'status'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            _buildStatusChip(order.purchaseStatus, Theme.of(context)),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderItemsTable(PurchaseRecord order) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Table(
        border: TableBorder.symmetric(
          inside: BorderSide(color: Theme.of(context).dividerColor),
        ),
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1.5),
          3: FlexColumnWidth(1.5),
        },
        children: [
          TableRow(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'item'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'qty'.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'unit_price'.tr(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'total'.tr(),
                  textAlign: TextAlign.right,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          
        ],
      ),
    );
  }

  Widget _buildOrderSummary(PurchaseRecord order) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('grandTotal'.tr()),
            Text('Rs. ${order.grandTotal.toStringAsFixed(2)}'),
          ],
        ),
        if (order.discount != null && order.discount! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('discount'.tr()),
                Text('- Rs. ${order.discount!.toStringAsFixed(2)}'),
              ],
            ),
          ),
        if (order.tax != null && order.tax! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('tax'.tr()),
                Text('Rs. ${order.tax!.toStringAsFixed(2)}'),
              ],
            ),
          ),
        const Divider(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'total'.tr(),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Rs. ${order.grandTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Print or share functionality
          },
          child: Text('print_order'.tr()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterOrders);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<PurchaseProvider>(
      builder: (context, purchaseProvider, child) {
        if (!purchaseProvider.isLoading &&
            _filteredOrders.isEmpty &&
            purchaseProvider.purchases.isNotEmpty &&
            _searchController.text.isEmpty) {
          _filteredOrders = purchaseProvider.purchases;
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
                      _buildFilterSection(purchaseProvider.purchases, theme),
                      const SizedBox(height: 20),
                      if (purchaseProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (purchaseProvider.errorMessage != null)
                        Center(
                          child: Text(
                            purchaseProvider.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error, fontSize: 16),
                          ),
                        )
                      else if (_filteredOrders.isEmpty)
                        Center(
                          child: Text(
                            "no_orders_found".tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        _buildModernOrdersList(theme),
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
          'order_list'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
          label: Text('add_order'.tr()),
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

  Widget _buildFilterSection(List<PurchaseRecord> allOrders, ThemeData theme) {
    final suppliers = allOrders.map((o) => o.supplier).toSet().toList();
    final statuses = allOrders.map((o) => o.purchaseStatus).toSet().toList();

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
                    hintText: 'search_reference_supplier'.tr(),
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
                  value: _selectedSupplier,
                  hint: Text('all_suppliers'.tr(), 
                    style: TextStyle(color: theme.hintColor)),
                  icon: Icon(Icons.arrow_drop_down, color: theme.hintColor),
                  elevation: 2,
                  underline: const SizedBox(),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  items: suppliers
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedSupplier = newValue;
                      _filterOrders();
                    });
                  },
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
                  value: _selectedStatus,
                  hint: Text('all_statuses'.tr(), 
                    style: TextStyle(color: theme.hintColor)),
                  icon: Icon(Icons.arrow_drop_down, color: theme.hintColor),
                  elevation: 2,
                  underline: const SizedBox(),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  items: statuses
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedStatus = newValue;
                      _filterOrders();
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
                  '${_filteredOrders.length} ${'results_found'.tr()}',
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

  Widget _buildModernOrdersList(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    final int totalEntries = _filteredOrders.length;
    final int totalPages =
        totalEntries > 0 ? (totalEntries / _rowsPerPage).ceil() : 1;
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = min(startIndex + _rowsPerPage, totalEntries);
    final List<PurchaseRecord> pagedOrders =
        _filteredOrders.sublist(startIndex, endIndex);

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: pagedOrders.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = pagedOrders[index];
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
                onTap: () => _showOrderDetails(order),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            order.referenceNo,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Rs. ${order.grandTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        order.supplier,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            order.date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
                          const Spacer(),
                          _buildStatusChip(order.purchaseStatus, theme),
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

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color color;
    switch (status.toLowerCase()) {
      case 'paid':
      case 'received':
        color = Colors.green;
        break;
      case 'due':
      case 'pending':
        color = Colors.red;
        break;
      case 'partial':
        color = Colors.orange;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        status,
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color.withOpacity(0.5)),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
    );
  }
}

extension on String {
  toStringAsFixed(int i) {}
}