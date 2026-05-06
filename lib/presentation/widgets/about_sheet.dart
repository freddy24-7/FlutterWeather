import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:cinematic_weather/core/theme/app_theme.dart';

const _repoUrl = 'https://github.com/freddy24-7/FlutterWeather';

void showAboutSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AboutSheet(),
  );
}

class _AboutSheet extends StatelessWidget {
  const _AboutSheet();

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF12122A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomPad),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Cinematic Weather',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'A production-quality Flutter weather app with cinematic video '
            'backgrounds, a live radar map, and clean architecture. '
            'Search any city to see live conditions, pin a default city '
            'that persists across sessions, and explore precipitation, '
            'cloud, wind, and temperature layers on an interactive map.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Tech stack'),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Chip('Flutter 3'),
              _Chip('Dart 3'),
              _Chip('Riverpod 2'),
              _Chip('Clean Architecture'),
              _Chip('OpenWeatherMap API'),
              _Chip('flutter_map'),
              _Chip('Cloudinary CDN'),
              _Chip('Lottie animations'),
              _Chip('shared_preferences'),
              _Chip('video_player'),
            ],
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Source code'),
          const SizedBox(height: 10),
          Semantics(
            label: 'Open GitHub repository',
            button: true,
            child: GestureDetector(
              onTap: () => _launchUrl(_repoUrl),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.code, color: AppColors.accentBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    _repoUrl,
                    style: TextStyle(
                      color: AppColors.accentBlue,
                      fontSize: 13,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.accentBlue,
                    ),
                  ),  // Text is not const because _repoUrl is a top-level const but TextStyle.decoration prevents it
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

Future<void> _launchUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
