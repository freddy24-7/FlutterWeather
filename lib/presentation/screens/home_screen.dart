import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinematic_weather/core/errors/failures.dart';
import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/presentation/providers/weather_provider.dart';
import 'package:cinematic_weather/presentation/widgets/city_search_bar.dart';
import 'package:cinematic_weather/presentation/widgets/loading_shimmer.dart';
import 'package:cinematic_weather/presentation/widgets/temperature_display.dart';
import 'package:cinematic_weather/presentation/widgets/video_background.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncWeather = ref.watch(weatherNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: asyncWeather.when(
        loading: () => const _LoadingView(),
        data: (weather) => weather == null
            ? const _LoadingView()
            : _WeatherView(weather: weather),
        error: (error, _) => _ErrorView(
          failure: error,
          onRetry: () =>
              ref.read(weatherNotifierProvider.notifier).retry(),
        ),
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading weather data',
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.backgroundDark),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: _vPad(context)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: _hPad(context)),
                  child: const CitySearchBar(),
                ),
                const Expanded(child: LoadingShimmer()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherView extends ConsumerWidget {
  const _WeatherView({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinnedCity = ref.watch(defaultCityProvider);
    final isPinned = pinnedCity == weather.cityName;
    final notifier = ref.read(weatherNotifierProvider.notifier);

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 600),
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: VideoBackground(
            key: ValueKey(weather.conditionMain),
            conditionMain: weather.conditionMain,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
          child: Container(color: Colors.transparent),
        ),
        _buildGradientOverlay(),
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: _vPad(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad(context)),
                child: const CitySearchBar(),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: _hPad(context),
                  vertical: _vPad(context) * 3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _WeatherContent(weather: weather),
                    const SizedBox(height: 20),
                    _PinButton(
                      cityName: weather.cityName,
                      isPinned: isPinned,
                      onPin: () => notifier.setDefaultCity(weather.cityName),
                      onUnpin: () => notifier.clearDefaultCity(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.4, 1.0],
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.75),
            ],
          ),
        ),
      ),
    );
  }
}

class _PinButton extends StatelessWidget {
  const _PinButton({
    required this.cityName,
    required this.isPinned,
    required this.onPin,
    required this.onUnpin,
  });

  final String cityName;
  final bool isPinned;
  final VoidCallback onPin;
  final VoidCallback onUnpin;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isPinned
          ? '$cityName is your default city. Tap to unpin.'
          : 'Set $cityName as default city',
      child: GestureDetector(
        onTap: isPinned ? onUnpin : onPin,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isPinned
                ? AppColors.accentBlue.withValues(alpha: 0.18)
                : AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isPinned
                  ? AppColors.accentBlue
                  : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                size: 15,
                color: isPinned ? AppColors.accentBlue : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                isPinned ? 'Default city' : 'Set as default',
                style: TextStyle(
                  fontSize: AppTextScale.responsive(context, 13, min: 11),
                  color: isPinned ? AppColors.accentBlue : AppColors.textSecondary,
                  fontWeight: isPinned ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    final citySize = AppTextScale.responsive(context, AppTextScale.city, min: 20, max: 40);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          weather.cityName,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: citySize,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        TemperatureDisplay(weather: weather),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.failure, required this.onRetry});

  final Object failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final (message, semanticHint) = switch (failure) {
      CityNotFoundFailure f => (
          'City "${f.city}" not found — try another name',
          'City ${f.city} was not found. Tap Retry to search again.',
        ),
      NetworkFailure() => (
          'No internet connection',
          'No internet connection. Check your network and tap Retry.',
        ),
      _ => (
          'Something went wrong',
          'An error occurred. Tap Retry to try again.',
        ),
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        Container(color: AppColors.backgroundDark),
        SafeArea(
          child: Column(
            children: [
              SizedBox(height: _vPad(context)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: _hPad(context)),
                child: const CitySearchBar(),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.all(_hPad(context) * 1.3),
                child: Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ExcludeSemantics(
                        child: Icon(
                          Icons.cloud_off_rounded,
                          size: AppTextScale.responsive(context, 64, min: 48, max: 80),
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: AppTextScale.responsive(
                                  context, AppTextScale.label,
                                  min: 13),
                            ),
                      ),
                      const SizedBox(height: 32),
                      Semantics(
                        hint: semanticHint,
                        child: ElevatedButton(
                          onPressed: onRetry,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentBlue,
                            foregroundColor: Colors.black,
                            minimumSize: const Size(120, 48),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }
}

double _hPad(BuildContext context) =>
    (MediaQuery.sizeOf(context).width * 0.06).clamp(16.0, 32.0);

double _vPad(BuildContext context) =>
    (MediaQuery.sizeOf(context).height * 0.02).clamp(8.0, 24.0);
