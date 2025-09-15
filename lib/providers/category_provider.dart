import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CategoryRecord {
  final int id;
  final String name;
  final String thumbnail;
  final String? parentCategoryName;
  final int totalProducts;

  CategoryRecord({
    required this.id,
    required this.name,
    required this.thumbnail,
    this.parentCategoryName,
    required this.totalProducts,
  });

  factory CategoryRecord.fromMap(Map<String, dynamic> map) {
    return CategoryRecord(
      id: map['id'] ?? 0,
      name: map['name'] ?? 'N/A',
      thumbnail: map['thumbnail'] ?? '',
      parentCategoryName: map['parent_category_name'],
      totalProducts: map['total_products'] ?? 0,
    );
  }
}

class CategoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryRecord> _allCategories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryRecord> get categories => _allCategories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CategoryProvider() {
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getCategories();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        final Map<String, dynamic> dataObject = responseData['data'];
        final List<dynamic> categoryList = dataObject['categories']; 
        
        _allCategories = categoryList.map((json) => CategoryRecord.fromMap(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Failed to load category data from the server.";
      }
    } catch (e) {
      _errorMessage = "A network error occurred. Please check your connection.";
      print("Categories fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
