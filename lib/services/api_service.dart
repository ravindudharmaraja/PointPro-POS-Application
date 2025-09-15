import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = "https://propoint.coreit.digital/api";
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Authentication token not found. User may be logged out.');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> _getPublicHeaders() {
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint, {bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = requiresAuth ? await _getAuthHeaders() : _getPublicHeaders();
      
      final response = await _client.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw _formatException(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, 
      {required Map<String, dynamic> data, bool requiresAuth = true}) async {
    try {
      final url = Uri.parse('$_baseUrl/$endpoint');
      final headers = requiresAuth ? await _getAuthHeaders() : _getPublicHeaders();
      
      final response = await _client.post(
        url,
        headers: headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _formatException(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final responseBody = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    } else {
      final errorMsg = responseBody['message'] ?? 'Request failed with status ${response.statusCode}';
      throw Exception(errorMsg);
    }
  }

  Exception _formatException(dynamic e) {
    if (e is Exception) return e;
    return Exception('Network error: ${e.toString()}');
  }


  Future<http.Response> signIn(String email, String password) async {
    final url = Uri.parse('$_baseUrl/sign-in');
    final body = jsonEncode({'email': email, 'password': password});
    return await http.post(url, headers: _getPublicHeaders(), body: body);
  }

  Future<http.Response> forgotPassword(String email) async {
    final url = Uri.parse('$_baseUrl/forgot/password');
    final body = jsonEncode({'email': email});
    return await http.post(url, headers: _getPublicHeaders(), body: body);
  }

  Future<http.Response> checkOtp(String email, String otp) async {
    final url = Uri.parse('$_baseUrl/check/otp');
    final body = jsonEncode({'email': email, 'otp': otp});
    return await http.post(url, headers: _getPublicHeaders(), body: body);
  }

  Future<http.Response> resetPassword(String email, String otp, String password, String passwordConfirmation) async {
    final url = Uri.parse('$_baseUrl/reset/password');
    final body = jsonEncode({
      'email': email,
      'otp': otp,
      'password': password,
      'password_confirmation': passwordConfirmation
    });
    return await http.put(url, headers: _getPublicHeaders(), body: body);
  }

  Future<http.Response> logout() async {
    final url = Uri.parse('$_baseUrl/logout');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> getGeneralSettings() async {
    final url = Uri.parse('$_baseUrl/general-settings');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> getDashboardData() async {
    final url = Uri.parse('$_baseUrl/dashboard');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> getProfileDetails() async {
    final url = Uri.parse('$_baseUrl/profile');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> updateProfile(Map<String, dynamic> profileData) async {
    final url = Uri.parse('$_baseUrl/profile/update');
    return await http.post(url, headers: await _getAuthHeaders(), body: jsonEncode(profileData));
  }

  Future<http.Response> changePassword(String currentPassword, String newPassword, String newPasswordConfirmation) async {
    final url = Uri.parse('$_baseUrl/change/password');
    final body = jsonEncode({
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
    return await http.put(url, headers: await _getAuthHeaders(), body: body);
  }

  Future<http.Response> getProducts({int page = 1}) async {
    final url = Uri.parse('$_baseUrl/products?page=$page');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> searchProducts(String query) async {
    final url = Uri.parse('$_baseUrl/product/search?q=$query');
    return await http.get(url, headers: await _getAuthHeaders());
  }
  
  Future<http.Response> getProductDetails(int productId) async {
    final url = Uri.parse('$_baseUrl/product/details/$productId');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> deleteProduct(int productId) async {
    final url = Uri.parse('$_baseUrl/product/delete/$productId');
    return await http.delete(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> postSale(Map<String, dynamic> saleData) async {
    final url = Uri.parse('$_baseUrl/pos/store');
    return await http.post(url, headers: await _getAuthHeaders(), body: jsonEncode(saleData));
  }
  
  Future<http.Response> getSalesHistory() async {
    final url = Uri.parse('$_baseUrl/sales');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> getCategories() async {
    final url = Uri.parse('$_baseUrl/categories');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> createCategory(Map<String, dynamic> categoryData) async {
    final url = Uri.parse('$_baseUrl/categories/store');
    return await http.post(url, headers: await _getAuthHeaders(), body: jsonEncode(categoryData));
  }
  
  Future<http.Response> updateCategory(int categoryId, Map<String, dynamic> categoryData) async {
    final url = Uri.parse('$_baseUrl/categories/update/$categoryId');
    return await http.post(url, headers: await _getAuthHeaders(), body: jsonEncode(categoryData));
  }

  Future<http.Response> deleteCategory(int categoryId) async {
    final url = Uri.parse('$_baseUrl/categories/delete/$categoryId');
    return await http.delete(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> searchCustomers(String query) async {
    final url = Uri.parse('$_baseUrl/customer/search?q=$query');
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> createCustomer(Map<String, dynamic> customerData) async {
    final url = Uri.parse('$_baseUrl/customer/store');
    return await http.post(url, headers: await _getAuthHeaders(), body: jsonEncode(customerData));
  }

  Future<http.Response> getCustomers() async {
    final url = Uri.parse('$_baseUrl/customer'); // Assuming a /customers endpoint
    return await http.get(url, headers: await _getAuthHeaders());
  }

  Future<http.Response> getPurchases() async {
    final url = Uri.parse('$_baseUrl/purchase');
    return await http.get(url, headers: await _getAuthHeaders());
  }

   Future<http.Response> getAnalyticsReport({String period = 'this_month'}) async {
    final url = Uri.parse('$_baseUrl/reports?period=$period');
    return await http.get(url, headers: await _getAuthHeaders());
  }

}
