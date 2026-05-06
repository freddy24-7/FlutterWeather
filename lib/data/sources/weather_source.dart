import 'package:cinematic_weather/data/models/weather_model.dart';

abstract class WeatherSource {
  Future<WeatherModel> fetchWeather(String city);
}
