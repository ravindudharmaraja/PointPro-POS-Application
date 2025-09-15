import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../widgets/header.dart';
import 'dart:math';

// Data model for a single supplier record
class SupplierRecord {
  final int sl;
  final String companyName;
  final String name;
  final String email;
  final String phoneNumber;
  final String address;

  SupplierRecord({
    required this.sl,
    required this.companyName,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.address,
  });
}

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final List<SupplierRecord> _allSuppliers = List.generate(
    50,
    (index) => SupplierRecord(
      sl: index + 1,
      companyName: 'Supplier Co ${index + 1}',
      name: 'Person ${index + 1}',
      email: 'supplier${index + 1}@example.com',
      phoneNumber: '077-123-45${index.toString().padLeft(2, '0')}',
      address: 'No.${index + 1}, Some Street, Some Town',
    ),
  );

  List<SupplierRecord> _filteredSuppliers = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;
  int? _hoveredRowIndex;

  @override
  void initState() {
    super.initState();
    _filteredSuppliers = _allSuppliers;
    _searchController.addListener(_filterSuppliers);
  }

  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSuppliers = _allSuppliers.where((supplier) {
        return supplier.name.toLowerCase().contains(query) ||
            supplier.companyName.toLowerCase().contains(query) ||
            supplier.email.toLowerCase().contains(query);
      }).toList();
      _currentPage = 1; // Reset to first page after search
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;

    final int totalEntries = _filteredSuppliers.length;
    final int totalPages = (totalEntries / _rowsPerPage).ceil();
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = min(startIndex + _rowsPerPage, totalEntries);

    return Scaffold(
      backgroundColor: backgroundColor,
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
                  // Header Row with Title and Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Supplier List'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Handle import from Excel
                            },
                            icon: const Icon(Icons.file_upload, size: 18),
                            label: Text('Import Suppliers'.tr()),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: theme.colorScheme.secondary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              // TODO: Handle add supplier
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: Text('Add Supplier'.tr()),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Search and Table
                  _buildSuppliersCard(
                      startIndex, endIndex, totalEntries, totalPages, theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuppliersCard(int startIndex, int endIndex, int totalEntries,
      int totalPages, ThemeData theme) {
    final primaryColor = theme.colorScheme.primary;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final cardColor = theme.cardColor;
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.white;
    final textSecondaryColor = theme.textTheme.bodyMedium?.color ?? Colors.white70;
    final dividerColor = theme.dividerColor;

    final List<SupplierRecord> pagedSuppliers =
        _filteredSuppliers.sublist(startIndex, endIndex);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Search
          Row(
            children: [
              Text('Suppliers'.tr(),
                  style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const Spacer(),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Search by name, company, or email...'.tr(),
                    hintStyle: TextStyle(color: textSecondaryColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: textSecondaryColor, size: 20),
                    filled: true,
                    fillColor: backgroundColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              )
            ],
          ),
          Divider(color: dividerColor, height: 40),

          // Rows per page selector
          Row(
            children: [
              Text("Show ".tr(), style: TextStyle(color: textSecondaryColor)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: dividerColor),
                ),
                child: DropdownButton<int>(
                  value: _rowsPerPage,
                  dropdownColor: backgroundColor,
                  style: TextStyle(color: textColor),
                  items: [10, 25, 50, 100].map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _rowsPerPage = newValue!;
                      _currentPage = 1; // Reset to first page
                    });
                  },
                  underline: const SizedBox(),
                ),
              ),
              Text(" entries".tr(), style: TextStyle(color: textSecondaryColor)),
            ],
          ),
          const SizedBox(height: 20),

          // Data table
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 20,
              dataRowMinHeight: 52,
              dataRowMaxHeight: 52,
              headingRowColor:
                  WidgetStateProperty.all(backgroundColor.withOpacity(0.5)),
              columns: [
                DataColumn(
                    label: Text('SL'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Company Name'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Name'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Email'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Phone Number'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Address'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action'.tr(),
                        style: TextStyle(
                            color: textSecondaryColor,
                            fontWeight: FontWeight.bold))),
              ],
              rows: List.generate(pagedSuppliers.length, (index) {
                final supplier = pagedSuppliers[index];
                return DataRow(
                  color: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                      final isHovered = _hoveredRowIndex == index;
                      if (isHovered) return primaryColor.withOpacity(0.1);
                      return index.isEven
                          ? backgroundColor.withOpacity(0.3)
                          : Colors.transparent;
                    },
                  ),
                  onLongPress: () {
                    setState(() {
                      _hoveredRowIndex = index;
                    });
                  },
                  cells: [
                    DataCell(Text(supplier.sl.toString(),
                        style: TextStyle(color: textColor))),
                    DataCell(Text(supplier.companyName,
                        style: TextStyle(color: textColor))),
                    DataCell(Text(supplier.name, style: TextStyle(color: textColor))),
                    DataCell(Text(supplier.email, style: TextStyle(color: textColor))),
                    DataCell(Text(supplier.phoneNumber,
                        style: TextStyle(color: textColor))),
                    DataCell(Text(supplier.address, style: TextStyle(color: textColor))),
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          // TODO: Handle action like view/edit/delete
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
                          PopupMenuItem<String>(
                            value: 'view',
                            child: ListTile(
                                leading: const Icon(Icons.visibility),
                                title: Text('View'.tr())),
                          ),
                          PopupMenuItem<String>(
                            value: 'edit',
                            child: ListTile(
                                leading: const Icon(Icons.edit),
                                title: Text('Edit'.tr())),
                          ),
                          PopupMenuItem<String>(
                            value: 'delete',
                            child: ListTile(
                                leading: const Icon(Icons.delete),
                                title: Text('Delete'.tr())),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, color: textColor),
                        color: cardColor,
                        tooltip: "Actions".tr(),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Pagination controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${startIndex + 1} to $endIndex of $totalEntries entries'
                    .tr(),
                style: TextStyle(color: textSecondaryColor, fontSize: 14),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: Icon(Icons.chevron_left, color: textColor),
                    disabledColor: Colors.grey,
                  ),
                  Text('Page $_currentPage of $totalPages'.tr(),
                      style: TextStyle(color: textColor)),
                  IconButton(
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: Icon(Icons.chevron_right, color: textColor),
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
