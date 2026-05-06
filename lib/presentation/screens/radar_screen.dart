import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/domain/entities/weather_entity.dart';
import 'package:cinematic_weather/presentation/providers/weather_provider.dart';

// OWM map layer types
enum _RadarLayer { precipitation, clouds, wind, temp }

extension _LayerLabel on _RadarLayer {
  String get label => switch (this) {
        _RadarLayer.precipitation => 'Rain',
        _RadarLayer.clouds        => 'Clouds',
        _RadarLayer.wind          => 'Wind',
        _RadarLayer.temp          => 'Temp',
      };

  String get owmLayerId => switch (this) {
        _RadarLayer.precipitation => 'precipitation_new',
        _RadarLayer.clouds        => 'clouds_new',
        _RadarLayer.wind          => 'wind_new',
        _RadarLayer.temp          => 'temp_new',
      };
}

class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  _RadarLayer _activeLayer = _RadarLayer.precipitation;
  final _mapController = MapController();

  LatLng _centreFromWeather(WeatherEntity? weather) {
    if (weather != null && (weather.lat != 0 || weather.lon != 0)) {
      return LatLng(weather.lat, weather.lon);
    }
    return const LatLng(52.1, 5.3); // Netherlands fallback
  }

  String _owmTileUrl(_RadarLayer layer) =>
      'https://tile.openweathermap.org/map/${layer.owmLayerId}'
      '/{z}/{x}/{y}.png?appid=${AppConstants.apiKey}';

  @override
  Widget build(BuildContext context) {
    final asyncWeather = ref.watch(weatherNotifierProvider);
    final weather = asyncWeather.valueOrNull;
    final centre = _centreFromWeather(weather);

    // Fly to new city whenever weather changes
    ref.listen(weatherNotifierProvider, (_, next) {
      final w = next.valueOrNull;
      if (w != null) {
        _mapController.move(LatLng(w.lat, w.lon), 6.5);
      }
    });

    return Semantics(
      label: 'Weather radar map',
      child: Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: centre,
              initialZoom: 6.5,
              minZoom: 3,
              maxZoom: 12,
            ),
            children: [
              // Base dark map tiles (CartoDB Dark Matter — no key needed)
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.example.cinematic_weather',
                retinaMode: MediaQuery.devicePixelRatioOf(context) > 1,
                tileProvider: CancellableNetworkTileProvider(),
              ),
              // OWM weather overlay
              if (AppConstants.apiKey.isNotEmpty)
                Opacity(
                  opacity: 0.65,
                  child: TileLayer(
                    urlTemplate: _owmTileUrl(_activeLayer),
                    userAgentPackageName: 'com.example.cinematic_weather',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),
                ),
              // City marker
              if (weather != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: centre,
                      width: 160,
                      height: 44,
                      child: _CityMarker(weather: weather),
                    ),
                  ],
                ),
            ],
          ),
          // Layer selector
          Positioned(
            top: MediaQuery.paddingOf(context).top + 16,
            left: 0,
            right: 0,
            child: Center(child: _LayerSelector(
              active: _activeLayer,
              onSelect: (l) => setState(() => _activeLayer = l),
            )),
          ),
          // Legend — only shown for temp layer
          if (_activeLayer == _RadarLayer.temp)
            const Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: _TempLegend(),
            ),
          // Mock mode notice
          if (AppConstants.apiKey.isEmpty)
            const Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: _MockNotice(),
            ),
        ],
      ),
      ),
    );
  }
}

class _LayerSelector extends StatelessWidget {
  const _LayerSelector({required this.active, required this.onSelect});

  final _RadarLayer active;
  final ValueChanged<_RadarLayer> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _RadarLayer.values
            .map((l) => _LayerChip(
                  layer: l,
                  selected: l == active,
                  onTap: () => onSelect(l),
                ))
            .toList(),
      ),
    );
  }
}

class _LayerChip extends StatelessWidget {
  const _LayerChip({
    required this.layer,
    required this.selected,
    required this.onTap,
  });

  final _RadarLayer layer;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${layer.label} layer',
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.accentBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            layer.label,
            style: TextStyle(
              color: selected ? Colors.black : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _CityMarker extends StatelessWidget {
  const _CityMarker({required this.weather});

  final WeatherEntity weather;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${weather.cityName}, ${weather.temperatureCelsius.round()} degrees Celsius',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.backgroundDark.withOpacity(0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.accentBlue, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExcludeSemantics(
              child: const Icon(Icons.location_on, color: AppColors.accentBlue, size: 14),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                '${weather.cityName}  ${weather.temperatureCelsius.round()}°',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TempLegend extends StatelessWidget {
  const _TempLegend();

  // OWM temp_new colour scale (approximate, matches their palette)
  static const _stops = [
    (-40.0, Color(0xFF6B00D7), '-40°'),
    (-20.0, Color(0xFF0000FF), '-20°'),
    (0.0,   Color(0xFF00AAFF),   '0°'),
    (10.0,  Color(0xFF00FF00),  '10°'),
    (20.0,  Color(0xFFFFFF00),  '20°'),
    (30.0,  Color(0xFFFF6600),  '30°'),
    (40.0,  Color(0xFFFF0000),  '40°'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.backgroundDark.withOpacity(0.88),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temperature (°C)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          // Gradient bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _stops.map((s) => s.$2).toList(),
                  ),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // Labels row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _stops
                .map((s) => Text(
                      s.$3,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MockNotice extends StatelessWidget {
  const _MockNotice();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.5)),
        ),
        child: const Text(
          'OWM radar layer requires an API key',
          style: TextStyle(color: Colors.orange, fontSize: 12),
        ),
      ),
    );
  }
}
