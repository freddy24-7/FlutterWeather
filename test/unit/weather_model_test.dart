import 'package:flutter_test/flutter_test.dart';

import 'package:cinematic_weather/data/models/weather_model.dart';
import '../fixtures/weather_fixtures.dart';

void main() {
  group('WeatherModel', () {
    test(
      'given valid JSON, when fromJson is called, then all fields parse correctly',
      () {
        final model = WeatherModel.fromJson(WeatherFixtures.amsterdamJson);

        expect(model.cityName, 'Amsterdam');
        expect(model.temperatureCelsius, 18.5);
        expect(model.feelsLikeCelsius, 16.0);
        expect(model.humidity, 72);
        expect(model.conditionMain, 'Clear');
        expect(model.conditionDescription, 'clear sky');
        expect(model.iconCode, '01d');
      },
    );

    test(
      'given JSON with numeric temperature as int, when fromJson is called, then converts to double',
      () {
        final json = {
          'name': 'TestCity',
          'main': {'temp': 20, 'feels_like': 18, 'humidity': 60},
          'weather': [
            {'main': 'Clouds', 'description': 'cloudy', 'icon': '03d'}
          ],
        };

        final model = WeatherModel.fromJson(json);
        expect(model.temperatureCelsius, 20.0);
        expect(model.feelsLikeCelsius, 18.0);
        expect(model.temperatureCelsius, isA<double>());
      },
    );

    test(
      'given two models with same data, when compared, then equality holds',
      () {
        final a = WeatherModel.fromJson(WeatherFixtures.amsterdamJson);
        final b = WeatherModel.fromJson(WeatherFixtures.amsterdamJson);

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      },
    );

    test(
      'given two models with different data, when compared, then not equal',
      () {
        final amsterdam = WeatherModel.fromJson(WeatherFixtures.amsterdamJson);
        final london = WeatherModel.fromJson(WeatherFixtures.londonJson);

        expect(amsterdam, isNot(equals(london)));
      },
    );

    test(
      'given existing model, when copyWith called with new city, then only city changes',
      () {
        const original = WeatherFixtures.amsterdamModel;
        final copy = original.copyWith(cityName: 'London');

        expect(copy.cityName, 'London');
        expect(copy.temperatureCelsius, original.temperatureCelsius);
        expect(copy.feelsLikeCelsius, original.feelsLikeCelsius);
        expect(copy.humidity, original.humidity);
        expect(copy.conditionMain, original.conditionMain);
      },
    );

    test(
      'given a model, when toJson called then fromJson on result, then roundtrip is lossless',
      () {
        const original = WeatherFixtures.amsterdamModel;
        final json = original.toJson();
        final restored = WeatherModel.fromJson(json);

        expect(restored, equals(original));
      },
    );

    test(
      'given a model, when toEntity is called, then entity has same field values',
      () {
        const model = WeatherFixtures.amsterdamModel;
        final entity = model.toEntity();

        expect(entity.cityName, model.cityName);
        expect(entity.temperatureCelsius, model.temperatureCelsius);
        expect(entity.feelsLikeCelsius, model.feelsLikeCelsius);
        expect(entity.humidity, model.humidity);
        expect(entity.conditionMain, model.conditionMain);
      },
    );
  });
}
