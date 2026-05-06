import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/domain/repositories/weather_repository.dart';

class GetWeatherUseCase {
  const GetWeatherUseCase(this._repository);

  final WeatherRepository _repository;

  Future<WeatherEntity> call(String city) => _repository.getWeather(city);
}
