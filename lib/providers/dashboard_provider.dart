import 'package:flutter/material.dart';
import 'dart:convert';
import '../../services/api_service.dart';


class DashboardData {
  final double sale;
  final double purchase;
  final double profit;
  final double purchaseDue;

  DashboardData({
    required this.sale,
    required this.purchase,
    required this.profit,
    required this.purchaseDue,
  });

  factory DashboardData.fromMap(Map<String, dynamic> map) {
    return DashboardData(
      sale: (map['sale'] ?? 0).toDouble(),
      purchase: (map['purchase'] ?? 0).toDouble(),
      profit: (map['profit'] ?? 0).toDouble(),
      purchaseDue: (map['purchase_due'] ?? 0).toDouble(),
    );
  }
}

class DashboardProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  DashboardData? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;

  DashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDashboardData() async {
     print('fetchDashboardData() called');  // Add this at the very top
  _isLoading = true;
  _errorMessage = null;
  notifyListeners();

  try {
    final response = await _apiService.getDashboardData();
    final responseBody = response.body;

    if (response.statusCode == 200) {
      final responseData = json.decode(responseBody);

      if (responseData['data'] != null) {
        final data = responseData['data'];

        _dashboardData = DashboardData.fromMap(data);
      } else {
        _errorMessage = "error_no_data_found";
      }
    } else {
      _errorMessage = "error_failed_load";
      print('API returned non-200 status: ${response.statusCode}');
    }
  } catch (e) {
    _errorMessage = "Please Check Your Network Connection!";

  }

  _isLoading = false;
  notifyListeners();
}

}

