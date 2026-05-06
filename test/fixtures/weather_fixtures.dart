import 'package:cinematic_weather/data/models/weather_model.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';

abstract final class WeatherFixtures {
  static const Map<String, dynamic> amsterdamJson = {
    'name': 'Amsterdam',
    'coord': {'lat': 52.374, 'lon': 4.890},
    'main': {'temp': 18.5, 'feels_like': 16.0, 'humidity': 72},
    'weather': [
      {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
    ],
  };

  static const Map<String, dynamic> londonJson = {
    'name': 'London',
    'main': {'temp': 12.0, 'feels_like': 9.5, 'humidity': 85},
    'weather': [
      {'main': 'Rain', 'description': 'light rain', 'icon': '10d'}
    ],
  };

  static const WeatherModel amsterdamModel = WeatherModel(
    cityName: 'Amsterdam',
    temperatureCelsius: 18.5,
    feelsLikeCelsius: 16.0,
    humidity: 72,
    conditionMain: 'Clear',
    conditionDescription: 'clear sky',
    iconCode: '01d',
    lat: 52.374,
    lon: 4.890,
  );

  static const WeatherModel londonModel = WeatherModel(
    cityName: 'London',
    temperatureCelsius: 12.0,
    feelsLikeCelsius: 9.5,
    humidity: 85,
    conditionMain: 'Rain',
    conditionDescription: 'light rain',
    iconCode: '10d',
    lat: 51.507,
    lon: -0.128,
  );

  static const WeatherEntity amsterdamEntity = WeatherEntity(
    cityName: 'Amsterdam',
    temperatureCelsius: 18.5,
    feelsLikeCelsius: 16.0,
    humidity: 72,
    conditionMain: 'Clear',
    conditionDescription: 'clear sky',
    iconCode: '01d',
    lat: 52.374,
    lon: 4.890,
  );

  static const WeatherEntity londonEntity = WeatherEntity(
    cityName: 'London',
    temperatureCelsius: 12.0,
    feelsLikeCelsius: 9.5,
    humidity: 85,
    conditionMain: 'Rain',
    conditionDescription: 'light rain',
    iconCode: '10d',
    lat: 51.507,
    lon: -0.128,
  );

  static const WeatherEntity osloEntity = WeatherEntity(
    cityName: 'Oslo',
    temperatureCelsius: -3.0,
    feelsLikeCelsius: -7.0,
    humidity: 90,
    conditionMain: 'Snow',
    conditionDescription: 'light snow',
    iconCode: '13d',
    lat: 59.913,
    lon: 10.752,
  );

  static const String amsterdamResponseBody = '''
{
  "name": "Amsterdam",
  "coord": {"lat": 52.374, "lon": 4.890},
  "main": {"temp": 18.5, "feels_like": 16.0, "humidity": 72},
  "weather": [{"main": "Clear", "description": "clear sky", "icon": "01d"}]
}
''';
}
