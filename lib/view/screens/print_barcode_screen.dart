import 'package:flutter/material.dart';
import '../../view/widgets/header.dart';

class ProductToPrint {
  final String name;
  final String code;
  final double price;
  final double promotionalPrice;
  int quantity;

  ProductToPrint({
    required this.name,
    required this.code,
    required this.price,
    required this.promotionalPrice,
    this.quantity = 1,
  });
}

class PrintBarcodeScreen extends StatefulWidget {
  const PrintBarcodeScreen({super.key});

  @override
  State<PrintBarcodeScreen> createState() => _PrintBarcodeScreenState();
}

class _PrintBarcodeScreenState extends State<PrintBarcodeScreen> {
  final List<ProductToPrint> _productsToPrint = [];
  final TextEditingController _searchController = TextEditingController();

  final List<ProductToPrint> _searchResults = [
    ProductToPrint(
        name: 'Ice Cream Cones (WS)',
        code: '00000001',
        price: 700.00,
        promotionalPrice: 640.00),
    ProductToPrint(
        name: 'Chocolate Bar',
        code: '00000002',
        price: 150.00,
        promotionalPrice: 120.00),
    ProductToPrint(
        name: 'Soda Can',
        code: '00000003',
        price: 80.00,
        promotionalPrice: 75.00),
  ];

  void _addProductToList(ProductToPrint product) {
    setState(() {
      final existingIndex =
          _productsToPrint.indexWhere((p) => p.code == product.code);
      if (existingIndex != -1) {
        _productsToPrint[existingIndex].quantity++;
      } else {
        _productsToPrint.add(ProductToPrint(
          name: product.name,
          code: product.code,
          price: product.price,
          promotionalPrice: product.promotionalPrice,
          quantity: 1,
        ));
      }
    });
  }

  TextStyle _titleStyle(ThemeData theme) =>
      TextStyle(color: theme.colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.w600);

  TextStyle _sectionTitleStyle(ThemeData theme) =>
      TextStyle(color: theme.colorScheme.onSurface, fontSize: 16, fontWeight: FontWeight.bold);

  TextStyle _textStyleWhite(ThemeData theme) =>
      TextStyle(color: theme.colorScheme.onSurface);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            const Header(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Print Barcode', style: _titleStyle(theme)),
                      // Uncomment and customize the button when ready
                      // ElevatedButton.icon(
                      //   onPressed: _productsToPrint.isNotEmpty ? _generateBarcodePdf : null,
                      //   icon: const Icon(Icons.print, size: 18),
                      //   label: const Text('Print Barcodes'),
                      //   style: ElevatedButton.styleFrom(
                      //     foregroundColor: Colors.white,
                      //     backgroundColor: theme.colorScheme.primary,
                      //     disabledBackgroundColor: Colors.grey.withOpacity(0.5),
                      //     padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildAddProductSection(theme),
                  const SizedBox(height: 24),
                  _buildPrintQueueCard(theme),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add Product*', style: _sectionTitleStyle(theme)),
          const SizedBox(height: 16),
          Autocomplete<ProductToPrint>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<ProductToPrint>.empty();
              }
              final query = textEditingValue.text.toLowerCase();
              return _searchResults.where((p) =>
                  p.name.toLowerCase().contains(query) ||
                  p.code.contains(query));
            },
            displayStringForOption: (option) => '${option.name} (${option.code})',
            fieldViewBuilder: (context, fieldController, focusNode, onSubmitted) {
              return TextField(
                controller: fieldController,
                focusNode: focusNode,
                style: TextStyle(color: theme.colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search product by name or code...',
                  hintStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.54)),
                  prefixIcon: Icon(Icons.search, color: theme.colorScheme.onSurface.withOpacity(0.54)),
                  filled: true,
                  fillColor: theme.scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              );
            },
            onSelected: (selection) {
              _addProductToList(selection);
              _searchController.clear();
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 6,
                  color: theme.cardColor,
                  child: Container(
                    width: 600,
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option.name, style: _textStyleWhite(theme)),
                          subtitle: Text(option.code,
                              style: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.7))),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrintQueueCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.7),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Print Queue', style: _sectionTitleStyle(theme)),
          Divider(color: theme.dividerColor, height: 30),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(theme.scaffoldBackgroundColor.withOpacity(0.6)),
              dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                  (states) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.primary.withOpacity(0.3);
                }
                return null;
              }),
              columns: [
                DataColumn(
                    label: Text('Name',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Code',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Quantity',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold))),
                DataColumn(
                    label: Text('Action',
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                            fontWeight: FontWeight.bold))),
              ],
              rows: _productsToPrint.map((product) {
                return DataRow(cells: [
                  DataCell(Text(product.name, style: _textStyleWhite(theme))),
                  DataCell(Text(product.code, style: _textStyleWhite(theme))),
                  DataCell(Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove,
                            color: theme.colorScheme.onSurface.withOpacity(0.7), size: 18),
                        onPressed: () {
                          setState(() {
                            if (product.quantity > 1) product.quantity--;
                          });
                        },
                      ),
                      Text(product.quantity.toString(),
                          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16)),
                      IconButton(
                        icon:
                            Icon(Icons.add, color: theme.colorScheme.onSurface.withOpacity(0.7), size: 18),
                        onPressed: () {
                          setState(() {
                            product.quantity++;
                          });
                        },
                      ),
                    ],
                  )),
                  DataCell(IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setState(() {
                        _productsToPrint.removeWhere((p) => p.code == product.code);
                      });
                    },
                  )),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
