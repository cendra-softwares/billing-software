import 'dart:math' as math;
import 'package:flutter/material.dart';

class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  final bool isLoading;
  final Widget child;
  final String? message;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Fade animation for overlay appearance
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Rotation animation for the main logo
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );

    // Scale animation for breathing effect
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Pulse animation for outer ring
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(LoadingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading && !oldWidget.isLoading) {
      _startAnimations();
    } else if (!widget.isLoading && oldWidget.isLoading) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    _fadeController.forward();
    _rotationController.repeat();
    _scaleController.repeat(reverse: true);
    _pulseController.repeat();
  }

  void _stopAnimations() {
    _fadeController.reverse();
    _rotationController.stop();
    _scaleController.stop();
    _pulseController.stop();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isLoading)
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value * 0.85,
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const ModalBarrier(
                    dismissible: false,
                    color: Colors.transparent,
                  ),
                ),
              );
            },
          ),
        if (widget.isLoading)
          AnimatedBuilder(
            animation: Listenable.merge([
              _fadeAnimation,
              _rotationAnimation,
              _scaleAnimation,
              _pulseAnimation,
            ]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCendraLoader(context),
                      const SizedBox(height: 24),
                      _buildLoadingText(context),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildCendraLoader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer pulsing ring
          Transform.scale(
            scale: 1.0 + (_pulseAnimation.value * 0.3),
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: colorScheme.primary.withValues(
                    alpha: 0.3 * (1.0 - _pulseAnimation.value),
                  ),
                  width: 2,
                ),
              ),
            ),
          ),

          // Middle rotating ring
          Transform.rotate(
            angle: _rotationAnimation.value * 2 * math.pi,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.secondary, width: 3),
                gradient: SweepGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.secondary,
                    colorScheme.primary.withValues(alpha: 0.3),
                    colorScheme.secondary,
                  ],
                  stops: const [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Inner breathing logo
          Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: colorScheme.onPrimary,
                size: 24,
              ),
            ),
          ),

          // Floating particles effect
          ...List.generate(6, (index) {
            final angle = (index * 60.0) * (math.pi / 180);
            final radius = 45.0;
            final x =
                radius *
                math.cos(angle + _rotationAnimation.value * 2 * math.pi);
            final y =
                radius *
                math.sin(angle + _rotationAnimation.value * 2 * math.pi);

            return Transform.translate(
              offset: Offset(x, y),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primary.withValues(
                    alpha: 0.6 + (0.4 * _pulseAnimation.value),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLoadingText(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        Text(
          'Cendra',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.message ?? 'Loading...',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        // Animated dots
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            return AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final delay = index * 0.3;
                final animationValue = (_pulseAnimation.value + delay) % 1.0;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withValues(
                      alpha: 0.3 + (0.7 * animationValue),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
