import 'package:flutter/material.dart';
import 'cendra_alert.dart';

/// Service for showing Cendra alerts throughout the app
/// Replaces the traditional snackbar system with modern, colorful alerts
class CendraAlertService {
  static OverlayEntry? _currentOverlay;
  static bool _isShowing = false;

  /// Show a success alert
  static void showSuccess(
    BuildContext context,
    String title, {
    String? description,
    List<Widget>? children,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
    bool dismissible = true,
  }) {
    _showAlert(
      context,
      CendraAlert(
        type: CendraAlertType.success,
        title: title,
        description: description,
        icon: icon,
        onDismiss: dismissible ? () => hide() : null,
        showCloseButton: dismissible,
        children: children,
      ),
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Show an error alert
  static void showError(
    BuildContext context,
    String title, {
    String? description,
    List<Widget>? children,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
  }) {
    _showAlert(
      context,
      CendraAlert(
        type: CendraAlertType.error,
        title: title,
        description: description,
        icon: icon,
        onDismiss: dismissible ? () => hide() : null,
        showCloseButton: dismissible,
        children: children,
      ),
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Show a warning alert
  static void showWarning(
    BuildContext context,
    String title, {
    String? description,
    List<Widget>? children,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    bool dismissible = true,
  }) {
    _showAlert(
      context,
      CendraAlert(
        type: CendraAlertType.warning,
        title: title,
        description: description,
        icon: icon,
        onDismiss: dismissible ? () => hide() : null,
        showCloseButton: dismissible,
        children: children,
      ),
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Show an info alert
  static void showInfo(
    BuildContext context,
    String title, {
    String? description,
    List<Widget>? children,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
    bool dismissible = true,
  }) {
    _showAlert(
      context,
      CendraAlert(
        type: CendraAlertType.info,
        title: title,
        description: description,
        icon: icon,
        onDismiss: dismissible ? () => hide() : null,
        showCloseButton: dismissible,
        children: children,
      ),
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Show a neutral alert
  static void showNeutral(
    BuildContext context,
    String title, {
    String? description,
    List<Widget>? children,
    IconData? icon,
    Duration duration = const Duration(seconds: 2),
    bool dismissible = true,
  }) {
    _showAlert(
      context,
      CendraAlert(
        type: CendraAlertType.neutral,
        title: title,
        description: description,
        icon: icon,
        onDismiss: dismissible ? () => hide() : null,
        showCloseButton: dismissible,
        children: children,
      ),
      duration: duration,
      dismissible: dismissible,
    );
  }

  /// Show a custom alert
  static void showCustom(
    BuildContext context,
    CendraAlert alert, {
    Duration duration = const Duration(seconds: 2),
    bool dismissible = true,
  }) {
    _showAlert(context, alert, duration: duration, dismissible: dismissible);
  }

  /// Hide the current alert
  static void hide() {
    if (_currentOverlay != null && _isShowing) {
      _currentOverlay!.remove();
      _currentOverlay = null;
      _isShowing = false;
    }
  }

  /// Internal method to show alerts with animation
  static void _showAlert(
    BuildContext context,
    CendraAlert alert, {
    required Duration duration,
    required bool dismissible,
  }) {
    // Hide any existing alert first
    hide();

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _AlertOverlay(
        alert: alert,
        onDismiss: () {
          hide();
        },
        dismissible: dismissible,
      ),
    );

    _currentOverlay = overlayEntry;
    _isShowing = true;
    overlay.insert(overlayEntry);

    // Auto-hide after duration
    Future.delayed(duration, () {
      if (_currentOverlay == overlayEntry && _isShowing) {
        hide();
      }
    });
  }
}

/// Overlay widget that handles the alert positioning and animation
class _AlertOverlay extends StatefulWidget {
  const _AlertOverlay({
    required this.alert,
    required this.onDismiss,
    required this.dismissible,
  });

  final CendraAlert alert;
  final VoidCallback onDismiss;
  final bool dismissible;

  @override
  State<_AlertOverlay> createState() => _AlertOverlayState();
}

class _AlertOverlayState extends State<_AlertOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero).animate(
          CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      width: 320, // Fixed width for compact size
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: GestureDetector(
                onTap: widget.dismissible ? _dismiss : null,
                child: CendraAlert(
                  type: widget.alert.type,
                  title: widget.alert.title,
                  description: widget.alert.description,
                  icon: widget.alert.icon,
                  onDismiss: widget.dismissible ? _dismiss : null,
                  showCloseButton: widget.alert.showCloseButton,
                  margin: EdgeInsets.zero,
                  children: widget.alert.children,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
