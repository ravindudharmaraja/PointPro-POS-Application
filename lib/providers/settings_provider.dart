// providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class SettingsModel {
  final String currencyPosition;
  final String symbol;
  final String dateFormat;
  final String dateWithTime;
  final String direction;
  final String language;
  final String siteTitle;
  

  SettingsModel({
    required this.currencyPosition,
    required this.symbol,
    required this.dateFormat,
    required this.dateWithTime,
    required this.direction,
    required this.language,
    required this.siteTitle,
   
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      currencyPosition: json['currency_position'] ?? 'Prefix',
      symbol: json['symbol'] ?? 'Rs.',
      dateFormat: json['date_format'] ?? 'Y-m-d',
      dateWithTime: json['date_with_time'] ?? 'Enable',
      direction: json['direction'] ?? 'ltr',
      language: json['language'] ?? 'en',
      siteTitle: json['site_title'] ?? '',
    
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency_position': currencyPosition,
      'symbol': symbol,
      'date_format': dateFormat,
      'date_with_time': dateWithTime,
      'direction': direction,
      'language': language,
      'site_title': siteTitle
    };
  }
}

class SettingsProvider with ChangeNotifier {
  SettingsModel? _settings;
  bool _isLoading = false;
  String? _error;
  bool _isSaving = false;

  SettingsModel? get settings => _settings;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  // Initialize with default values
  SettingsProvider() {
    _initializeWithDefaults();
  }

  void _initializeWithDefaults() {
    _settings = SettingsModel(
      currencyPosition: 'Prefix',
      symbol: 'Rs.',
      dateFormat: 'Y-m-d',
      dateWithTime: 'Enable',
      direction: 'ltr',
      language: 'en',
      siteTitle: ''
      
    );
  }

  Future<void> fetchSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().get('general-settings');
      if (response['data'] != null) {
        _settings = SettingsModel.fromJson(response['data']);
      } else {
        throw Exception('No settings data found in response');
      }
    } catch (e) {
      _error = 'Failed to load settings: ${e.toString()}';
      if (kDebugMode) {
        print('Error fetching settings: $e');
      }
      // Reinitialize with defaults on error
      _initializeWithDefaults();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateSettings() async {
    if (_settings == null) return false;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().post(
        'general-settings',
        data: _settings!.toJson(),
      );
      
      if (response['success'] == true) {
        await fetchSettings(); // Refresh settings after update
        return true;
      } else {
        throw Exception(response['message'] ?? 'Failed to save settings');
      }
    } catch (e) {
      _error = 'Failed to save settings: ${e.toString()}';
      if (kDebugMode) {
        print('Error updating settings: $e');
      }
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // Individual property setters
  void setCurrencyPosition(String value) {
    _settings = _settings?.copyWith(currencyPosition: value);
    notifyListeners();
  }

  void setSymbol(String value) {
    _settings = _settings?.copyWith(symbol: value);
    notifyListeners();
  }

  void setDateFormat(String value) {
    _settings = _settings?.copyWith(dateFormat: value);
    notifyListeners();
  }

  void setDateWithTime(String value) {
    _settings = _settings?.copyWith(dateWithTime: value);
    notifyListeners();
  }

  void setDirection(String value) {
    _settings = _settings?.copyWith(direction: value);
    notifyListeners();
  }

  void setLanguage(String value) {
    _settings = _settings?.copyWith(language: value);
    notifyListeners();
  }

  void setSiteTitle(String value) {
    _settings = _settings?.copyWith(siteTitle: value);
    notifyListeners();
  }

 
}

extension SettingsModelCopyWith on SettingsModel {
  SettingsModel copyWith({
    String? currencyPosition,
    String? symbol,
    String? dateFormat,
    String? dateWithTime,
    String? direction,
    String? language,
    String? siteTitle,
    
  }) {
    return SettingsModel(
      currencyPosition: currencyPosition ?? this.currencyPosition,
      symbol: symbol ?? this.symbol,
      dateFormat: dateFormat ?? this.dateFormat,
      dateWithTime: dateWithTime ?? this.dateWithTime,
      direction: direction ?? this.direction,
      language: language ?? this.language,
      siteTitle: siteTitle ?? this.siteTitle,
      
    );
  }
}