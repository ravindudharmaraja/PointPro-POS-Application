import 'package:dashboard_template_dribbble/providers/customer_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import '../../widgets/header.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CustomerProvider(),
      child: const _CustomersScreenContent(),
    );
  }
}

class _CustomersScreenContent extends StatefulWidget {
  const _CustomersScreenContent();

  @override
  State<_CustomersScreenContent> createState() =>
      _CustomersScreenContentState();
}

class _CustomersScreenContentState extends State<_CustomersScreenContent> {
  List<CustomerRecord> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterCustomers();
  }

  void _filterCustomers() {
    final customerProvider = context.read<CustomerProvider>();
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredCustomers = customerProvider.customers.where((customer) {
        return customer.companyName.toLowerCase().contains(query) ||
            customer.email.toLowerCase().contains(query) ||
            customer.phoneNumber.toLowerCase().contains(query);
      }).toList();
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterCustomers);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<CustomerProvider>(
      builder: (context, customerProvider, child) {
        if (!customerProvider.isLoading &&
            _filteredCustomers.isEmpty &&
            customerProvider.customers.isNotEmpty &&
            _searchController.text.isEmpty) {
          _filteredCustomers = customerProvider.customers;
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
                      if (customerProvider.isLoading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(50.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (customerProvider.errorMessage != null)
                        Center(
                          child: Text(
                            customerProvider.errorMessage!,
                            style: const TextStyle(
                                color: Colors.redAccent, fontSize: 16),
                          ),
                        )
                      else if (_filteredCustomers.isEmpty)
                        Center(
                          child: Text(
                            'No customers found.'.tr(),
                            style: TextStyle(
                              color: theme.textTheme.bodyMedium?.color,
                              fontSize: 16,
                            ),
                          ),
                        )
                      else
                        _buildCustomersCard(theme),
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
    final primaryColor = theme.colorScheme.primary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Customer List'.tr(),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_upload, size: 18),
              label: Text('Import Customers'.tr()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: theme.colorScheme.secondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 18),
              label: Text('Add Customer'.tr()),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCustomersCard(ThemeData theme) {
    final int totalEntries = _filteredCustomers.length;
    final int totalPages =
        totalEntries > 0 ? (totalEntries / _rowsPerPage).ceil() : 1;
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = min(startIndex + _rowsPerPage, totalEntries);
    final List<CustomerRecord> pagedCustomers =
        _filteredCustomers.sublist(startIndex, endIndex);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text('Show '.tr(),
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: theme.dividerColor)),
                    child: DropdownButton<int>(
                      value: _rowsPerPage,
                      dropdownColor: theme.scaffoldBackgroundColor,
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                      items: [10, 25, 50, 100]
                          .map((int value) => DropdownMenuItem<int>(
                              value: value,
                              child: Text(value.toString(),
                                  style: TextStyle(
                                      color: theme.textTheme.bodyLarge?.color))))
                          .toList(),
                      onChanged: (newValue) => setState(() {
                        _rowsPerPage = newValue!;
                        _currentPage = 1;
                      }),
                      underline: const SizedBox(),
                    ),
                  ),
                  Text(' entries'.tr(),
                      style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
                ],
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'Search by company, email, or phone...'.tr(),
                    hintStyle: TextStyle(
                        color: theme.textTheme.bodyMedium?.color, fontSize: 14),
                    prefixIcon: Icon(Icons.search,
                        color: theme.textTheme.bodyMedium?.color, size: 20),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 20,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 52,
              headingRowColor: WidgetStateProperty.all(
                  theme.scaffoldBackgroundColor.withOpacity(0.5)),
              columns: [
                DataColumn(
                    label: Text('ID'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Group Name'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Company Name'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Email'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Phone Number'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Tax Number'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action'.tr(),
                        style: TextStyle(
                            color: theme.textTheme.bodyMedium?.color,
                            fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(pagedCustomers.length, (index) {
                final customer = pagedCustomers[index];
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>((states) =>
                      index.isEven
                          ? theme.scaffoldBackgroundColor.withOpacity(0.3)
                          : Colors.transparent),
                  cells: [
                    DataCell(Text(customer.id.toString(),
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
                    DataCell(Text(customer.groupName,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
                    DataCell(Text(customer.companyName,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
                    DataCell(Text(customer.email,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
                    DataCell(Text(customer.phoneNumber,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
                    DataCell(Text(customer.taxNumber,
                        style: TextStyle(color: theme.textTheme.bodyLarge?.color))),
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (value) {},
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'view',
                            child: ListTile(
                              leading: const Icon(Icons.visibility),
                              title: Text('View'.tr()),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                              leading: const Icon(Icons.edit),
                              title: Text('Edit'.tr()),
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                              leading: const Icon(Icons.delete),
                              title: Text('Delete'.tr()),
                            ),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: theme.iconTheme.color),
                        color: theme.cardColor,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${totalEntries > 0 ? startIndex + 1 : 0} to $endIndex of $totalEntries entries'
                    .tr(),
                style: TextStyle(color: theme.textTheme.bodyMedium?.color, fontSize: 14),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: Icon(Icons.chevron_left, color: theme.iconTheme.color),
                    disabledColor: Colors.grey,
                  ),
                  Text('Page $_currentPage of $totalPages'.tr(),
                      style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
                  IconButton(
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: Icon(Icons.chevron_right, color: theme.iconTheme.color),
                    disabledColor: Colors.grey,
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}
