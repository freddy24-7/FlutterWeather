import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/data/repositories/weather_repository_impl.dart';
import '../fixtures/weather_fixtures.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient mockClient;
  late WeatherRepositoryImpl repo;

  setUpAll(() {
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  setUp(() {
    mockClient = _MockHttpClient();
    repo = WeatherRepositoryImpl.withClient(mockClient);
  });

  group('WeatherRepositoryImpl', () {
    test(
      'given HTTP 200 with valid body, when getWeather is called, then returns WeatherEntity',
      () async {
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async =>
              http.Response(WeatherFixtures.amsterdamResponseBody, 200),
        );

        final entity = await repo.getWeather('Amsterdam');

        expect(entity.cityName, 'Amsterdam');
        expect(entity.temperatureCelsius, 18.5);
        expect(entity.conditionMain, 'Clear');
      },
    );

    test(
      'given HTTP 404, when getWeather is called, then throws CityNotFoundFailure',
      () async {
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response('{"cod":"404","message":"city not found"}', 404),
        );

        await expectLater(
          repo.getWeather('Faketown'),
          throwsA(isA<CityNotFoundFailure>()),
        );
      },
    );

    test(
      'given SocketException, when getWeather is called, then throws NetworkFailure',
      () async {
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenThrow(const SocketException('No route to host'));

        await expectLater(
          repo.getWeather('Amsterdam'),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );

    test(
      'given HTTP 500, when getWeather is called, then throws UnknownFailure',
      () async {
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        await expectLater(
          repo.getWeather('Amsterdam'),
          throwsA(isA<UnknownFailure>()),
        );
      },
    );
  });
}
