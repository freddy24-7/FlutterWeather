# Agent: Flutter Clean Architecture

## Purpose
This agent skill guides code generation for Flutter/Dart projects following clean architecture, Riverpod state management, and sound null safety. Reference this when generating any Dart/Flutter code in this project.

---

## Layer Rules

### Data Layer (`lib/data/`)
- **Models** are pure data classes: `fromJson`, `toJson`, `==`, `hashCode`, `copyWith`. No business logic.
- **Sources** are abstract classes with `Remote` and `Mock` implementations. Never instantiate a source directly in a widget.
- **Repository implementations** select the correct source via a feature flag or dependency injection. They translate source exceptions into domain `Failure` types.

### Domain Layer (`lib/domain/`)
- **Entities** are immutable Dart classes with no `fromJson` — they know nothing about JSON or HTTP.
- **Repository interfaces** are abstract. The domain layer owns the contract; data layer fulfils it.
- **Use cases** have a single `call()` method. One use case = one business action.

### Presentation Layer (`lib/presentation/`)
- **Providers** (`AsyncNotifier` or `Notifier`) hold all state. No `StatefulWidget` for async state.
- **Screens** are thin: they read providers and pass data to widgets.
- **Widgets** are dumb: they accept typed parameters, emit callbacks, never call providers directly (exception: leaf widgets that genuinely need global access like theme).

---

## Riverpod Patterns

### AsyncNotifier skeleton
```dart
@riverpod
class WeatherNotifier extends _$WeatherNotifier {
  @override
  Future<WeatherEntity?> build() async => null;

  Future<void> fetchWeather(String city) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(getWeatherUseCaseProvider).call(city),
    );
  }
}
```

### Provider consumption in widgets
```dart
// Preferred: watch at screen level, pass data down
final asyncWeather = ref.watch(weatherNotifierProvider);
return asyncWeather.when(
  data: (weather) => weather == null
      ? const _EmptyState()
      : WeatherContent(weather: weather),
  loading: () => const LoadingShimmer(),
  error: (e, _) => ErrorView(failure: e),
);
```

### Testing providers in isolation
```dart
test('fetchWeather updates state', () async {
  final container = ProviderContainer(
    overrides: [
      getWeatherUseCaseProvider.overrideWithValue(mockUseCase),
    ],
  );
  addTearDown(container.dispose);
  await container.read(weatherNotifierProvider.notifier).fetchWeather('London');
  expect(
    container.read(weatherNotifierProvider).value?.cityName,
    'London',
  );
});
```

---

## Error Handling

### Define failures as a sealed class
```dart
sealed class WeatherFailure implements Exception {
  const WeatherFailure();
}

final class CityNotFoundFailure extends WeatherFailure {
  const CityNotFoundFailure(this.city);
  final String city;
  @override
  String toString() => 'City not found: $city';
}

final class NetworkFailure extends WeatherFailure {
  const NetworkFailure([this.message = 'No internet connection']);
  final String message;
}

final class UnknownFailure extends WeatherFailure {
  const UnknownFailure(this.cause);
  final Object cause;
}
```

### Repository catch pattern
```dart
Future<WeatherEntity> getWeather(String city) async {
  try {
    final model = await _source.fetchWeather(city);
    return model.toEntity();
  } on CityNotFoundFailure {
    rethrow;
  } on SocketException catch (e) {
    throw NetworkFailure(e.message);
  } catch (e) {
    throw UnknownFailure(e);
  }
}
```

---

## Dart Code Standards

### Null safety
```dart
// ✅ Good
String? maybeName;
final name = maybeName ?? 'Unknown';

// ❌ Avoid
final name = maybeName!; // no preceding null check
```

### Immutable models
```dart
@immutable
class WeatherEntity {
  const WeatherEntity({
    required this.cityName,
    required this.temperatureCelsius,
    required this.conditionMain,
  });

  final String cityName;
  final double temperatureCelsius;
  final String conditionMain;

  WeatherEntity copyWith({
    String? cityName,
    double? temperatureCelsius,
    String? conditionMain,
  }) => WeatherEntity(
    cityName: cityName ?? this.cityName,
    temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
    conditionMain: conditionMain ?? this.conditionMain,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeatherEntity &&
          cityName == other.cityName &&
          temperatureCelsius == other.temperatureCelsius &&
          conditionMain == other.conditionMain;

  @override
  int get hashCode => Object.hash(cityName, temperatureCelsius, conditionMain);
}
```

### Switch exhaustiveness (Dart 3+)
```dart
String lottieUrlForCondition(String condition) =>
    switch (condition.toLowerCase()) {
      'clear'                  => LottieAssets.sunny,
      'rain' || 'drizzle'      => LottieAssets.rainy,
      'clouds'                 => LottieAssets.cloudy,
      'snow'                   => LottieAssets.snowy,
      'thunderstorm'           => LottieAssets.thunderstorm,
      _                        => LottieAssets.mist,
    };
```

---

## Widget Patterns

### Cinematic Stack layout
```dart
Stack(
  fit: StackFit.expand,
  children: [
    // Layer 0: Lottie animation (fills screen)
    WeatherAnimation(conditionMain: weather.conditionMain),

    // Layer 1: Blur + dark gradient for readability
    BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
      child: Container(color: Colors.transparent),
    ),
    _buildGradientOverlay(),

    // Layer 2: Foreground content
    SafeArea(child: WeatherContent(weather: weather)),
  ],
)
```

### AnimatedSwitcher for weather transitions
```dart
AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  transitionBuilder: (child, animation) =>
      FadeTransition(opacity: animation, child: child),
  child: WeatherAnimation(
    key: ValueKey(weather.conditionMain), // key drives the switch
    conditionMain: weather.conditionMain,
  ),
)
```

### Shimmer loading
```dart
class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});
  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  // ... build shimmer gradient using AnimatedBuilder
}
```

---

## Testing Conventions

### Unit test structure
```dart
group('WeatherRepositoryImpl', () {
  late MockWeatherRemoteSource mockSource;
  late WeatherRepositoryImpl repo;

  setUp(() {
    mockSource = MockWeatherRemoteSource();
    repo = WeatherRepositoryImpl(source: mockSource);
  });

  test('given HTTP 200, when getWeather called, then returns entity', () async {
    when(() => mockSource.fetchWeather('London'))
        .thenAnswer((_) async => fakeWeatherModel);

    final result = await repo.getWeather('London');
    expect(result.cityName, 'London');
  });

  test('given SocketException, when getWeather called, then throws NetworkFailure', () {
    when(() => mockSource.fetchWeather(any()))
        .thenThrow(const SocketException(''));

    expect(() => repo.getWeather('London'), throwsA(isA<NetworkFailure>()));
  });
});
```

### Widget test with provider override
```dart
Widget buildTestApp(WeatherEntity? weather) {
  return ProviderScope(
    overrides: [
      weatherNotifierProvider.overrideWith(
        () => _FakeWeatherNotifier(weather),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}
```

---

## Common Mistakes to Avoid

| Mistake | Correct approach |
|---|---|
| Calling `ref.read` inside `build()` | Use `ref.watch` in build, `ref.read` in callbacks |
| Putting `AsyncNotifier` inside a widget file | Top-level provider files only |
| Force-unwrapping `!` without null check | Use `??`, `if (x != null)`, or `?.` |
| HTTP calls inside a widget | Only in data sources, called through use case |
| `dynamic` return types | Always type explicitly |
| Single giant `HomeScreen` file | Extract each visual section into its own widget |
| Missing `dispose` on `AnimationController` | Always dispose in `State.dispose()` |
