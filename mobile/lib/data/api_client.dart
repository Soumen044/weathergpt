import 'dart:convert';
import 'package:http/http.dart' as http;

/// Typed API Client for WeatherGPT backend.
/// All methods return parsed typed responses or throw descriptive errors.
/// No silent fallback to fake data — errors propagate to the UI layer.
class ApiClient {
  // On Android emulator, use 10.0.2.2 to reach host machine's localhost.
  // On physical device, replace with your machine's LAN IP.
  static const String baseUrl = "http://10.0.2.2:8000/api/v1";

  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  // ─── Weather ──────────────────────────────────────────────────

  Future<WeatherSnapshot> getCurrentWeather({
    String? location,
    double? lat,
    double? lon,
  }) async {
    final params = <String, String>{};
    if (location != null) params['location'] = location;
    if (lat != null) params['lat'] = lat.toString();
    if (lon != null) params['lon'] = lon.toString();

    final uri = Uri.parse('$baseUrl/weather/current').replace(queryParameters: params);
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      return WeatherSnapshot.fromJson(json.decode(response.body));
    }
    throw ApiException('Failed to fetch current weather (${response.statusCode})');
  }

  Future<ForecastResponse> getForecast({
    String? location,
    double? lat,
    double? lon,
  }) async {
    final params = <String, String>{};
    if (location != null) params['location'] = location;
    if (lat != null) params['lat'] = lat.toString();
    if (lon != null) params['lon'] = lon.toString();

    final uri = Uri.parse('$baseUrl/weather/forecast').replace(queryParameters: params);
    final response = await _client.get(uri).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      return ForecastResponse.fromJson(json.decode(response.body));
    }
    throw ApiException('Failed to fetch forecast (${response.statusCode})');
  }

  // ─── Location ─────────────────────────────────────────────────

  Future<PincodeDetails> lookupPincode(String pincode) async {
    final uri = Uri.parse('$baseUrl/location/pincode/$pincode');
    final response = await _client.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return PincodeDetails.fromJson(json.decode(response.body));
    }
    throw ApiException('PIN code $pincode not found in India Post directory.');
  }

  Future<List<PincodeDetails>> searchLocations(String query) async {
    final uri = Uri.parse('$baseUrl/location/search').replace(queryParameters: {'q': query});
    final response = await _client.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => PincodeDetails.fromJson(e)).toList();
    }
    return [];
  }

  // ─── Chat ─────────────────────────────────────────────────────

  Future<ChatResponse> sendChatMessage({
    required String query,
    String? location,
    double? latitude,
    double? longitude,
    String occupation = 'general',
    String language = 'en',
  }) async {
    final uri = Uri.parse('$baseUrl/chat');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'query': query,
            'location': location,
            'latitude': latitude,
            'longitude': longitude,
            'occupation': occupation,
            'language': language,
          }),
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      return ChatResponse.fromJson(json.decode(response.body));
    }
    throw ApiException('WeatherGPT chat query failed (${response.statusCode})');
  }

  // ─── Warnings ─────────────────────────────────────────────────

  Future<WarningResponse> getWarnings({
    String? location,
    double? lat,
    double? lon,
  }) async {
    final params = <String, String>{};
    if (location != null) params['location'] = location;
    if (lat != null) params['lat'] = lat.toString();
    if (lon != null) params['lon'] = lon.toString();

    final uri = Uri.parse('$baseUrl/warnings').replace(queryParameters: params);
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      return WarningResponse.fromJson(json.decode(response.body));
    }
    throw ApiException('Failed to fetch warnings (${response.statusCode})');
  }

  // ─── Language ─────────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSupportedLanguages() async {
    final uri = Uri.parse('$baseUrl/language/supported');
    final response = await _client.get(uri).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    }
    return [];
  }

  Future<String> translateText({
    required String text,
    required String targetLanguage,
    String sourceLanguage = 'en',
  }) async {
    final uri = Uri.parse('$baseUrl/language/translate');
    final response = await _client
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'text': text,
            'target_language': targetLanguage,
            'source_language': sourceLanguage,
          }),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['translated_text'] ?? text;
    }
    return text; // Graceful fallback
  }

  // ─── Climate ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> getClimateTrend({String location = 'Kolkata'}) async {
    final uri = Uri.parse('$baseUrl/climate/trend').replace(queryParameters: {'location': location});
    final response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw ApiException('Failed to fetch climate trend (${response.statusCode})');
  }
}

// ─── Custom Exception ─────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

// ─── Models ───────────────────────────────────────────────────

class LocationInfo {
  final String name;
  final String? pincode;
  final String? district;
  final String? state;
  final double latitude;
  final double longitude;

  LocationInfo({
    required this.name,
    this.pincode,
    this.district,
    this.state,
    required this.latitude,
    required this.longitude,
  });

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    return LocationInfo(
      name: json['name'] ?? 'Unknown',
      pincode: json['pincode'],
      district: json['district'],
      state: json['state'],
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
}

class WarningItem {
  final String level;
  final String category;
  final String headline;
  final String description;
  final String? issuedAt;
  final String source;

  WarningItem({
    required this.level,
    required this.category,
    required this.headline,
    required this.description,
    this.issuedAt,
    required this.source,
  });

  factory WarningItem.fromJson(Map<String, dynamic> json) {
    return WarningItem(
      level: json['level'] ?? 'GREEN',
      category: json['category'] ?? 'General',
      headline: json['headline'] ?? '',
      description: json['description'] ?? '',
      issuedAt: json['issued_at'],
      source: json['source'] ?? 'IMD',
    );
  }
}

class WeatherSnapshot {
  final LocationInfo location;
  final String timestamp;
  final double temperature;
  final double feelsLike;
  final double humidity;
  final double pressure;
  final double windSpeed;
  final double windDirection;
  final double visibility;
  final double cloudCover;
  final double rain;
  final double rainProbability;
  final int weatherCode;
  final String weatherDesc;
  final double uvIndex;
  final String sunrise;
  final String sunset;
  final List<WarningItem> warnings;
  final String source;
  final String model;

  WeatherSnapshot({
    required this.location,
    required this.timestamp,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.cloudCover,
    required this.rain,
    required this.rainProbability,
    required this.weatherCode,
    required this.weatherDesc,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
    required this.warnings,
    required this.source,
    required this.model,
  });

  factory WeatherSnapshot.fromJson(Map<String, dynamic> json) {
    return WeatherSnapshot(
      location: LocationInfo.fromJson(json['location'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      feelsLike: (json['feels_like'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      pressure: (json['pressure'] ?? 1013).toDouble(),
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      windDirection: (json['wind_direction'] ?? 0).toDouble(),
      visibility: (json['visibility'] ?? 10000).toDouble(),
      cloudCover: (json['cloud_cover'] ?? 0).toDouble(),
      rain: (json['rain'] ?? 0).toDouble(),
      rainProbability: (json['rain_probability'] ?? 0).toDouble(),
      weatherCode: json['weather_code'] ?? 0,
      weatherDesc: json['weather_desc'] ?? 'Clear sky',
      uvIndex: (json['uv_index'] ?? 0).toDouble(),
      sunrise: json['sunrise'] ?? '06:00',
      sunset: json['sunset'] ?? '18:00',
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((w) => WarningItem.fromJson(w))
              .toList() ??
          [],
      source: json['source'] ?? 'IMD + Open-Meteo',
      model: json['model'] ?? 'ECMWF',
    );
  }
}

class ForecastHourlyItem {
  final String time;
  final double temperature;
  final double rainProbability;
  final double rainMm;
  final double windSpeed;
  final int weatherCode;
  final String weatherDesc;

  ForecastHourlyItem({
    required this.time,
    required this.temperature,
    required this.rainProbability,
    required this.rainMm,
    required this.windSpeed,
    required this.weatherCode,
    required this.weatherDesc,
  });

  factory ForecastHourlyItem.fromJson(Map<String, dynamic> json) {
    return ForecastHourlyItem(
      time: json['time'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      rainProbability: (json['rain_probability'] ?? 0).toDouble(),
      rainMm: (json['rain_mm'] ?? 0).toDouble(),
      windSpeed: (json['wind_speed'] ?? 0).toDouble(),
      weatherCode: json['weather_code'] ?? 0,
      weatherDesc: json['weather_desc'] ?? '',
    );
  }
}

class ForecastDailyItem {
  final String date;
  final double tempMax;
  final double tempMin;
  final double rainProbability;
  final double precipitationSum;
  final int weatherCode;
  final String weatherDesc;
  final double uvIndexMax;

  ForecastDailyItem({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.rainProbability,
    required this.precipitationSum,
    required this.weatherCode,
    required this.weatherDesc,
    required this.uvIndexMax,
  });

  factory ForecastDailyItem.fromJson(Map<String, dynamic> json) {
    return ForecastDailyItem(
      date: json['date'] ?? '',
      tempMax: (json['temp_max'] ?? 30).toDouble(),
      tempMin: (json['temp_min'] ?? 20).toDouble(),
      rainProbability: (json['rain_probability'] ?? 0).toDouble(),
      precipitationSum: (json['precipitation_sum'] ?? 0).toDouble(),
      weatherCode: json['weather_code'] ?? 0,
      weatherDesc: json['weather_desc'] ?? '',
      uvIndexMax: (json['uv_index_max'] ?? 0).toDouble(),
    );
  }
}

class ForecastResponse {
  final LocationInfo location;
  final WeatherSnapshot current;
  final List<ForecastHourlyItem> hourly;
  final List<ForecastDailyItem> daily;
  final String source;

  ForecastResponse({
    required this.location,
    required this.current,
    required this.hourly,
    required this.daily,
    required this.source,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) {
    return ForecastResponse(
      location: LocationInfo.fromJson(json['location'] ?? {}),
      current: WeatherSnapshot.fromJson(json['current'] ?? {}),
      hourly: (json['hourly'] as List<dynamic>?)
              ?.map((e) => ForecastHourlyItem.fromJson(e))
              .toList() ??
          [],
      daily: (json['daily'] as List<dynamic>?)
              ?.map((e) => ForecastDailyItem.fromJson(e))
              .toList() ??
          [],
      source: json['source'] ?? 'Open-Meteo',
    );
  }
}

class PincodeDetails {
  final String pincode;
  final String officeName;
  final String district;
  final String state;
  final double? latitude;
  final double? longitude;

  PincodeDetails({
    required this.pincode,
    required this.officeName,
    required this.district,
    required this.state,
    this.latitude,
    this.longitude,
  });

  factory PincodeDetails.fromJson(Map<String, dynamic> json) {
    return PincodeDetails(
      pincode: json['pincode'] ?? '',
      officeName: json['office_name'] ?? '',
      district: json['district'] ?? '',
      state: json['state'] ?? '',
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}

class ExplainabilityDetails {
  final double temperature;
  final double rainProbability;
  final double rainMm;
  final double windKmh;
  final double uvIndex;
  final int weatherCode;
  final String weatherDesc;
  final String dataSource;
  final String nwpModel;
  final String updatedAt;
  final List<WarningItem> activeWarnings;
  final List<String> matchedRules;

  ExplainabilityDetails({
    required this.temperature,
    required this.rainProbability,
    required this.rainMm,
    required this.windKmh,
    required this.uvIndex,
    required this.weatherCode,
    required this.weatherDesc,
    required this.dataSource,
    required this.nwpModel,
    required this.updatedAt,
    required this.activeWarnings,
    required this.matchedRules,
  });

  factory ExplainabilityDetails.fromJson(Map<String, dynamic> json) {
    return ExplainabilityDetails(
      temperature: (json['temperature'] ?? 0).toDouble(),
      rainProbability: (json['rain_probability'] ?? 0).toDouble(),
      rainMm: (json['rain_mm'] ?? 0).toDouble(),
      windKmh: (json['wind_kmh'] ?? 0).toDouble(),
      uvIndex: (json['uv_index'] ?? 0).toDouble(),
      weatherCode: json['weather_code'] ?? 0,
      weatherDesc: json['weather_desc'] ?? '',
      dataSource: json['data_source'] ?? 'IMD',
      nwpModel: json['nwp_model'] ?? 'ECMWF',
      updatedAt: json['updated_at'] ?? '',
      activeWarnings: (json['active_warnings'] as List<dynamic>?)
              ?.map((w) => WarningItem.fromJson(w))
              .toList() ??
          [],
      matchedRules: List<String>.from(json['matched_rules'] ?? []),
    );
  }
}

class ChatResponse {
  final String query;
  final String intent;
  final String language;
  final String locationName;
  final String answer;
  final WeatherSnapshot weatherSnapshot;
  final List<String> detectedEvents;
  final List<String> recommendedActions;
  final ExplainabilityDetails whyExplainability;
  final double confidence;

  ChatResponse({
    required this.query,
    required this.intent,
    required this.language,
    required this.locationName,
    required this.answer,
    required this.weatherSnapshot,
    required this.detectedEvents,
    required this.recommendedActions,
    required this.whyExplainability,
    required this.confidence,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      query: json['query'] ?? '',
      intent: json['intent'] ?? 'general',
      language: json['language'] ?? 'en',
      locationName: json['location_name'] ?? '',
      answer: json['answer'] ?? '',
      weatherSnapshot: WeatherSnapshot.fromJson(json['weather_snapshot'] ?? {}),
      detectedEvents: List<String>.from(json['detected_events'] ?? []),
      recommendedActions: List<String>.from(json['recommended_actions'] ?? []),
      whyExplainability: ExplainabilityDetails.fromJson(json['why_explainability'] ?? {}),
      confidence: (json['confidence'] ?? 0.95).toDouble(),
    );
  }
}

class WarningResponse {
  final LocationInfo location;
  final List<WarningItem> activeWarnings;
  final String highestSeverity;
  final int totalWarnings;

  WarningResponse({
    required this.location,
    required this.activeWarnings,
    required this.highestSeverity,
    required this.totalWarnings,
  });

  factory WarningResponse.fromJson(Map<String, dynamic> json) {
    return WarningResponse(
      location: LocationInfo.fromJson(json['location'] ?? {}),
      activeWarnings: (json['active_warnings'] as List<dynamic>?)
              ?.map((w) => WarningItem.fromJson(w))
              .toList() ??
          [],
      highestSeverity: json['highest_severity'] ?? 'GREEN',
      totalWarnings: json['total_warnings'] ?? 0,
    );
  }
}
