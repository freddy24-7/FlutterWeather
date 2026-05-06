# Cinematic Weather Demo — Project Guide for Claude Code

## Project Overview

A production-quality Flutter app demonstrating cinematic UI with live weather data, Lottie animations, and clean architecture. Built in 4 phases, each fully tested before the next begins.

## Tech Stack

| Concern | Choice | Reason |
|---|---|---|
| Language | Dart (sound null safety) | Required by Flutter |
| State management | **Riverpod** (flutter_riverpod ^2.x) | Industry standard 2025–2026; compile-safe, testable |
| Networking | `http` package | Lightweight, mockable in tests |
| Animations | `lottie` package + public LottieFiles CDN URLs | No local asset downloads required to run |
| Architecture | Clean Architecture (Data → Domain → Presentation) | Separation of concerns, easy to test |
| Testing | `flutter_test`, `mocktail`, `integration_test` | Full unit + widget + integration coverage |

## Project Structure

```
lib/
  core/
    constants.dart          # API base URL, key placeholder, animation URLs
    errors/
      failures.dart         # CityNotFound, NetworkFailure, etc.
    theme/
      app_theme.dart        # Apple-style dark/light theme tokens
  data/
    models/
      weather_model.dart    # Dart model, fromJson, toJson
    sources/
      weather_remote_source.dart   # Real HTTP calls
      weather_mock_source.dart     # Mock for dev/testing
    repositories/
      weather_repository_impl.dart
  domain/
    entities/
      weather_entity.dart   # Pure domain object (no JSON)
    repositories/
      weather_repository.dart  # Abstract interface
    usecases/
      get_weather_usecase.dart
  presentation/
    providers/
      weather_provider.dart  # Riverpod AsyncNotifier
    screens/
      home_screen.dart
    widgets/
      temperature_display.dart
      city_search_bar.dart
      weather_animation.dart  # Lottie switcher
      loading_shimmer.dart
test/
  unit/
    weather_model_test.dart
    weather_repository_test.dart
    get_weather_usecase_test.dart
  widget/
    home_screen_test.dart
    weather_animation_test.dart
integration_test/
  app_test.dart
```

## API Configuration

```dart
// lib/core/constants.dart
class AppConstants {
  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  // Replace with real key or leave empty to use mock service
  static const String apiKey = String.fromEnvironment(
    'OWM_API_KEY',
    defaultValue: '', // empty → MockWeatherSource is used automatically
  );

  static bool get useMock => apiKey.isEmpty;
}
```

**Running with a real key:**
```bash
flutter run --dart-define=OWM_API_KEY=your_key_here
```

**Running without a key (mock mode — works immediately):**
```bash
flutter run
```

## Lottie Asset Strategy

Use public CDN URLs from LottieFiles — no downloads needed:

```dart
class LottieAssets {
  static const String sunny =
      'https://assets5.lottiefiles.com/packages/lf20_xlmz9xwm.json';
  static const String rainy =
      'https://assets9.lottiefiles.com/packages/lf20_rpC1Rd.json';
  static const String cloudy =
      'https://assets3.lottiefiles.com/packages/lf20_puciaact.json';
  static const String snowy =
      'https://assets9.lottiefiles.com/packages/lf20_hdo6t9de.json';
  static const String thunderstorm =
      'https://assets5.lottiefiles.com/packages/lf20_bpa2gjzu.json';
  static const String mist =
      'https://assets5.lottiefiles.com/packages/lf20_d8oanrob.json';
}
```

## Weather → Animation Mapping

```dart
String lottieUrlForCondition(String condition) => switch (condition.toLowerCase()) {
  'clear'        => LottieAssets.sunny,
  'rain' ||
  'drizzle'      => LottieAssets.rainy,
  'clouds'       => LottieAssets.cloudy,
  'snow'         => LottieAssets.snowy,
  'thunderstorm' => LottieAssets.thunderstorm,
  _              => LottieAssets.mist,
};
```

## Build Phases

### Phase 1 — Data Layer & Logic
**Goal:** `WeatherModel`, `WeatherService`, error handling.

Deliver:
- `WeatherModel` (fromJson, toJson, `==`, `copyWith`)
- `WeatherRemoteSource` + `WeatherMockSource` (toggle via `AppConstants.useMock`)
- `WeatherRepository` (abstract) + `WeatherRepositoryImpl`
- `GetWeatherUseCase`
- **All failure types**: `CityNotFoundFailure`, `NetworkFailure`, `UnknownFailure`
- Unit tests mocking HTTP with `mocktail`; verify parsing and error paths

Do NOT proceed to Phase 2 until all Phase 1 tests pass (`flutter test test/unit/`).

---

### Phase 2 — UI Foundation
**Goal:** Main dashboard layout.

Deliver:
- `HomeScreen` with `Stack` layout (background layer + foreground content)
- `TemperatureDisplay` widget (large bold numerals, feels-like, humidity)
- `CitySearchBar` widget (submit on enter / search icon tap)
- Apple-style typography: SF Pro-like fonts via Google Fonts (`Inter` or `Nunito`)
- Riverpod `AsyncNotifier` (`WeatherNotifier`) managing city search state
- Widget tests: temperature and city name render correctly; search bar triggers provider

Do NOT proceed to Phase 3 until all Phase 2 tests pass (`flutter test test/widget/`).

---

### Phase 3 — Cinematic Factor (Lottie)
**Goal:** Dynamic background animations.

Deliver:
- `WeatherAnimation` widget: loads Lottie from URL, fills background
- `BackdropFilter` (blur + dark overlay) to keep text readable over animation
- `AnimatedSwitcher` wrapping `WeatherAnimation` for crossfade on condition change
- Widget test: given weather state `"Clear"`, verify `LottieAssets.sunny` URL is used; given `"Rain"`, verify rain URL

Do NOT proceed to Phase 4 until all Phase 3 tests pass (`flutter test test/widget/`).

---

### Phase 4 — Refinement & Polish
**Goal:** Loading states, transitions, production finish.

Deliver:
- `LoadingShimmer` widget shown during `AsyncValue.loading`
- Error screen with retry button for failures
- Smooth `AnimatedSwitcher` transitions (300 ms fade) between weather states
- Integration test (`integration_test/app_test.dart`):
  1. App opens → loading shimmer visible
  2. Mock resolves → default city weather displayed
  3. User types new city in search bar and submits
  4. New city name and temperature appear on screen

---

## Code Standards

### Null Safety
- All code must use Dart sound null safety
- No `!` force-unwraps without a preceding null check or documented assertion
- Use `required` named params over positional where ambiguity exists

### Error Handling Pattern
```dart
// Use Either-style or sealed classes — choose ONE and be consistent
sealed class WeatherFailure {
  const WeatherFailure();
}
class CityNotFoundFailure extends WeatherFailure { ... }
class NetworkFailure extends WeatherFailure { ... }
```

### Riverpod Pattern
```dart
// Use AsyncNotifier for async state
class WeatherNotifier extends AsyncNotifier<WeatherEntity?> {
  @override
  Future<WeatherEntity?> build() async => null; // empty on start

  Future<void> fetchWeather(String city) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getWeatherUseCaseProvider).call(city),
    );
  }
}
```

### Testing Conventions
- Mock HTTP client with `mocktail`: never hit real network in unit/widget tests
- Use `ProviderContainer` for unit-testing Riverpod providers in isolation
- Each test file has a `group()` per class and a `setUp()` for shared fixtures
- Test names follow: `'given [state], when [action], then [outcome]'`

## pubspec.yaml Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  http: ^1.2.1
  lottie: ^3.1.0
  google_fonts: ^6.2.1
  cached_network_image: ^3.3.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  build_runner: ^2.4.9
  riverpod_generator: ^2.4.0
  mocktail: ^1.0.4
  flutter_lints: ^4.0.0
```

## Running Tests

```bash
# Unit + widget tests
flutter test

# Integration tests (requires connected device/emulator)
flutter test integration_test/app_test.dart

# With coverage report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

## UI Design Tokens

```dart
// Apple-inspired palette
static const Color backgroundDark   = Color(0xFF0A0A1A);
static const Color surfaceCard      = Color(0x1AFFFFFF); // 10% white
static const Color textPrimary      = Color(0xFFFFFFFF);
static const Color textSecondary    = Color(0xB3FFFFFF); // 70% white
static const Color accentBlue       = Color(0xFF4FC3F7);

// Typography scale
static const double tempFontSize    = 96.0;
static const double cityFontSize    = 32.0;
static const double labelFontSize   = 16.0;
```

## Known Constraints & Decisions

- **Lottie CDN**: URLs are public but may change; wrap in a `FutureBuilder` or `LottieBuilder.network` with an error fallback to a static icon.
- **No local Lottie files**: keeps the project runnable without asset setup.
- **Mock mode**: when `OWM_API_KEY` is not set, `WeatherMockSource` returns a rotating set of fake cities so all UI states are testable offline.
- **Platform**: iOS + Android primary. Web support is optional (Lottie network URLs work on web).
