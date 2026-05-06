import 'package:flutter_test/flutter_test.dart';

import 'package:cinematic_weather/core/constants.dart';

void main() {
  group('lottieUrlForCondition', () {
    test('given "Clear", returns sunny URL', () {
      expect(lottieUrlForCondition('Clear'), LottieAssets.sunny);
    });

    test('given "clear" (lowercase), returns sunny URL', () {
      expect(lottieUrlForCondition('clear'), LottieAssets.sunny);
    });

    test('given mixed case "cLEAR", returns sunny URL', () {
      expect(lottieUrlForCondition('cLEAR'), LottieAssets.sunny);
    });

    test('given "Rain", returns rainy URL', () {
      expect(lottieUrlForCondition('Rain'), LottieAssets.rainy);
    });

    test('given "Drizzle", returns rainy URL', () {
      expect(lottieUrlForCondition('Drizzle'), LottieAssets.rainy);
    });

    test('given "Clouds", returns cloudy URL', () {
      expect(lottieUrlForCondition('Clouds'), LottieAssets.cloudy);
    });

    test('given "Snow", returns snowy URL', () {
      expect(lottieUrlForCondition('Snow'), LottieAssets.snowy);
    });

    test('given "Thunderstorm", returns thunderstorm URL', () {
      expect(lottieUrlForCondition('Thunderstorm'), LottieAssets.thunderstorm);
    });

    test('given "Mist", returns mist URL', () {
      expect(lottieUrlForCondition('Mist'), LottieAssets.mist);
    });

    test('given unknown condition "Volcano", returns mist URL as fallback', () {
      expect(lottieUrlForCondition('Volcano'), LottieAssets.mist);
    });

    test('given empty string, returns mist URL as fallback', () {
      expect(lottieUrlForCondition(''), LottieAssets.mist);
    });
  });
}
