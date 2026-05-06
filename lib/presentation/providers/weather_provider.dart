import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/core/preferences.dart';
import 'package:cinematic_weather/data/repositories/weather_repository_impl.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/domain/repositories/weather_repository.dart';
import 'package:cinematic_weather/domain/usecases/get_weather_usecase.dart';

final weatherRepositoryProvider = Provider<WeatherRepository>(
  (_) => WeatherRepositoryImpl(),
);

final getWeatherUseCaseProvider = Provider<GetWeatherUseCase>(
  (ref) => GetWeatherUseCase(ref.read(weatherRepositoryProvider)),
);

/// Tracks the currently pinned default city so the UI can rebuild reactively.
/// Holds null when no city is pinned (app falls back to Amsterdam).
final defaultCityProvider = StateProvider<String?>(
  (ref) => ref.read(preferencesProvider).savedCity,
);

final weatherNotifierProvider =
    AsyncNotifierProvider<WeatherNotifier, WeatherEntity?>(
  WeatherNotifier.new,
);

class WeatherNotifier extends AsyncNotifier<WeatherEntity?> {
  String? _lastCity;

  @override
  Future<WeatherEntity?> build() async {
    final saved = ref.read(preferencesProvider).savedCity;
    await fetchWeather(saved ?? AppConstants.defaultCity);
    return state.valueOrNull;
  }

  Future<void> fetchWeather(String city) async {
    _lastCity = city;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getWeatherUseCaseProvider).call(city),
    );
  }

  Future<void> retry() async {
    final city = _lastCity;
    if (city != null) await fetchWeather(city);
  }

  /// Pins [city] as the default city shown on next app launch.
  Future<void> setDefaultCity(String city) async {
    await ref.read(preferencesProvider).saveCity(city);
    ref.read(defaultCityProvider.notifier).state = city;
  }

  /// Removes the pinned default, reverting to the built-in fallback.
  Future<void> clearDefaultCity() async {
    await ref.read(preferencesProvider).clearCity();
    ref.read(defaultCityProvider.notifier).state = null;
  }
}
