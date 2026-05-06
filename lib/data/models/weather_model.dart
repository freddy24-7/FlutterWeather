import 'package:flutter/foundation.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';

@immutable
class WeatherModel {
  const WeatherModel({
    required this.cityName,
    required this.temperatureCelsius,
    required this.feelsLikeCelsius,
    required this.humidity,
    required this.conditionMain,
    required this.conditionDescription,
    required this.iconCode,
    required this.lat,
    required this.lon,
  });

  final String cityName;
  final double temperatureCelsius;
  final double feelsLikeCelsius;
  final int humidity;
  final String conditionMain;
  final String conditionDescription;
  final String iconCode;
  final double lat;
  final double lon;

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final main = json['main'] as Map<String, dynamic>;
    final weatherList = json['weather'] as List<dynamic>;
    final weather = weatherList.first as Map<String, dynamic>;
    final coord = json['coord'] as Map<String, dynamic>? ?? {};

    return WeatherModel(
      cityName: json['name'] as String,
      temperatureCelsius: (main['temp'] as num).toDouble(),
      feelsLikeCelsius: (main['feels_like'] as num).toDouble(),
      humidity: main['humidity'] as int,
      conditionMain: weather['main'] as String,
      conditionDescription: weather['description'] as String,
      iconCode: weather['icon'] as String,
      lat: (coord['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (coord['lon'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': cityName,
        'coord': {'lat': lat, 'lon': lon},
        'main': {
          'temp': temperatureCelsius,
          'feels_like': feelsLikeCelsius,
          'humidity': humidity,
        },
        'weather': [
          {
            'main': conditionMain,
            'description': conditionDescription,
            'icon': iconCode,
          }
        ],
      };

  WeatherModel copyWith({
    String? cityName,
    double? temperatureCelsius,
    double? feelsLikeCelsius,
    int? humidity,
    String? conditionMain,
    String? conditionDescription,
    String? iconCode,
    double? lat,
    double? lon,
  }) =>
      WeatherModel(
        cityName: cityName ?? this.cityName,
        temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
        feelsLikeCelsius: feelsLikeCelsius ?? this.feelsLikeCelsius,
        humidity: humidity ?? this.humidity,
        conditionMain: conditionMain ?? this.conditionMain,
        conditionDescription: conditionDescription ?? this.conditionDescription,
        iconCode: iconCode ?? this.iconCode,
        lat: lat ?? this.lat,
        lon: lon ?? this.lon,
      );

  WeatherEntity toEntity() => WeatherEntity(
        cityName: cityName,
        temperatureCelsius: temperatureCelsius,
        feelsLikeCelsius: feelsLikeCelsius,
        humidity: humidity,
        conditionMain: conditionMain,
        conditionDescription: conditionDescription,
        iconCode: iconCode,
        lat: lat,
        lon: lon,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherModel &&
          cityName == other.cityName &&
          temperatureCelsius == other.temperatureCelsius &&
          feelsLikeCelsius == other.feelsLikeCelsius &&
          humidity == other.humidity &&
          conditionMain == other.conditionMain &&
          conditionDescription == other.conditionDescription &&
          iconCode == other.iconCode &&
          lat == other.lat &&
          lon == other.lon;

  @override
  int get hashCode => Object.hash(
        cityName,
        temperatureCelsius,
        feelsLikeCelsius,
        humidity,
        conditionMain,
        conditionDescription,
        iconCode,
        lat,
        lon,
      );
}
