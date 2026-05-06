# Agent: Flutter Testing

## Purpose
Defines the testing strategy, conventions, and templates for the Cinematic Weather Demo. Reference this when generating any test file.

---

## Test Pyramid

```
         ┌─────────────┐
         │ Integration │  1 test suite (app_test.dart)
         │    Tests    │  Runs on real device/emulator
         └──────┬──────┘
          ┌─────┴──────┐
          │   Widget   │  1 file per screen/widget with complex logic
          │   Tests    │  Uses ProviderScope overrides, no real HTTP
          └──────┬─────┘
      ┌──────────┴──────────┐
      │     Unit Tests      │  1 file per class
      │  (model, repo, use  │  Pure Dart, mocktail for HTTP
      │   case, notifier)   │
      └─────────────────────┘
```

---

## Package Setup

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mocktail: ^1.0.4       # Mock generation without codegen
  flutter_lints: ^4.0.0
```

No `mockito` — use `mocktail` to avoid `build_runner` for mocks.

---

## Mocktail Setup Pattern

```dart
// Define mock at top of file
class MockWeatherRemoteSource extends Mock implements WeatherRemoteSource {}
class MockGetWeatherUseCase extends Mock implements GetWeatherUseCase {}

// Register fallback values for complex types
setUpAll(() {
  registerFallbackValue(const CityNotFoundFailure(''));
});
```

---

## Unit Test Templates

### Model parsing test
```dart
// test/unit/weather_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cinematic_weather/data/models/weather_model.dart';

void main() {
  group('WeatherModel', () {
    const validJson = {
      'name': 'Amsterdam',
      'main': {
        'temp': 18.5,
        'feels_like': 16.0,
        'humidity': 72,
      },
      'weather': [
        {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
      ],
    };

    test(
      'given valid JSON, when fromJson called, then all fields parsed correctly',
      () {
        final model = WeatherModel.fromJson(validJson);
        expect(model.cityName, 'Amsterdam');
        expect(model.temperatureCelsius, 18.5);
        expect(model.conditionMain, 'Clear');
        expect(model.iconCode, '01d');
      },
    );

    test('given same data, when compared, then equality holds', () {
      final a = WeatherModel.fromJson(validJson);
      final b = WeatherModel.fromJson(validJson);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('given existing model, when copyWith called, then only specified field changes', () {
      final original = WeatherModel.fromJson(validJson);
      final copy = original.copyWith(cityName: 'London');
      expect(copy.cityName, 'London');
      expect(copy.temperatureCelsius, original.temperatureCelsius);
    });
  });
}
```

### Repository test with HTTP mocking
```dart
// test/unit/weather_repository_test.dart
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;
import 'package:cinematic_weather/data/repositories/weather_repository_impl.dart';
import 'package:cinematic_weather/domain/errors/failures.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  group('WeatherRepositoryImpl', () {
    late MockHttpClient mockClient;
    late WeatherRepositoryImpl repo;

    setUp(() {
      mockClient = MockHttpClient();
      repo = WeatherRepositoryImpl.withClient(mockClient);
    });

    test(
      'given HTTP 200 with valid body, when getWeather called, then returns entity',
      () async {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(_validResponseBody, 200));

        final entity = await repo.getWeather('Amsterdam');
        expect(entity.cityName, 'Amsterdam');
      },
    );

    test(
      'given HTTP 404, when getWeather called, then throws CityNotFoundFailure',
      () {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('{"cod":"404"}', 404));

        expect(
          () => repo.getWeather('Faketown'),
          throwsA(isA<CityNotFoundFailure>()),
        );
      },
    );

    test(
      'given SocketException, when getWeather called, then throws NetworkFailure',
      () {
        when(() => mockClient.get(any(), headers: any(named: 'headers')))
            .thenThrow(const SocketException('No network'));

        expect(
          () => repo.getWeather('Amsterdam'),
          throwsA(isA<NetworkFailure>()),
        );
      },
    );
  });
}

const _validResponseBody = '''
{
  "name": "Amsterdam",
  "main": {"temp": 18.5, "feels_like": 16.0, "humidity": 72},
  "weather": [{"main": "Clear", "description": "clear sky", "icon": "01d"}]
}
''';
```

---

## Widget Test Templates

### HomeScreen state tests
```dart
// test/widget/home_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cinematic_weather/presentation/screens/home_screen.dart';
import 'package:cinematic_weather/presentation/providers/weather_provider.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';

// Fake notifier that lets tests set state directly
class FakeWeatherNotifier extends WeatherNotifier {
  FakeWeatherNotifier(this._state);
  final AsyncValue<WeatherEntity?> _state;

  @override
  Future<WeatherEntity?> build() async =>
      _state.valueOrNull;
}

Widget buildSubject(AsyncValue<WeatherEntity?> state) {
  return ProviderScope(
    overrides: [
      weatherNotifierProvider.overrideWith(() => FakeWeatherNotifier(state)),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

const _amsterdam = WeatherEntity(
  cityName: 'Amsterdam',
  temperatureCelsius: 18.5,
  feelsLikeCelsius: 16.0,
  humidity: 72,
  conditionMain: 'Clear',
  conditionDescription: 'clear sky',
  iconCode: '01d',
);

void main() {
  group('HomeScreen', () {
    testWidgets(
      'given loading state, when rendered, then shimmer is visible',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(const AsyncValue.loading()),
        );
        expect(find.byType(LoadingShimmer), findsOneWidget);
      },
    );

    testWidgets(
      'given data state, when rendered, then city and temperature appear',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(const AsyncValue.data(_amsterdam)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Amsterdam'), findsOneWidget);
        expect(find.textContaining('18'), findsOneWidget); // 18.5°C
        expect(find.text('Clear'), findsOneWidget);
      },
    );

    testWidgets(
      'given CityNotFoundFailure, when rendered, then error message visible',
      (tester) async {
        await tester.pumpWidget(
          buildSubject(
            AsyncValue.error(
              const CityNotFoundFailure('Faketown'),
              StackTrace.empty,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('not found'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );
  });
}
```

### Lottie animation selection test
```dart
// test/widget/weather_animation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/presentation/widgets/weather_animation.dart';

void main() {
  group('lottieUrlForCondition', () {
    test('given "Clear", returns sunny URL', () {
      expect(lottieUrlForCondition('Clear'), LottieAssets.sunny);
    });

    test('given "Rain", returns rainy URL', () {
      expect(lottieUrlForCondition('Rain'), LottieAssets.rainy);
    });

    test('given "Drizzle", returns rainy URL', () {
      expect(lottieUrlForCondition('Drizzle'), LottieAssets.rainy);
    });

    test('given "Snow", returns snowy URL', () {
      expect(lottieUrlForCondition('Snow'), LottieAssets.snowy);
    });

    test('given unknown condition, returns mist URL as fallback', () {
      expect(lottieUrlForCondition('Volcano'), LottieAssets.mist);
    });

    test('given mixed case "cLEAR", still returns sunny URL', () {
      expect(lottieUrlForCondition('cLEAR'), LottieAssets.sunny);
    });
  });
}
```

---

## Integration Test Template

```dart
// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:cinematic_weather/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end: City weather flow', () {
    testWidgets('open app → default city loads → search updates UI', (tester) async {
      // Uses mock source (no API key needed)
      app.main();
      await tester.pump(); // start frame

      // Step 1: Loading state visible immediately
      // (shimmer may be too brief to catch reliably — skip or use pump(duration))

      // Step 2: Default city (Amsterdam) appears
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Amsterdam'), findsOneWidget);

      // Step 3: Search for London
      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'London');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Step 4: UI updates
      expect(find.text('London'), findsOneWidget);
      expect(find.text('Amsterdam'), findsNothing);
    });

    testWidgets('searching unknown city shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      await tester.tap(searchField);
      await tester.enterText(searchField, 'XYZ_NONEXISTENT_CITY');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.textContaining('not found'), findsOneWidget);
    });
  });
}
```

---

## Running Tests

```bash
# All unit + widget tests
flutter test

# Specific phase
flutter test test/unit/
flutter test test/widget/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# Integration (requires device/emulator)
flutter test integration_test/app_test.dart

# Verbose output
flutter test --reporter expanded
```

---

## Test Data Fixtures

Keep shared test fixtures in `test/fixtures/`:

```dart
// test/fixtures/weather_fixtures.dart
import 'package:cinematic_weather/domain/entities/weather_entity.dart';

class WeatherFixtures {
  static const amsterdam = WeatherEntity(
    cityName: 'Amsterdam',
    temperatureCelsius: 18.5,
    feelsLikeCelsius: 16.0,
    humidity: 72,
    conditionMain: 'Clear',
    conditionDescription: 'clear sky',
    iconCode: '01d',
  );

  static const london = WeatherEntity(
    cityName: 'London',
    temperatureCelsius: 12.0,
    feelsLikeCelsius: 9.5,
    humidity: 85,
    conditionMain: 'Rain',
    conditionDescription: 'light rain',
    iconCode: '10d',
  );

  static const oslo = WeatherEntity(
    cityName: 'Oslo',
    temperatureCelsius: -3.0,
    feelsLikeCelsius: -7.0,
    humidity: 90,
    conditionMain: 'Snow',
    conditionDescription: 'light snow',
    iconCode: '13d',
  );

  static const Map<String, dynamic> amsterdamJson = {
    'name': 'Amsterdam',
    'main': {'temp': 18.5, 'feels_like': 16.0, 'humidity': 72},
    'weather': [
      {'main': 'Clear', 'description': 'clear sky', 'icon': '01d'}
    ],
  };
}
```
