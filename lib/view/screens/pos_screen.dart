import 'package:flutter/material.dart';
import 'dart:math';
import '../../../utils/colors.dart';
// Import the new header

// Data Models
class PosProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  PosProduct({required this.id, required this.name, required this.category, required this.price, required this.imageUrl});
}

class CartItem {
  final PosProduct product;
  int quantity;
  double discount; // Discount for this specific item

  CartItem({required this.product, this.quantity = 1, this.discount = 0.0});

  // The subtotal for this cart item before any discounts
  double get subtotal => product.price * quantity;
  // The final total for this cart item after its discount
  double get totalPrice => subtotal - discount;
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  // --- State Variables ---
  final List<PosProduct> _allProducts = List.generate(
    50,
    (index) => PosProduct(
      id: 'prod_$index',
      name: 'Product ${index + 1}',
      category: ['Sweets', 'Beverages', 'Snacks', 'Bakery'][index % 4],
      price: 100.0 + Random().nextInt(1500),
      imageUrl: 'https://placehold.co/150x150/${(index % 2 == 0) ? "EFEFEF" : "DDEFEF"}/grey?text=Product',
    ),
  );

  List<PosProduct> _filteredProducts = [];
  final List<CartItem> _cartItems = [];
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _overallDiscountController = TextEditingController(text: "0.00");
  final TextEditingController _cashTenderedController = TextEditingController();
  
  double _overallDiscount = 0.0;
  bool _isFinalizingPayment = false;
  String _paymentMethod = 'Cash';
  double _changeDue = 0.0;
  final bool _isFullScreen = true; // Default to full screen

  // --- Lifecycle & Methods ---
  @override
  void initState() {
    super.initState();
    _filteredProducts = _allProducts;
    _searchController.addListener(_filterProducts);
    _overallDiscountController.addListener(() {
      setState(() {
        _overallDiscount = double.tryParse(_overallDiscountController.text) ?? 0.0;
      });
    });
      _cashTenderedController.addListener(_calculateChange);
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        final categoryMatch = _selectedCategory == 'All' || product.category == _selectedCategory;
        final searchMatch = product.name.toLowerCase().contains(query);
        return categoryMatch && searchMatch;
      }).toList();
    });
  }

  void _addToCart(PosProduct product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
      if (existingIndex != -1) {
        _cartItems[existingIndex].quantity++;
      } else {
        _cartItems.add(CartItem(product: product));
      }
    });
  }

  void _calculateChange() {
    final grandTotal = _calculateGrandTotal();
    final cashTendered = double.tryParse(_cashTenderedController.text) ?? 0.0;
    setState(() {
      _changeDue = cashTendered - grandTotal;
    });
  }
  
  double _calculateGrandTotal() {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + item.subtotal);
    double itemDiscounts = _cartItems.fold(0, (sum, item) => sum + item.discount);
    double totalAfterItemDiscounts = subtotal - itemDiscounts;
    double tax = (totalAfterItemDiscounts - _overallDiscount) * 0.05;
    return totalAfterItemDiscounts - _overallDiscount + tax;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _overallDiscountController.dispose();
    _cashTenderedController.dispose();
    super.dispose();
  }

  // --- Main Build Method ---
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
    title: const Text('POS'),
    leading: IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
      },
    ),
  ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // PosHeader(
          //   isFullScreen: _isFullScreen,
          //   onToggleFullScreen: () => setState(() => _isFullScreen = !_isFullScreen),
          //   onBackToDashboard: () {
          //     // Navigate back to the main screen. 
          //     // This assumes the POS screen was pushed on top of the MainScreen.
          //     if (Navigator.canPop(context)) {
          //         Navigator.of(context).pop();
          //     }
          //   },
          // ),
          Expanded(
            child: Row(
              children: [
                // Product Selection Area
                Expanded(
                  flex: _isFullScreen ? 3 : 1, // Adjust flex based on screen mode
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          _buildSearchAndFilter(theme),
                        const SizedBox(height: 20),
                        const Text("Categories", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        _buildCategorySelector(theme),
                        const SizedBox(height: 20),
                        Expanded(child: _buildProductGrid(theme)),
                      ],
                    ),
                  ),
                ),
                // Billing Area
                if (_isFullScreen)
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            )
                          ]
                      ),
                      child: _buildBillingSection(theme),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- UI Widgets ---

  Widget _buildSearchAndFilter(ThemeData theme) {
    return TextField(
            controller: _searchController,
            style: TextStyle(color: theme.textTheme.bodyLarge?.color),
            decoration: InputDecoration(
              hintText: 'Search products by name...',
              hintStyle: TextStyle(color: theme.textTheme.bodySmall?.color),
              prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
              filled: true,
              fillColor: theme.cardColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          );
  }

  Widget _buildCategorySelector(ThemeData theme) {
    final categories = ['All', 'Sweets', 'Beverages', 'Snacks', 'Bakery'];
    return SizedBox(
      height: 60, // Increased height for a better box-like feel
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return _buildCategoryBox(category, isSelected, theme);
        },
      ),
    );
  }

  Widget _buildCategoryBox(String category, bool isSelected, ThemeData theme) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
          _filterProducts();
        });
      },
      child: Container(
        width: 100, // Fixed width for each box
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor : theme.cardColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isSelected ? theme.primaryColor : theme.dividerColor,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid(ThemeData theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 0.85,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return InkWell(
          onTap: () => _addToCart(product),
          borderRadius: BorderRadius.circular(12),
          child: Card(
            color: theme.cardColor,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('Rs. ${product.price.toStringAsFixed(2)}', style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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

  Widget _buildBillingSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _isFinalizingPayment
            ? _buildPaymentView(theme)
            : _buildCartView(theme),
      ),
    );
  }

  Widget _buildCartView(ThemeData theme) {
    double subtotal = _cartItems.fold(0, (sum, item) => sum + item.subtotal);
    double itemDiscounts = _cartItems.fold(0, (sum, item) => sum + item.discount);
    double totalAfterItemDiscounts = subtotal - itemDiscounts;
    double tax = (totalAfterItemDiscounts - _overallDiscount) * 0.05;
    double grandTotal = totalAfterItemDiscounts - _overallDiscount + tax;

    return Column(
      key: const ValueKey('cartView'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(Icons.person_outline),
            const SizedBox(width: 10),
            Expanded(child: Text('Walk-in Customer', style: theme.textTheme.titleMedium)),
            IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
          ],
        ),
        const Divider(height: 30),
        Expanded(
          child: _cartItems.isEmpty
              ? _buildEmptyCart(theme)
              : ListView.separated(
                  itemCount: _cartItems.length,
                  separatorBuilder: (context, index) => const Divider(color: Colors.transparent, height: 10),
                  itemBuilder: (context, index) {
                    final item = _cartItems[index];
                    return _buildCartItemTile(item, theme);
                  },
                ),
        ),
        const Divider(height: 30),
        _buildTotalRow('Subtotal', 'Rs. ${subtotal.toStringAsFixed(2)}', theme),
        _buildTotalRow('Item Discounts', '- Rs. ${itemDiscounts.toStringAsFixed(2)}', theme),
        _buildDiscountRow('Overall Discount', theme),
        _buildTotalRow('Tax (5%)', 'Rs. ${tax.toStringAsFixed(2)}', theme),
        const Divider(height: 20),
        _buildTotalRow('Grand Total', 'Rs. ${grandTotal.toStringAsFixed(2)}', theme, isBold: true),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: OutlinedButton(style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)), onPressed: () => setState(() => _cartItems.clear()), child: const Text('Cancel'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)), onPressed: _cartItems.isNotEmpty ? () => setState(() => _isFinalizingPayment = true) : null, child: const Text('Payment'))),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentView(ThemeData theme) {
    final grandTotal = _calculateGrandTotal();

    return Column(
      key: const ValueKey('paymentView'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() => _isFinalizingPayment = false),
              icon: const Icon(Icons.arrow_back),
            ),
            Text('Finalize Payment', style: theme.textTheme.titleLarge),
          ],
        ),
        const Spacer(),
        Text('Payable Amount', style: theme.textTheme.bodyMedium),
        Text('Rs. ${grandTotal.toStringAsFixed(2)}', style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 30),
        const Text('Select Payment Method:'),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildPaymentMethodChip('Cash', Icons.money, theme),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildPaymentMethodChip('Credit', Icons.credit_card, theme),
            ),
          ],
        ),
        if (_paymentMethod == 'Cash') ...[
          const SizedBox(height: 20),
          TextField(
            controller: _cashTenderedController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Cash Tendered'),
          ),
          const SizedBox(height: 10),
          Text(
            'Change Due: Rs. ${_changeDue.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18, color: _changeDue < 0 ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
          ),
        ],
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
          onPressed: () {
            // Handle final payment logic here
            setState(() {
              _cartItems.clear();
              _isFinalizingPayment = false;
              _overallDiscountController.text = "0.00";
              _cashTenderedController.clear();
            });
          },
          child: const Text('Confirm & Finalize'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodChip(String method, IconData icon, ThemeData theme) {
    final isSelected = _paymentMethod == method;
    return ChoiceChip(
      label: Text(method),
      avatar: Icon(icon, color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _paymentMethod = method);
        }
      },
      selectedColor: theme.primaryColor,
      labelStyle: TextStyle(color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color),
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? theme.primaryColor : theme.dividerColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }
  
  Widget _buildCartItemTile(CartItem item, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(item.product.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.product.name, style: theme.textTheme.bodyLarge),
                Text('Rs. ${item.product.price.toStringAsFixed(2)}', style: theme.textTheme.bodySmall),
                if (item.discount > 0) Text('Discount: -Rs. ${item.discount.toStringAsFixed(2)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.green)),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 20),
                onPressed: () => setState(() {
                  if (item.quantity > 1) {
                    item.quantity--;
                  } else {
                    _cartItems.remove(item);
                  }
                }),
              ),
              Text('${item.quantity}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 20),
                onPressed: () => setState(() => item.quantity++),
              ),
            ],
          ),
          IconButton(icon: const Icon(Icons.edit_note, size: 22), onPressed: () => _showItemDiscountDialog(item)),
          Text('Rs. ${item.totalPrice.toStringAsFixed(2)}', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shopping_cart_outlined, size: 80, color: theme.dividerColor),
        const SizedBox(height: 20),
        Text('Your Cart is Empty', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text('Add products to get started', style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTotalRow(String title, String amount, ThemeData theme, {bool isBold = false}) {
    final style = isBold ? theme.textTheme.titleMedium : theme.textTheme.bodyLarge;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(amount, style: style),
        ],
      ),
    );
  }

  Widget _buildDiscountRow(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.bodyLarge),
          SizedBox(
            width: 100,
            height: 40,
            child: TextField(
              controller: _overallDiscountController,
              textAlign: TextAlign.right,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '- Rs. ',
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showItemDiscountDialog(CartItem item) {
    final discountController = TextEditingController(text: item.discount.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Discount for ${item.product.name}'),
          content: TextField(
            controller: discountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Discount Amount'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  item.discount = double.tryParse(discountController.text) ?? 0.0;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}