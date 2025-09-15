import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class CustomerRecord {
  final int id;
  final String groupName;
  final String companyName;
  final String email;
  final String phoneNumber;
  final String taxNumber;

  CustomerRecord({
    required this.id,
    required this.groupName,
    required this.companyName,
    required this.email,
    required this.phoneNumber,
    required this.taxNumber,
  });

  factory CustomerRecord.fromMap(Map<String, dynamic> map) {
  return CustomerRecord(
    id: map['id'] ?? 0,
    groupName: map['customer_group_id']?.toString() ?? 'N/A', // You might want to fetch the name from another source
    companyName: map['company_name'] ?? map['name'] ?? 'N/A', // fallback to 'name' if company_name is null
    email: map['email'] ?? 'N/A',
    phoneNumber: map['phone_number'] ?? 'N/A', // Fix: correct key
    taxNumber: map['tax_no'] ?? 'N/A',
  );
}
}

class CustomerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CustomerRecord> _allCustomers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<CustomerRecord> get customers => _allCustomers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  CustomerProvider() {
    fetchCustomers();
  }

 Future<void> fetchCustomers() async {
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _apiService.getCustomers();

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      print("Response data: $responseData");

      List<dynamic> customerList = [];

      // Check if responseData is a List (top-level array)
      if (responseData is List) {
        customerList = responseData;
      } else if (responseData is Map) {
        // If responseData is Map, check for nested data key
        if (responseData['data'] is List) {
          customerList = responseData['data'];
        } else if (responseData['data'] is Map && responseData['data']['data'] is List) {
          customerList = responseData['data']['data'];
        } else {
          throw Exception("Unexpected JSON structure");
        }
      } else {
        throw Exception("Unexpected JSON structure");
      }

      _allCustomers = customerList.map((json) => CustomerRecord.fromMap(json)).toList();
    } else {
      final errorData = json.decode(response.body);
      _errorMessage = errorData['message'] ?? "Failed to load customer data from the server.";
    }
  } catch (e) {
    _errorMessage = "A network error occurred. Please check your connection.";
    print("Customers fetch error: $e");
  }

  _isLoading = false;
  notifyListeners();
}

}
