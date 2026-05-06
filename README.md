# Cinematic Weather

A production-quality Flutter weather app with cinematic video backgrounds, a live radar map, and clean architecture. Runs on iOS, Android, and web.

---

## Features

### Current Weather
Search any city to see live weather data from [OpenWeatherMap](https://openweathermap.org/). The screen shows:
- Current temperature and "feels like"
- Humidity
- Weather condition (Clear, Rain, Clouds, etc.)

### Cinematic Video Backgrounds
Each weather condition triggers a matching full-screen looping video background (sunny, rainy, cloudy, snowy, thunderstorm, mist). If a video file is not present the app falls back gracefully to a Lottie animation.

### Live Radar Map
A dedicated Radar tab shows an interactive dark-mode map (CartoDB Dark Matter tiles) with selectable OpenWeatherMap weather overlays:
- **Rain** — precipitation layer
- **Clouds** — cloud cover layer
- **Wind** — wind speed layer
- **Temp** — temperature layer with a colour legend (−40 °C purple → 0 °C blue → 20 °C green → 40 °C red)

The map automatically flies to the searched city whenever weather is updated.

### Default City (Pinned City)
After searching for a city you can tap **Set as default** to pin it. The app saves the choice to local storage and opens that city automatically on every subsequent launch. Tap **Default city** again to unpin and revert to Amsterdam.

### Mock Mode
No API key? No problem. Run the app without any configuration and it uses a built-in mock source that cycles through five real cities (Amsterdam, London, Oslo, Tokyo, Miami) so every UI state is fully testable offline.

### Responsive Layout
All font sizes, padding, and shimmer block widths scale proportionally to the screen width, clamped to sensible minimums and maximums, so the app looks correct on small phones, large phones, and tablets.

### Accessibility
- Every interactive element has a screen-reader label (`Semantics`)
- The weather summary is read as a single natural sentence by TalkBack / VoiceOver
- The loading shimmer announces "Loading weather information" once instead of per-block
- Error messages use `liveRegion: true` so they are announced automatically when they appear
- The Retry button carries a descriptive hint
- Radar layer chips report their selected state to assistive technology

---

## Tech Stack

| Concern | Choice |
|---|---|
| Language | Dart 3 (sound null safety) |
| Framework | Flutter 3 |
| State management | Riverpod 2 (`AsyncNotifier`) |
| Networking | `http` |
| Animations | Lottie (local assets, MIT-licensed `@meteocons/lottie`) |
| Video | `video_player` |
| Map | `flutter_map` + CartoDB Dark Matter tiles + OWM overlay tiles |
| Local storage | `shared_preferences` |
| Architecture | Clean Architecture — Data / Domain / Presentation |
| Testing | `flutter_test`, `mocktail`, `integration_test` |
| Fonts | Google Fonts (Inter) |

---

## Project Structure

```
lib/
  core/
    constants.dart          # API config, Lottie asset paths, condition mapping
    preferences.dart        # SharedPreferences wrapper + Riverpod provider
    errors/failures.dart    # Sealed failure types
    theme/app_theme.dart    # Colour tokens, typography scale, responsive helper
    video_assets.dart       # Video asset paths per condition
  data/
    models/                 # WeatherModel (JSON ↔ entity)
    sources/                # WeatherRemoteSource + WeatherMockSource
    repositories/           # WeatherRepositoryImpl
  domain/
    entities/               # WeatherEntity (pure Dart)
    repositories/           # WeatherRepository (abstract)
    usecases/               # GetWeatherUseCase
  presentation/
    providers/              # WeatherNotifier, defaultCityProvider
    screens/                # HomeScreen, RadarScreen, RootScreen
    widgets/                # CitySearchBar, TemperatureDisplay,
                            # LoadingShimmer, VideoBackground
test/
  unit/                     # Model parsing, repository, use-case tests
  widget/                   # HomeScreen widget tests
  fixtures/                 # Shared test data and fake preferences helper
```

---

## Getting Started

### Prerequisites
- Flutter 3.10+ (`flutter doctor` should show no errors for your target platform)
- An [OpenWeatherMap API key](https://home.openweathermap.org/api_keys) — free tier is sufficient (optional; the app works without one in mock mode)

### Run without an API key (mock mode)
```bash
flutter run
```
The app uses a built-in mock data source and all UI states work offline.

### Run with a live API key
Create a `.env` file in the project root:
```
OWM_API_KEY=your_key_here
```
Then use the provided helper script:
```bash
bash run.sh
```
Or pass the key directly:
```bash
flutter run --dart-define=OWM_API_KEY=your_key_here
```

### Add video backgrounds (optional)
Download six looping MP4 files from [Pexels](https://www.pexels.com/) (search the condition name) and place them in `assets/video/`:
```
assets/video/sunny.mp4
assets/video/rainy.mp4
assets/video/cloudy.mp4
assets/video/snowy.mp4
assets/video/thunderstorm.mp4
assets/video/mist.mp4
```
If any file is missing the app falls back to the Lottie animation for that condition.

---

## Running Tests

```bash
# All unit and widget tests
flutter test

# With coverage report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html

# Integration tests (requires a connected device or emulator)
flutter test integration_test/app_test.dart
```

---

## Architecture Notes

### State management
`WeatherNotifier` is a Riverpod `AsyncNotifier<WeatherEntity?>`. Its `build()` method reads the pinned city from `SharedPreferences` (or falls back to Amsterdam) and fires the initial fetch. The `defaultCityProvider` (`StateProvider<String?>`) mirrors the pinned city in memory so any widget can reactively show the current pin state without hitting disk.

### Error handling
Failures are modelled as a sealed class hierarchy (`CityNotFoundFailure`, `NetworkFailure`, `UnknownFailure`). `AsyncValue.guard` in the notifier converts thrown exceptions into `AsyncValue.error` states, which `HomeScreen` pattern-matches to show the appropriate error message.

### Mock vs real data source
`WeatherRepositoryImpl` selects the data source at construction time based on `AppConstants.useMock` (i.e. whether `OWM_API_KEY` was provided at compile time via `--dart-define`). Swapping sources requires no changes to business logic or UI code.
