import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

// Assuming these are in your project
import '../../widgets/header.dart';
import '../../../providers/product_provider.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: const _ProductsScreenContent(),
    );
  }
}

class _ProductsScreenContent extends StatefulWidget {
  const _ProductsScreenContent();

  @override
  State<_ProductsScreenContent> createState() => _ProductsScreenContentState();
}

class _ProductsScreenContentState extends State<_ProductsScreenContent> {
  List<ProductRecord> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  int _rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterProducts);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterProducts();
  }

  void _filterProducts() {
    final productProvider = context.read<ProductProvider>();
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredProducts = productProvider.products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.code.toLowerCase().contains(query) ||
            product.brand.toLowerCase().contains(query) ||
            product.category.toLowerCase().contains(query);
      }).toList();
      _currentPage = 1;
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterProducts);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        if (!productProvider.isLoading &&
            _filteredProducts.isEmpty &&
            productProvider.products.isNotEmpty &&
            _searchController.text.isEmpty) {
          _filteredProducts = productProvider.products;
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
                        Center(
                            child: Padding(
                                padding: const EdgeInsets.all(50.0),
                                child: CircularProgressIndicator(
                                    color: theme.colorScheme.primary)))
                      else if (productProvider.errorMessage != null)
                        Center(
                            child: Text(productProvider.errorMessage!,
                                style: TextStyle(
                                    color: theme.colorScheme.error, fontSize: 16)))
                      else if (productProvider.products.isEmpty)
                        Center(
                            child: Text("No products found.",
                                style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    fontSize: 16)))
                      else
                        _buildProductsCard(theme),
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
        Text('Product List',
            style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface)),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Import Products
              },
              icon: const Icon(Icons.file_upload),
              label: const Text('Import Products'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement Add Product
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: theme.colorScheme.primary,
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

  Widget _buildProductsCard(ThemeData theme) {
    final int totalEntries = _filteredProducts.length;
    final int totalPages =
        totalEntries > 0 ? (totalEntries / _rowsPerPage).ceil() : 1;
    final int startIndex = (_currentPage - 1) * _rowsPerPage;
    final int endIndex = min(startIndex + _rowsPerPage, totalEntries);
    final List<ProductRecord> pagedProducts =
        _filteredProducts.sublist(startIndex, endIndex);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text("Show ", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: DropdownButton<int>(
                      value: _rowsPerPage,
                      dropdownColor: theme.scaffoldBackgroundColor,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      items: [10, 25, 50, 100]
                          .map((int value) => DropdownMenuItem<int>(
                              value: value, child: Text(value.toString())))
                          .toList(),
                      onChanged: (newValue) => setState(() {
                        _rowsPerPage = newValue!;
                        _currentPage = 1;
                      }),
                      underline: const SizedBox(),
                    ),
                  ),
                  Text(" entries", style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                ],
              ),
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: theme.colorScheme.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.5), fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.5), size: 20),
                    filled: true,
                    fillColor: theme.scaffoldBackgroundColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              )
            ],
          ),
          Divider(color: theme.dividerColor, height: 30),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 75,
              columns: [
                DataColumn(label: Text('ID', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Image', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Name', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Code', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Brand', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Category', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Quantity', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Unit Price', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
                DataColumn(label: Text('Action', style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7)))),
              ],
              rows: pagedProducts.map((product) {
                return DataRow(
                  cells: [
                    DataCell(Text(product.id.toString(),
                        style: TextStyle(color: theme.colorScheme.onSurface))),
                    DataCell(
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: theme.dividerColor,
                        backgroundImage: NetworkImage(product.thumbnail),
                        onBackgroundImageError: (_, __) {},
                        child: product.thumbnail.isEmpty
                            ? Icon(Icons.image, color: theme.colorScheme.onSurface.withOpacity(0.4))
                            : null,
                      ),
                    ),
                    DataCell(Text(product.name,
                        style: TextStyle(color: theme.colorScheme.onSurface))),
                    DataCell(Text(product.code,
                        style: TextStyle(color: theme.colorScheme.onSurface))),
                    DataCell(Text(product.brand,
                        style: TextStyle(color: theme.colorScheme.onSurface))),
                    DataCell(Text(product.category,
                        style: TextStyle(color: theme.colorScheme.onSurface))),
                    DataCell(Text('${product.qty} ${product.unit}',
                        style: TextStyle(color: theme.colorScheme.onSurface))),
                    DataCell(Text('Rs. ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold))),
                    DataCell(
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          // TODO: Implement actions like view, edit, delete
                        },
                        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(value: 'view', child: Text('View')),
                          const PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem<String>(value: 'delete', child: Text('Delete')),
                        ],
                        icon: Icon(Icons.more_vert, color: theme.colorScheme.onSurface),
                        color: theme.cardColor,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing ${totalEntries > 0 ? startIndex + 1 : 0} to $endIndex of $totalEntries entries',
                style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7), fontSize: 14),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => setState(() => _currentPage--)
                        : null,
                    icon: const Icon(Icons.chevron_left),
                    color: theme.colorScheme.onSurface,
                    disabledColor: theme.disabledColor,
                  ),
                  Text('Page $_currentPage of $totalPages',
                      style: TextStyle(color: theme.colorScheme.onSurface)),
                  IconButton(
                    onPressed: _currentPage < totalPages
                        ? () => setState(() => _currentPage++)
                        : null,
                    icon: const Icon(Icons.chevron_right),
                    color: theme.colorScheme.onSurface,
                    disabledColor: theme.disabledColor,
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
