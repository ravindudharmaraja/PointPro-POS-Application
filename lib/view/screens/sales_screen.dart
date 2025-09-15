import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/header.dart';
import '../../providers/sale_provider.dart';

class SalesScreen extends StatelessWidget {
  const SalesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SaleProvider(),
      child: const _SalesScreenContent(),
    );
  }
}

class _SalesScreenContent extends StatefulWidget {
  const _SalesScreenContent();

  @override
  State<_SalesScreenContent> createState() => _SalesScreenContentState();
}

class _SalesScreenContentState extends State<_SalesScreenContent> {
  List<SaleRecord> _filteredSales = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;
  String? _selectedBiller;
  // ignore: unused_field
  SaleRecord? _selectedSaleForView;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterSales);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterSales();
  }

  void _filterSales() {
    final saleProvider = context.read<SaleProvider>();
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredSales = saleProvider.sales.where((sale) {
        final searchMatch = sale.referenceNo.toLowerCase().contains(query) ||
            sale.biller.toLowerCase().contains(query);

        final billerMatch =
            _selectedBiller == null || sale.biller == _selectedBiller;

        return searchMatch && billerMatch;
      }).toList();
      _currentPage = 1;
    });
  }

  void _showBillDetails(SaleRecord sale) {
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
                  'bill_details'.tr(),
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
                    _buildBillHeader(sale),
                    const SizedBox(height: 24),
                    _buildBillItemsTable(sale),
                    const SizedBox(height: 24),
                    _buildBillSummary(sale),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillHeader(SaleRecord sale) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'invoice_number'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              sale.referenceNo,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'date'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              sale.date,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'biller'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              sale.biller,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBillItemsTable(SaleRecord sale) {
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
          ...sale.items.map((item) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(item.productName),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      item.quantity,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Rs. ${item.unitPrice}',
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      'Rs. ${item.subtotal}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildBillSummary(SaleRecord sale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('subtotal'.tr()),
            Text('Rs. ${sale.totalPrice.toStringAsFixed(2)}'),
          ],
        ),
        if (sale.discount != null && sale.discount! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('discount'.tr()),
                Text('- Rs. ${sale.discount!.toStringAsFixed(2)}'),
              ],
            ),
          ),
        if (sale.tax != null && sale.tax! > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('tax'.tr()),
                Text('Rs. ${sale.tax!.toStringAsFixed(2)}'),
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
              'Rs. ${sale.grandTotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            // Print or share functionality
          },
          child: Text('print_receipt'.tr()),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterSales);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Consumer<SaleProvider>(
      builder: (context, saleProvider, child) {
        if (!saleProvider.isLoading &&
            _filteredSales.isEmpty &&
            saleProvider.sales.isNotEmpty &&
            _searchController.text.isEmpty) {
          _filteredSales = saleProvider.sales;
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
                      _buildFilterSection(saleProvider.sales, theme),
                      const SizedBox(height: 20),
                      if (saleProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (saleProvider.errorMessage != null)
                        Center(
                          child: Text(
                            saleProvider.errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.error, fontSize: 16),
                          ),
                        )
                      else if (_filteredSales.isEmpty)
                        Center(
                          child: Text(
                            "no_sales_found".tr(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        _buildModernSalesList(theme),
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
          'sales_list'.tr(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: Icon(Icons.refresh, color: theme.colorScheme.primary),
          onPressed: () => context.read<SaleProvider>().refreshSales(),
        ),
      ],
    );
  }

  Widget _buildFilterSection(List<SaleRecord> allSales, ThemeData theme) {
    final billers = allSales.map((s) => s.biller).toSet().toList();

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
                    hintText: 'search_invoice_biller'.tr(),
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
                  value: _selectedBiller,
                  hint: Text('all_billers'.tr(), 
                    style: TextStyle(color: theme.hintColor)),
                  icon: Icon(Icons.arrow_drop_down, color: theme.hintColor),
                  elevation: 2,
                  underline: const SizedBox(),
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  items: billers
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedBiller = newValue;
                      _filterSales();
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
                  '${_filteredSales.length} ${'results_found'.tr()}',
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

  Widget _buildModernSalesList(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    final int totalEntries = _filteredSales.length;
    final int totalPages =
        totalEntries > 0 ? (totalEntries / _rowsPerPage).ceil() : 1;
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = min(startIndex + _rowsPerPage, totalEntries);
    final List<SaleRecord> pagedSales =
        _filteredSales.sublist(startIndex, endIndex);

    return Column(
      children: [
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: pagedSales.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final sale = pagedSales[index];
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
                onTap: () => _showBillDetails(sale),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            sale.referenceNo,
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
                              'Rs. ${sale.grandTotal.toStringAsFixed(2)}',
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
                        sale.biller,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [

                          Icon(
                            Icons.list_alt,
                            size: 16,
                            color: theme.hintColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${sale.items.length} ${'items'.tr()}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                            ),
                          ),
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
}