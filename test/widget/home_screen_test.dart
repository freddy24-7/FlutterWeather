import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/core/preferences.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/presentation/providers/weather_provider.dart';
import 'package:cinematic_weather/presentation/screens/home_screen.dart';
import 'package:cinematic_weather/presentation/widgets/loading_shimmer.dart';
import '../fixtures/fake_preferences.dart';

Future<ProviderScope> _buildScope(
  AsyncValue<WeatherEntity?> fixedState, {
  VoidCallback? onRetry,
  String? pinnedCity,
}) async {
  final fakePrefs = await makeFakePreferences(savedCity: pinnedCity);
  return ProviderScope(
    overrides: [
      preferencesProvider.overrideWithValue(fakePrefs),
      weatherNotifierProvider.overrideWith(
          () => _StubNotifier(fixedState, onRetry: onRetry)),
      if (pinnedCity != null)
        defaultCityProvider.overrideWith((ref) => pinnedCity),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

class _StubNotifier extends WeatherNotifier {
  _StubNotifier(this._value, {this.onRetry});
  final AsyncValue<WeatherEntity?> _value;
  final VoidCallback? onRetry;

  @override
  Future<WeatherEntity?> build() {
    return switch (_value) {
      AsyncData(:final value)  => Future.value(value),
      AsyncError(:final error) => Future.error(error, StackTrace.empty),
      _                        => Completer<WeatherEntity?>().future,
    };
  }

  @override
  Future<void> fetchWeather(String city) async {}

  @override
  Future<void> retry() async => onRetry?.call();
}

Future<void> _pump(
  WidgetTester tester,
  AsyncValue<WeatherEntity?> state, {
  VoidCallback? onRetry,
  String? pinnedCity,
}) async {
  GoogleFonts.config.allowRuntimeFetching = false;
  await tester.pumpWidget(
      await _buildScope(state, onRetry: onRetry, pinnedCity: pinnedCity));
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 20));
  }
}

const _amsterdam = WeatherEntity(
  cityName: 'Amsterdam',
  temperatureCelsius: 18.5,
  feelsLikeCelsius: 16.0,
  humidity: 72,
  conditionMain: 'Clear',
  conditionDescription: 'clear sky',
  iconCode: '01d',
  lat: 52.374,
  lon: 4.890,
);

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  group('HomeScreen', () {
    testWidgets(
      'given loading state, when HomeScreen renders, then LoadingShimmer is visible',
      (tester) async {
        await _pump(tester, const AsyncValue.loading());
        expect(find.byType(LoadingShimmer), findsOneWidget);
      },
    );

    testWidgets(
      'given data state with Amsterdam/Clear, when HomeScreen renders, then city name and condition appear',
      (tester) async {
        await _pump(tester, const AsyncValue.data(_amsterdam));
        expect(find.text('Amsterdam', skipOffstage: false), findsOneWidget);
        expect(find.text('Clear', skipOffstage: false), findsOneWidget);
        expect(find.textContaining('19', skipOffstage: false), findsOneWidget);
      },
    );

    testWidgets(
      'given error state CityNotFoundFailure, when HomeScreen renders, then "not found" and Retry button appear',
      (tester) async {
        await _pump(tester, const AsyncValue.error(
            CityNotFoundFailure('Faketown'), StackTrace.empty));
        expect(find.textContaining('not found', skipOffstage: false), findsOneWidget);
        expect(find.text('Retry', skipOffstage: false), findsOneWidget);
      },
    );

    testWidgets(
      'given NetworkFailure, when HomeScreen renders, then "No internet" message appears',
      (tester) async {
        await _pump(tester, const AsyncValue.error(
            NetworkFailure(), StackTrace.empty));
        expect(find.textContaining('internet', skipOffstage: false), findsOneWidget);
        expect(find.text('Retry', skipOffstage: false), findsOneWidget);
      },
    );

    testWidgets(
      'given retry button tapped, when CityNotFoundFailure is shown, then retry action is invoked',
      (tester) async {
        var retryCalled = false;
        await _pump(
          tester,
          const AsyncValue.error(
              CityNotFoundFailure('Faketown'), StackTrace.empty),
          onRetry: () => retryCalled = true,
        );
        await tester.tap(find.text('Retry', skipOffstage: false));
        await tester.pump();
        expect(retryCalled, isTrue);
      },
    );

    testWidgets(
      'given data state with no pinned city, when HomeScreen renders, then "Set as default" button appears',
      (tester) async {
        await _pump(tester, const AsyncValue.data(_amsterdam));
        expect(find.text('Set as default', skipOffstage: false), findsOneWidget);
      },
    );

    testWidgets(
      'given data state with Amsterdam pinned, when HomeScreen renders, then "Default city" label appears',
      (tester) async {
        await _pump(tester, const AsyncValue.data(_amsterdam),
            pinnedCity: 'Amsterdam');
        expect(find.text('Default city', skipOffstage: false), findsOneWidget);
      },
    );
  });
}
