import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/data/models/weather_model.dart';
import 'package:cinematic_weather/data/sources/weather_source.dart';

class WeatherRemoteSource implements WeatherSource {
  WeatherRemoteSource({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<WeatherModel> fetchWeather(String city) async {
    final uri = Uri.parse(
      '${AppConstants.openWeatherBaseUrl}/weather'
      '?q=$city&appid=${AppConstants.apiKey}&units=metric',
    );

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 404) {
        throw CityNotFoundFailure(city);
      }

      if (response.statusCode != 200) {
        throw UnknownFailure('HTTP ${response.statusCode}');
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(json);
    } on CityNotFoundFailure {
      rethrow;
    } on UnknownFailure {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkFailure(e.message);
    } on http.ClientException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e);
    }
  }
}
