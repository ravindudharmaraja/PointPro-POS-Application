import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class AnalyticsData {
  final double salesTotal;
  final double salesTax;
  final double salesDiscount;
  final int sellingProducts;
  final int availableProducts;
  final List<double> salesMonthlyTrend;
  final double purchasesTotal;
  final double purchasesPaid;
  final double purchasesTax;
  final double purchasesDiscount;
  final double purchasesDue;
  final int purchasesProducts;
  final List<double> purchasesMonthlyTrend;
  final double paymentReceivedTotal;
  final double paymentReceivedCash;
  final double paymentReceivedBank;
  final int cashCount;
  final int bankCount;
  final double profit;
  final List<TopProduct> topProducts;

  AnalyticsData({
    required this.salesTotal,
    required this.salesTax,
    required this.salesDiscount,
    required this.sellingProducts,
    required this.availableProducts,
    required this.salesMonthlyTrend,
    required this.purchasesTotal,
    required this.purchasesPaid,
    required this.purchasesTax,
    required this.purchasesDiscount,
    required this.purchasesDue,
    required this.purchasesProducts,
    required this.purchasesMonthlyTrend,
    required this.paymentReceivedTotal,
    required this.paymentReceivedCash,
    required this.paymentReceivedBank,
    required this.cashCount,
    required this.bankCount,
    required this.profit,
    required this.topProducts,
  });

  factory AnalyticsData.fromMap(Map<String, dynamic> map) {
    return AnalyticsData(
      salesTotal: (map['sales']['total'] as num).toDouble(),
      salesTax: (map['sales']['tax'] as num).toDouble(),
      salesDiscount: (map['sales']['discount'] as num).toDouble(),
      sellingProducts: map['sales']['selling_product'] ?? 0,
      availableProducts: map['sales']['available_product'] ?? 0,
      salesMonthlyTrend: List<double>.from(
          (map['sales']['monthly_trend'] as List).map((e) => (e as num).toDouble())),
      purchasesTotal: (map['purchases']['total'] as num).toDouble(),
      purchasesPaid: (map['purchases']['paid'] as num).toDouble(),
      purchasesTax: (map['purchases']['tax'] as num).toDouble(),
      purchasesDiscount: (map['purchases']['discount'] as num).toDouble(),
      purchasesDue: (map['purchases']['due'] as num).toDouble(),
      purchasesProducts: map['purchases']['products'] ?? 0,
      purchasesMonthlyTrend: List<double>.from(
          (map['purchases']['monthly_trend'] as List).map((e) => (e as num).toDouble())),
      paymentReceivedTotal: (map['payment_received']['total'] as num).toDouble(),
      paymentReceivedCash: (map['payment_received']['cash'] as num).toDouble(),
      paymentReceivedBank: (map['payment_received']['bank'] as num).toDouble(),
      cashCount: map['payment_received']['cash_count'] ?? 0,
      bankCount: map['payment_received']['bank_count'] ?? 0,
      profit: (map['profit'] as num).toDouble(),
      topProducts: List<TopProduct>.from(
          (map['top_products'] as List).map((e) => TopProduct.fromMap(e))),
    );
  }

  get sales => null;

  get purchases => null;
}

class TopProduct {
  final String name;
  final double sales;
  final int quantity;

  TopProduct({
    required this.name,
    required this.sales,
    required this.quantity,
  });

  factory TopProduct.fromMap(Map<String, dynamic> map) {
    return TopProduct(
      name: map['name'] ?? 'N/A',
      sales: (map['sales'] as num).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }
}

class AnalyticsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  AnalyticsData? _analyticsData;
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedPeriod = 'this_month';

  AnalyticsData? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedPeriod => _selectedPeriod;

  AnalyticsProvider() {
    fetchAnalyticsData();
  }

  Future<void> fetchAnalyticsData({String? period}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.getAnalyticsReport(period: period ?? _selectedPeriod);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final Map<String, dynamic> data = responseData['data'];
        _analyticsData = AnalyticsData.fromMap(data);
      } else {
        final errorData = json.decode(response.body);
        _errorMessage = errorData['message'] ?? "Failed to load analytics data from the server.";
      }
    } catch (e) {
      _errorMessage = "A network error occurred. Please check your connection.";
      print("Analytics fetch error: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  void setSelectedPeriod(String period) {
    _selectedPeriod = period;
    notifyListeners();
    fetchAnalyticsData(period: period);
  }
}