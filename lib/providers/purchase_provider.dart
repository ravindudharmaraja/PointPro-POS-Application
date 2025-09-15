import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PurchaseRecord {
  final int id;
  final String date;
  final String referenceNo;
  final String supplier;
  final String purchaseStatus;
  final String grandTotal;

  PurchaseRecord({
    required this.id,
    required this.date,
    required this.referenceNo,
    required this.supplier,
    required this.purchaseStatus,
    required this.grandTotal,
  });

  factory PurchaseRecord.fromMap(Map<String, dynamic> map) {
    return PurchaseRecord(
      id: map['id'] ?? 0,
      date: map['date'] ?? 'N/A',
      referenceNo: map['reference_no'] ?? 'N/A',
      supplier: map['supplier'] ?? 'N/A',
      purchaseStatus: map['status'] ?? 'N/A', // FIX: Key changed from 'purchase_status' to 'status'
      grandTotal: map['grand_total']?.toString() ?? '0.00',
    );
  }

  get items => null;

  get tax => null;

  get discount => null;

  get totalPrice => null;
}

class PurchaseProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<PurchaseRecord> _allPurchases = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PurchaseRecord> get purchases => _allPurchases;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PurchaseProvider() {
    fetchPurchases();
  }

  Future<void> fetchPurchases() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getPurchases();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        final Map<String, dynamic> dataObject = responseData['data'];
        // FIX: Path changed from 'data' to 'purchases' to match API
        final List<dynamic> purchaseList = dataObject['purchases']; 
        
        _allPurchases = purchaseList.map((json) => PurchaseRecord.fromMap(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Failed to load purchase data from the server.";
      }
    } catch (e) {
      _errorMessage = "A network error occurred. Please check your connection.";
      print("Purchases fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
