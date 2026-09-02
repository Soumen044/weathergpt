import 'package:flutter/material.dart';
import 'api_client.dart';

class AppState extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  String _location = "Kolkata, West Bengal";
  double _latitude = 22.5726;
  double _longitude = 88.3639;
  String _pincode = "700001";
  String _language = "en";
  String _occupation = "general";
  bool _isDarkMode = false; // Light mode default to match Web UI
  bool _highContrast = false;
  double _textSizeScale = 1.0;
  bool _emergencyMode = false;

  WeatherSnapshot? _currentWeather;
  ForecastResponse? _forecast;
  WarningResponse? _warnings;

  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get location => _location;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get pincode => _pincode;
  String get language => _language;
  String get occupation => _occupation;
  bool get isDarkMode => _isDarkMode;
  bool get highContrast => _highContrast;
  double get textSizeScale => _textSizeScale;
  bool get emergencyMode => _emergencyMode;

  WeatherSnapshot? get currentWeather => _currentWeather;
  ForecastResponse? get forecast => _forecast;
  WarningResponse? get warnings => _warnings;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructor
  AppState() {
    refreshData();
  }

  void setLocation(String loc, double lat, double lon, {String pincode = ""}) {
    _location = loc;
    _latitude = lat;
    _longitude = lon;
    if (pincode.isNotEmpty) _pincode = pincode;
    notifyListeners();
    refreshData();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setOccupation(String occ) {
    _occupation = occ;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setHighContrast(bool value) {
    _highContrast = value;
    notifyListeners();
  }

  void setTextSizeScale(double scale) {
    _textSizeScale = scale;
    notifyListeners();
  }

  void toggleEmergencyMode() {
    _emergencyMode = !_emergencyMode;
    notifyListeners();
  }

  Future<void> refreshData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final weather = await _api.getCurrentWeather(
        location: _location,
        lat: _latitude,
        lon: _longitude,
      );
      final fc = await _api.getForecast(
        location: _location,
        lat: _latitude,
        lon: _longitude,
      );
      final warn = await _api.getWarnings(
        location: _location,
        lat: _latitude,
        lon: _longitude,
      );

      _currentWeather = weather;
      _forecast = fc;
      _warnings = warn;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<ChatResponse> sendChatMessage(String query) async {
    return await _api.sendChatMessage(
      query: query,
      location: _location,
      latitude: _latitude,
      longitude: _longitude,
      occupation: _occupation,
      language: _language,
    );
  }

  Future<PincodeDetails> lookupPincode(String pincode) async {
    return await _api.lookupPincode(pincode);
  }
}
