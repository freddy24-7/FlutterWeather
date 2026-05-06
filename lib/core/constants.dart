class AppConstants {
  AppConstants._();

  static const String openWeatherBaseUrl =
      'https://api.openweathermap.org/data/2.5';

  static const String apiKey = String.fromEnvironment(
    'OWM_API_KEY',
    defaultValue: '',
  );

  static bool get useMock => apiKey.isEmpty;

  static const String defaultCity = 'Amsterdam';
}

class LottieAssets {
  LottieAssets._();

  // Bundled local files from @meteocons/lottie (MIT licensed)
  static const String sunny        = 'assets/lottie/sunny.json';
  static const String rainy        = 'assets/lottie/rainy.json';
  static const String cloudy       = 'assets/lottie/cloudy.json';
  static const String snowy        = 'assets/lottie/snowy.json';
  static const String thunderstorm = 'assets/lottie/thunderstorm.json';
  static const String mist         = 'assets/lottie/mist.json';
}

String lottieUrlForCondition(String conditionMain) =>
    switch (conditionMain.toLowerCase()) {
      'clear' => LottieAssets.sunny,
      'rain' || 'drizzle' => LottieAssets.rainy,
      'clouds' => LottieAssets.cloudy,
      'snow' => LottieAssets.snowy,
      'thunderstorm' => LottieAssets.thunderstorm,
      _ => LottieAssets.mist,
    };
