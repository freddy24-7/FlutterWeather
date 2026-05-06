import 'package:flutter/foundation.dart';

abstract final class VideoAssets {
  static const String _cloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: '',
  );

  static bool get _useCloudinary => _cloudName.isNotEmpty;

  static String _url(String publicId) => _useCloudinary
      ? 'https://res.cloudinary.com/$_cloudName/video/upload/q_auto,vc_auto/$publicId'
      : 'assets/video/$publicId.mp4';

  static String get sunny        => _url('weather/sunny_vpej7j');
  static String get rainy        => _url('weather/rainy_sxhocg');
  static String get cloudy       => _url('weather/cloudy_vhhdzk');
  static String get snowy        => _url('weather/snowy_zbwrna');
  static String get thunderstorm => _url('weather/thunderstorm_fmrlop');
  static String get mist         => _url('weather/mist_gvv0wi');

  static String forCondition(String conditionMain) =>
      switch (conditionMain.toLowerCase()) {
        'clear'             => sunny,
        'rain' || 'drizzle' => rainy,
        'clouds'            => cloudy,
        'snow'              => snowy,
        'thunderstorm'      => thunderstorm,
        _                   => mist,
      };

  // On web all sources (asset or network) are resolved by the browser.
  // On native, network URLs are always reachable; asset files may be absent.
  static bool get canUseVideo => kIsWeb || _useCloudinary;
}
