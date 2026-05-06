import 'package:cinematic_weather/domain/entities/weather_entity.dart';

abstract class WeatherRepository {
  Future<WeatherEntity> getWeather(String city);
}
