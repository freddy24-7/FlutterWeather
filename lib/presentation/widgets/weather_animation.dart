import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/core/theme/app_theme.dart';

class WeatherAnimation extends StatelessWidget {
  const WeatherAnimation({super.key, required this.conditionMain});

  final String conditionMain;

  @override
  Widget build(BuildContext context) {
    final url = lottieUrlForCondition(conditionMain);

    return SizedBox.expand(
      child: Lottie.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, _) => Container(
          color: AppColors.backgroundDark,
        ),
      ),
    );
  }
}
