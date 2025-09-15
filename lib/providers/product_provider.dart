import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductRecord {
  final int id;
  final String name;
  final String thumbnail;
  final String brand;
  final String category;
  final String unit;
  final double price;
  final int qty;
  final String code;

  ProductRecord({
    required this.id,
    required this.name,
    required this.thumbnail,
    required this.brand,
    required this.category,
    required this.unit,
    required this.price,
    required this.qty,
    required this.code,
  });

  factory ProductRecord.fromMap(Map<String, dynamic> map) {
    return ProductRecord(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'N/A',
      thumbnail: map['thumbnail'] ?? '',
      brand: map['brand'] ?? 'N/A',
      category: map['category'] ?? 'N/A',
      unit: map['unit'] ?? 'N/A',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      qty: map['qty'] ?? 0,
      code: map['code'] ?? 'N/A',
    );
  }

  get taxRate => null;

  get imageUrl => null;
}

class ProductProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProductRecord> _allProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductRecord> get products => _allProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ProductProvider() {
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getProducts();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        final Map<String, dynamic> dataObject = responseData['data'];
        final List<dynamic> productList = dataObject['products']; 
        
        _allProducts = productList.map((json) => ProductRecord.fromMap(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Failed to load product data from the server.";
      }
    } catch (e) {
      _errorMessage = "A network error occurred. Please check your connection.";
      print("Products fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
