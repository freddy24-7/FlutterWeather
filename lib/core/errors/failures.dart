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

  @override
  String toString() => 'Network failure: $message';
}

final class UnknownFailure extends WeatherFailure {
  const UnknownFailure(this.cause);
  final Object cause;

  @override
  String toString() => 'Unknown failure: $cause';
}
