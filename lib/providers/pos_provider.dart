import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

// --- DATA MODELS ---

// Models to parse the main JSON data structure
class PosApiResponse {
  final PosData data;
  PosApiResponse({required this.data});
  factory PosApiResponse.fromJson(Map<String, dynamic> json) {
    return PosApiResponse(data: PosData.fromJson(json['data']));
  }
}

class PosData {
  final List<Customer> customers;
  final List<Category> categories;
  final List<Brand> brands;

  PosData({required this.customers, required this.categories, required this.brands});

  factory PosData.fromJson(Map<String, dynamic> json) {
    return PosData(
      customers: (json['customers'] as List).map((c) => Customer.fromJson(c)).toList(),
      categories: (json['categories'] as List).map((c) => Category.fromJson(c)).toList(),
      brands: (json['brands'] as List).map((b) => Brand.fromJson(b)).toList(),
    );
  }
}

// Specific data models from the JSON
class Customer {
  final int id;
  final String name;
  Customer({required this.id, required this.name});
  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(id: json['id'], name: json['name'] ?? 'Unknown');
  }
}

class Category {
  final int id;
  final String name;
  final String thumbnail;
  Category({required this.id, required this.name, required this.thumbnail});
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(id: json['id'], name: json['name'] ?? '', thumbnail: json['thumbnail'] ?? '');
  }

  get parentCategoryName => null;

  get totalProducts => null;
}

class Brand {
  final int id;
  final String name;
  Brand({required this.id, required this.name});
  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(id: json['id'], name: json['name'] ?? '');
  }
}


// --- UI/STATE-SPECIFIC MODELS ---

class PosProduct {
  final String id;
  final String name;
  final String categoryName;
  final String brandName;
  final double price;
  final String imageUrl;

  PosProduct({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.brandName,
    required this.price,
    required this.imageUrl,
  });
}

class CartItem {
  final PosProduct product;
  int quantity;
  double discount;

  CartItem({required this.product, this.quantity = 1, this.discount = 0.0});

  double get subtotal => product.price * quantity;
  double get totalPrice => subtotal - discount;
}


// --- THE PROVIDER CLASS ---

class PosProvider with ChangeNotifier {
  // --- STATE VARIABLES ---
  
  // Data from API
  PosData? _posData;
  List<Customer> get customers => _posData?.customers ?? [];
  List<Category> get categories => _posData?.categories ?? [];
  List<Brand> get brands => _posData?.brands ?? [];

  // Product list
  List<PosProduct> _allProducts = [];
  List<PosProduct> _filteredProducts = [];
  List<PosProduct> get filteredProducts => _filteredProducts;

  // Cart and Billing
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => _cartItems;
  Customer? _selectedCustomer;
  Customer? get selectedCustomer => _selectedCustomer;

  // UI State
  String _selectedCategoryName = 'All';
  String get selectedCategoryName => _selectedCategoryName;
  bool _isFinalizingPayment = false;
  bool get isFinalizingPayment => _isFinalizingPayment;
  String _paymentMethod = 'Cash';
  String get paymentMethod => _paymentMethod;
  double _cashTendered = 0.0;
  double get cashTendered => _cashTendered;
  
  // Totals
  double _overallDiscount = 0.0;
  double get overallDiscount => _overallDiscount;
  double get subtotal => _cartItems.fold(0, (sum, item) => sum + item.subtotal);
  double get itemDiscounts => _cartItems.fold(0, (sum, item) => sum + item.discount);
  double get totalAfterItemDiscounts => subtotal - itemDiscounts;
  double get tax => (totalAfterItemDiscounts - _overallDiscount) * 0.05;
  double get grandTotal => totalAfterItemDiscounts - _overallDiscount + tax;

  // --- INITIALIZATION & DATA LOADING ---

  PosProvider() {
    _loadPosData();
  }

  Future<void> _loadPosData() async {
    const String jsonString = '''
    {
      "message": "Pos data",
      "data": {
          "customers": [{
              "id": 1,
              "name": "Jayasiri bake house",
              "email": "jayasiribakehouse99@gmail.com",
              "phone": "778001246"
          }],
          "categories": [{
              "id": 6,
              "name": "Cake Items",
              "thumbnail": "https://placehold.co/100"
          }, {
              "id": 5,
              "name": "Hotels",
              "thumbnail": "https://placehold.co/100"
          }, {
              "id": 4,
              "name": "Foods",
              "thumbnail": "https://placehold.co/100"
          }, {
              "id": 3,
              "name": "Sweets",
              "thumbnail": "https://placehold.co/100"
          }],
          "brands": [{
              "id": 41,
              "name": "Redman"
          }, {
              "id": 40,
              "name": "Fortune"
          }, {
              "id": 39,
              "name": "Motha"
          }]
      }
    }
    ''';

    final jsonData = json.decode(jsonString);
    _posData = PosApiResponse.fromJson(jsonData).data;
    
    _selectedCustomer = _posData!.customers.isNotEmpty ? _posData!.customers.first : null;
    
    _generateDummyProducts();
    _filteredProducts = _allProducts;
    
    // Notify listeners that initial data is loaded.
    notifyListeners();
  }

  void _generateDummyProducts() {
    if (_posData == null || categories.isEmpty || brands.isEmpty) return;
    final random = Random();
    _allProducts = List.generate(50, (index) {
      final category = categories[random.nextInt(categories.length)];
      final brand = brands[random.nextInt(brands.length)];
      return PosProduct(
        id: 'prod_$index',
        name: '${brand.name} Product ${index + 1}',
        categoryName: category.name,
        brandName: brand.name,
        price: 100.0 + random.nextInt(1500),
        imageUrl: 'https://placehold.co/150x150/${(index % 2 == 0) ? "EFEFEF" : "DDEFEF"}/grey?text=Product',
      );
    });
  }
  
  // --- METHODS (ACTIONS) ---

  void filterProducts({String? query}) {
    final lowerCaseQuery = query?.toLowerCase() ?? '';
    _filteredProducts = _allProducts.where((product) {
      final categoryMatch = _selectedCategoryName == 'All' || product.categoryName == _selectedCategoryName;
      final searchMatch = lowerCaseQuery.isEmpty || product.name.toLowerCase().contains(lowerCaseQuery);
      return categoryMatch && searchMatch;
    }).toList();
    notifyListeners();
  }
  
  void selectCategory(String categoryName) {
    _selectedCategoryName = categoryName;
    filterProducts(); // Re-run filter with the new category
  }

  void addToCart(PosProduct product) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    if (existingIndex != -1) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(CartItem cartItem) {
    _cartItems.remove(cartItem);
    notifyListeners();
  }

  void incrementQuantity(CartItem cartItem) {
    cartItem.quantity++;
    notifyListeners();
  }

  void decrementQuantity(CartItem cartItem) {
    if (cartItem.quantity > 1) {
      cartItem.quantity--;
    } else {
      _cartItems.remove(cartItem);
    }
    notifyListeners();
  }

  void applyItemDiscount(CartItem item, double discount) {
    item.discount = discount;
    notifyListeners();
  }

  void applyOverallDiscount(double discount) {
    _overallDiscount = discount;
    notifyListeners();
  }
  
  void clearCart() {
    _cartItems.clear();
    _overallDiscount = 0.0;
    notifyListeners();
  }

  void setPaymentView(bool isFinalizing) {
    _isFinalizingPayment = isFinalizing;
    notifyListeners();
  }

  void setPaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  void updateCashTendered(String value) {
    _cashTendered = double.tryParse(value) ?? 0.0;
    notifyListeners();
  }

  void finalizeOrder() {
    // In a real app, you would send this data to a server or local database.
    print("Order finalized for ${grandTotal.toStringAsFixed(2)} via $_paymentMethod");
    
    // Reset the state for the next transaction.
    _cartItems.clear();
    _overallDiscount = 0.0;
    _cashTendered = 0.0;
    _isFinalizingPayment = false;
    notifyListeners();
  }
}