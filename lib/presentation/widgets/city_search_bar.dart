import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/presentation/providers/weather_provider.dart';

class CitySearchBar extends ConsumerStatefulWidget {
  const CitySearchBar({super.key});

  @override
  ConsumerState<CitySearchBar> createState() => _CitySearchBarState();
}

class _CitySearchBarState extends ConsumerState<CitySearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final city = _controller.text.trim();
    if (city.isEmpty) return;
    ref.read(weatherNotifierProvider.notifier).fetchWeather(city);
    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'City search',
      hint: 'Type a city name and press search to load weather',
      textField: true,
      child: TextField(
        controller: _controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _submit(),
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search city…',
          suffixIcon: Semantics(
            label: 'Search',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.search, color: AppColors.accentBlue),
              onPressed: _submit,
              tooltip: 'Search',
            ),
          ),
        ),
      ),
    );
  }
}
