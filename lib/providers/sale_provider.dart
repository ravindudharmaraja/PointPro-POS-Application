import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart'; // Your API service

// --- 1. Data Model ---
class SaleRecord {
  final int id;
  final String date;
  final String referenceNo;
  final String biller;
  final double qty; // Changed to double as per API response
  final double? discount;
  final double? tax;
  final double totalPrice;
  final double grandTotal;
  final List<SaleItem> items;

  SaleRecord({
    required this.id,
    required this.date,
    required this.referenceNo,
    required this.biller,
    required this.qty,
    this.discount,
    this.tax,
    required this.totalPrice,
    required this.grandTotal,
    required this.items,
  });

  factory SaleRecord.fromMap(Map<String, dynamic> map) {
    return SaleRecord(
      id: map['id'] ?? 0,
      date: map['date'] ?? 'N/A',
      referenceNo: map['reference_no'] ?? 'N/A',
      biller: map['biller'] ?? 'N/A',
      qty: (map['qty'] ?? 0).toDouble(),
      discount: map['discount']?.toDouble(),
      tax: map['tax']?.toDouble(),
      totalPrice: (map['total_price'] ?? 0).toDouble(),
      grandTotal: (map['grand_total'] ?? 0).toDouble(),
      items: (map['items'] as List<dynamic>?)
              ?.map((item) => SaleItem.fromMap(item))
              .toList() ??
          [],
    );
  }

  // Helper getter for formatted grand total
  String get formattedGrandTotal => 'Rs. ${grandTotal.toStringAsFixed(2)}';
  
  // Helper getter for total items count (alternative to qty if needed)
  int get itemCount => items.fold(0, (sum, item) => sum + (double.tryParse(item.quantity)?.toInt() ?? 0));

  get totalProduct => null;
}

class SaleItem {
  final int productId;
  final String productName;
  final String productCode;
  final String quantity;
  final String unitPrice;
  final String discount;
  final String tax;
  final String subtotal;

  SaleItem({
    required this.productId,
    required this.productName,
    required this.productCode,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
    required this.tax,
    required this.subtotal,
  });

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      productId: map['product_id'] ?? 0,
      productName: map['product_name'] ?? 'N/A',
      productCode: map['product_code'] ?? 'N/A',
      quantity: map['quantity']?.toString() ?? '0',
      unitPrice: map['unit_price']?.toString() ?? '0.00',
      discount: map['discount']?.toString() ?? '0.00',
      tax: map['tax']?.toString() ?? '0.00',
      subtotal: map['subtotal']?.toString() ?? '0.00',
    );
  }
}

// --- 2. Provider to Fetch and Manage Sales State ---
class SaleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  // State variables
  List<SaleRecord> _allSales = [];
  bool _isLoading = false;
  String? _errorMessage;
  double _totalSales = 0;

  // Getters
  List<SaleRecord> get sales => _allSales;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double get totalSales => _totalSales;

  SaleProvider() {
    fetchSales();
  }

  /// Fetches sales data from the API
  Future<void> fetchSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getSalesHistory();

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['data'] != null) {
          final data = responseData['data'];
          final salesList = (data['sales'] as List<dynamic>)
              .map((json) => SaleRecord.fromMap(json))
              .toList();
              
          _allSales = salesList;
          _totalSales = (data['total'] ?? 0).toDouble();
        } else {
          _errorMessage = "No sales data found";
        }
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Failed to load sales data";
      }
    } catch (e) {
      _errorMessage = "Network error: ${e.toString()}";
      print("Sales fetch error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Filters sales by date range
  List<SaleRecord> filterByDateRange(DateTime start, DateTime end) {
    return _allSales.where((sale) {
      final saleDate = _parseDate(sale.date);
      return saleDate.isAfter(start.subtract(const Duration(days: 1))) && 
             saleDate.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  /// Helper to parse date strings from API
  DateTime _parseDate(String dateStr) {
    try {
      final parts = dateStr.split(' ');
      if (parts.length >= 3) {
        final day = int.parse(parts[0]);
        final month = _monthToNumber(parts[1]);
        final year = int.parse(parts[2].replaceAll(',', ''));
        return DateTime(year, month, day);
      }
    } catch (e) {
      print("Date parsing error: $e");
    }
    return DateTime.now();
  }

  int _monthToNumber(String month) {
    const months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return months[month] ?? 1;
  }

  void refreshSales() {}
}