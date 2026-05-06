import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/data/sources/weather_mock_source.dart';
import 'package:cinematic_weather/data/sources/weather_remote_source.dart';
import 'package:cinematic_weather/data/sources/weather_source.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/domain/repositories/weather_repository.dart';

class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl() : _source = _defaultSource();

  WeatherRepositoryImpl.withSource(this._source);

  WeatherRepositoryImpl.withClient(http.Client client)
      : _source = WeatherRemoteSource(client: client);

  final WeatherSource _source;

  static WeatherSource _defaultSource() => AppConstants.useMock
      ? WeatherMockSource()
      : WeatherRemoteSource();

  @override
  Future<WeatherEntity> getWeather(String city) async {
    try {
      final model = await _source.fetchWeather(city);
      return model.toEntity();
    } on CityNotFoundFailure {
      rethrow;
    } on NetworkFailure {
      rethrow;
    } on SocketException catch (e) {
      throw NetworkFailure(e.message);
    } catch (e) {
      throw UnknownFailure(e);
    }
  }
}
