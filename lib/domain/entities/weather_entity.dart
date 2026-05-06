import 'package:flutter/foundation.dart';

@immutable
class WeatherEntity {
  const WeatherEntity({
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

  WeatherEntity copyWith({
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
      WeatherEntity(
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherEntity &&
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
