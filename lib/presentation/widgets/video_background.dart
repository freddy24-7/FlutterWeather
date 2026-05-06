import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import 'package:cinematic_weather/core/constants.dart';
import 'package:cinematic_weather/core/theme/app_theme.dart';
import 'package:cinematic_weather/core/video_assets.dart';

/// Full-screen looping video background for a given weather condition.
/// Falls back to the Lottie animation if the video asset is missing or fails.
class VideoBackground extends StatefulWidget {
  const VideoBackground({super.key, required this.conditionMain});

  final String conditionMain;

  @override
  State<VideoBackground> createState() => _VideoBackgroundState();
}

class _VideoBackgroundState extends State<VideoBackground> {
  VideoPlayerController? _controller;
  bool _videoReady = false;
  bool _videoFailed = false;

  @override
  void initState() {
    super.initState();
    _initVideo(widget.conditionMain);
  }

  @override
  void didUpdateWidget(VideoBackground old) {
    super.didUpdateWidget(old);
    if (old.conditionMain != widget.conditionMain) {
      _disposeController();
      setState(() {
        _videoReady = false;
        _videoFailed = false;
      });
      _initVideo(widget.conditionMain);
    }
  }

  Future<void> _initVideo(String condition) async {
    final src = VideoAssets.forCondition(condition);
    VideoPlayerController? ctrl;
    try {
      ctrl = src.startsWith('http')
          ? VideoPlayerController.networkUrl(Uri.parse(src))
          : VideoPlayerController.asset(src);
      _controller = ctrl;
      await ctrl.initialize();
      if (!mounted) return;
      ctrl.setLooping(true);
      ctrl.setVolume(0);
      ctrl.play();
      setState(() => _videoReady = true);
    } catch (_) {
      ctrl?.dispose();
      _controller = null;
      if (!mounted) return;
      setState(() => _videoFailed = true);
    }
  }

  void _disposeController() {
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_videoFailed || (!_videoReady && _controller == null)) {
      return _LottieFallback(conditionMain: widget.conditionMain);
    }

    if (!_videoReady) {
      return Container(color: AppColors.backgroundDark);
    }

    final ctrl = _controller!;
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: ctrl.value.size.width,
          height: ctrl.value.size.height,
          child: VideoPlayer(ctrl),
        ),
      ),
    );
  }
}

class _LottieFallback extends StatelessWidget {
  const _LottieFallback({required this.conditionMain});

  final String conditionMain;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Lottie.asset(
        lottieUrlForCondition(conditionMain),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Container(color: AppColors.backgroundDark),
      ),
    );
  }
}
