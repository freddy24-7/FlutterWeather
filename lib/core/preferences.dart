import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kDefaultCity = 'default_city';

/// Reads and writes the user-pinned default city.
class CityPreferences {
  CityPreferences(this._prefs);

  final SharedPreferences _prefs;

  String? get savedCity => _prefs.getString(_kDefaultCity);

  Future<void> saveCity(String city) => _prefs.setString(_kDefaultCity, city);

  Future<void> clearCity() => _prefs.remove(_kDefaultCity);
}

/// Eagerly-initialised provider — call `await initPreferences(container)`
/// from main() before `runApp`.
final preferencesProvider = Provider<CityPreferences>((ref) {
  throw StateError('preferencesProvider must be overridden before use');
});
