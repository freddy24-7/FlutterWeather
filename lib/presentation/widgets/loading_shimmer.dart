import 'package:flutter/material.dart';

import 'package:cinematic_weather/core/theme/app_theme.dart';

class LoadingShimmer extends StatefulWidget {
  const LoadingShimmer({super.key});

  @override
  State<LoadingShimmer> createState() => _LoadingShimmerState();
}

class _LoadingShimmerState extends State<LoadingShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final hPad = (width * 0.06).clamp(16.0, 32.0);

    return Semantics(
      label: 'Loading weather information',
      excludeSemantics: true,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final gradient = LinearGradient(
            begin: Alignment(_animation.value - 1, 0),
            end: Alignment(_animation.value + 1, 0),
            colors: const [
              AppColors.shimmerBase,
              AppColors.shimmerHighlight,
              AppColors.shimmerBase,
            ],
          );

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: hPad * 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBlock(gradient: gradient, width: width * 0.4, height: 32),
                const SizedBox(height: 16),
                _ShimmerBlock(gradient: gradient, width: width * 0.3, height: 88),
                const SizedBox(height: 24),
                _ShimmerBlock(gradient: gradient, width: width * 0.5, height: 18),
                const SizedBox(height: 12),
                _ShimmerBlock(gradient: gradient, width: width * 0.38, height: 18),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({
    required this.gradient,
    required this.width,
    required this.height,
  });

  final Gradient gradient;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
