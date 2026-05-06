import 'package:flutter/material.dart';

import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';

class TemperatureDisplay extends StatelessWidget {
  const TemperatureDisplay({super.key, required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    final tempRounded = weather.temperatureCelsius.round();
    final feelsRounded = weather.feelsLikeCelsius.round();
    final tempSize = AppTextScale.responsive(context, AppTextScale.temp, min: 64, max: 120);
    final citySize = AppTextScale.responsive(context, AppTextScale.city, min: 20, max: 40);

    return Semantics(
      label:
          '${weather.cityName}. ${weather.conditionMain}. '
          '$tempRounded degrees Celsius. '
          'Feels like $feelsRounded degrees. '
          'Humidity ${weather.humidity} percent.',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$tempRounded°',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: tempSize,
                    fontWeight: FontWeight.w300,
                    color: AppColors.textPrimary,
                    height: 1.0,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              weather.conditionMain,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: citySize * 0.6,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatChip(
                  label: 'Feels like',
                  value: '$feelsRounded°',
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: 'Humidity',
                  value: '${weather.humidity}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: AppTextScale.responsive(context, AppTextScale.label - 4, min: 10),
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: AppTextScale.responsive(context, AppTextScale.label, min: 13),
                ),
          ),
        ],
      ),
    );
  }
}
