import 'package:cinematic_weather/core/preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Returns a [CityPreferences] backed by an in-memory SharedPreferences stub.
///
/// Call before any test that uses [preferencesProvider].
Future<CityPreferences> makeFakePreferences({String? savedCity}) async {
  SharedPreferences.setMockInitialValues(
    savedCity != null ? {'default_city': savedCity} : {},
  );
  final prefs = await SharedPreferences.getInstance();
  return CityPreferences(prefs);
}
