import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/city_suggestion.dart';

// OpenWeatherMap API key.
const String apiKey = '9519d523e987e2928b5bf1dd8b363760';

class WeatherService {
  Future<Weather> getWeather(String city) async {
    // API Key validation
    if (apiKey.isEmpty) {
      throw Exception(
        'Please add your valid OpenWeatherMap API key in weather_service.dart',
      );
    }

    // Fetch Coordinates (Lat(latitude), Lon(longitude))

    final geoUrl = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=$city&limit=1&appid=$apiKey',
    );

    final geoResponse = await http.get(geoUrl);

    if (geoResponse.statusCode != 200) {
      throw Exception(
        'Location lookup failed. Status: ${geoResponse.statusCode}',
      );
    }

    final List<dynamic> geoJson = jsonDecode(geoResponse.body);
    if (geoJson.isEmpty) {
      throw Exception('City not found. Please try another city.');
    }

    final double lat = (geoJson[0]['lat'] as num).toDouble();
    final double lon = (geoJson[0]['lon'] as num).toDouble();

    // Fetch Weather using Lat/Lon (latitude, longitude)
    final weatherUrl = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather'
      '?lat=$lat&lon=$lon&units=metric&appid=$apiKey',
    );

    final response = await http.get(weatherUrl);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Invalid API Key — please generate a new one.');
    } else {
      throw Exception(
        'Failed to load weather data. Status: ${response.statusCode}',
      );
    }
  }

  // Fetch city suggestions for autocomplete
  Future<List<CitySuggestion>> getCitySuggestions(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }

    if (apiKey.isEmpty) {
      return [];
    }

    try {
      final geoUrl = Uri.parse(
        'https://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$apiKey',
      );

      final geoResponse = await http.get(geoUrl);

      if (geoResponse.statusCode != 200) {
        return [];
      }

      final List<dynamic> geoJson = jsonDecode(geoResponse.body);
      return geoJson.map((json) => CitySuggestion.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
