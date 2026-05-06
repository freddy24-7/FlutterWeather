import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/data/models/weather_model.dart';
import 'package:cinematic_weather/data/sources/weather_source.dart';

class WeatherMockSource implements WeatherSource {
  static const _db = <String, WeatherModel>{
    'amsterdam': WeatherModel(
      cityName: 'Amsterdam',
      temperatureCelsius: 18.5,
      feelsLikeCelsius: 16.0,
      humidity: 72,
      conditionMain: 'Clear',
      conditionDescription: 'clear sky',
      iconCode: '01d',
      lat: 52.374,
      lon: 4.890,
    ),
    'london': WeatherModel(
      cityName: 'London',
      temperatureCelsius: 12.0,
      feelsLikeCelsius: 9.5,
      humidity: 85,
      conditionMain: 'Rain',
      conditionDescription: 'light rain',
      iconCode: '10d',
      lat: 51.507,
      lon: -0.128,
    ),
    'oslo': WeatherModel(
      cityName: 'Oslo',
      temperatureCelsius: -3.0,
      feelsLikeCelsius: -7.0,
      humidity: 90,
      conditionMain: 'Snow',
      conditionDescription: 'light snow',
      iconCode: '13d',
      lat: 59.913,
      lon: 10.752,
    ),
    'tokyo': WeatherModel(
      cityName: 'Tokyo',
      temperatureCelsius: 28.0,
      feelsLikeCelsius: 31.0,
      humidity: 78,
      conditionMain: 'Clouds',
      conditionDescription: 'overcast clouds',
      iconCode: '04d',
      lat: 35.690,
      lon: 139.692,
    ),
    'miami': WeatherModel(
      cityName: 'Miami',
      temperatureCelsius: 34.0,
      feelsLikeCelsius: 38.0,
      humidity: 88,
      conditionMain: 'Thunderstorm',
      conditionDescription: 'heavy thunderstorm',
      iconCode: '11d',
      lat: 25.775,
      lon: -80.209,
    ),
  };

  @override
  Future<WeatherModel> fetchWeather(String city) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final model = _db[city.toLowerCase()];
    if (model == null) throw CityNotFoundFailure(city);
    return model;
  }
}
