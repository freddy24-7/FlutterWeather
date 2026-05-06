import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/domain/repositories/weather_repository.dart';
import 'package:cinematic_weather/domain/usecases/get_weather_usecase.dart';
import '../fixtures/weather_fixtures.dart';

class _MockWeatherRepository extends Mock implements WeatherRepository {}

void main() {
  late _MockWeatherRepository mockRepo;
  late GetWeatherUseCase useCase;

  setUp(() {
    mockRepo = _MockWeatherRepository();
    useCase = GetWeatherUseCase(mockRepo);
  });

  group('GetWeatherUseCase', () {
    test(
      'given repository returns entity, when call is invoked, then returns same entity',
      () async {
        when(() => mockRepo.getWeather('Amsterdam'))
            .thenAnswer((_) async => WeatherFixtures.amsterdamEntity);

        final result = await useCase('Amsterdam');

        expect(result, WeatherFixtures.amsterdamEntity);
        verify(() => mockRepo.getWeather('Amsterdam')).called(1);
      },
    );

    test(
      'given repository throws CityNotFoundFailure, when call is invoked, then propagates failure',
      () async {
        when(() => mockRepo.getWeather(any()))
            .thenAnswer((_) => Future.error(const CityNotFoundFailure('Nowhere')));

        await expectLater(
          useCase('Nowhere'),
          throwsA(isA<CityNotFoundFailure>()),
        );
      },
    );

    test(
      'given repository throws NetworkFailure, when call is invoked, then propagates failure',
      () async {
        when(() => mockRepo.getWeather(any()))
            .thenAnswer((_) => Future.error(const NetworkFailure()));

        await expectLater(
          useCase('Amsterdam'),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });
}
