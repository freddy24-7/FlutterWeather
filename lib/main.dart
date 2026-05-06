import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinematic_weather/core/preferences.dart';
import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/presentation/screens/root_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(CityPreferences(prefs)),
      ],
      child: const CinematicWeatherApp(),
    ),
  );
}

class CinematicWeatherApp extends StatelessWidget {
  const CinematicWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinematic Weather',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const RootScreen(),
    );
  }
}
