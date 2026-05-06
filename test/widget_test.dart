import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinematic_weather/core/preferences.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/presentation/providers/weather_provider.dart';
import 'package:cinematic_weather/presentation/screens/root_screen.dart';
import 'fixtures/fake_preferences.dart';

class _FakeWeatherNotifier extends WeatherNotifier {
  @override
  Future<WeatherEntity?> build() async {
    state = const AsyncValue.loading();
    return null;
  }
}

void main() {
  testWidgets('app smoke test — RootScreen renders without crashing',
      (tester) async {
    final fakePrefs = await makeFakePreferences();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(fakePrefs),
          weatherNotifierProvider.overrideWith(() => _FakeWeatherNotifier()),
        ],
        child: const MaterialApp(home: RootScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(RootScreen), findsOneWidget);
  });
}
