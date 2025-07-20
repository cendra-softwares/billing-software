import 'package:flutter/material.dart';

/// Alert types for different use cases
enum CendraAlertType { success, error, warning, info, neutral }

/// Cendra Alert Widget - A colorful, modern alert component inspired by shadcn/ui
/// Replaces traditional snackbars with a more sophisticated design
class CendraAlert extends StatelessWidget {
  const CendraAlert({
    super.key,
    required this.type,
    required this.title,
    this.description,
    this.children,
    this.icon,
    this.onDismiss,
    this.showCloseButton = true,
    this.margin,
    this.padding,
  });

  final CendraAlertType type;
  final String title;
  final String? description;
  final List<Widget>? children;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final bool showCloseButton;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final alertConfig = _getAlertConfig(theme);

    return Container(
      margin: margin ?? EdgeInsets.zero,
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: alertConfig.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: alertConfig.borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: alertConfig.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: alertConfig.iconBackgroundColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon ?? alertConfig.defaultIcon,
              color: alertConfig.iconColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 10),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: alertConfig.titleColor,
                  ),
                ),

                // Description
                if (description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: alertConfig.descriptionColor,
                      height: 1.3,
                    ),
                  ),
                ],

                // Custom children
                if (children != null) ...[
                  const SizedBox(height: 6),
                  ...children!,
                ],
              ],
            ),
          ),

          // Close button
          if (showCloseButton && onDismiss != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: alertConfig.closeButtonColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: alertConfig.closeIconColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  _AlertConfig _getAlertConfig(ThemeData theme) {
    final colorScheme = theme.colorScheme;

    switch (type) {
      case CendraAlertType.success:
        return _AlertConfig(
          backgroundColor: const Color(0xFFF0FDF4),
          borderColor: const Color(0xFF22C55E),
          shadowColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
          iconBackgroundColor: const Color(0xFF22C55E),
          iconColor: Colors.white,
          titleColor: const Color(0xFF15803D),
          descriptionColor: const Color(0xFF166534),
          closeButtonColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
          closeIconColor: const Color(0xFF15803D),
          defaultIcon: Icons.check_circle_outline,
        );

      case CendraAlertType.error:
        return _AlertConfig(
          backgroundColor: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFEF4444),
          shadowColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
          iconBackgroundColor: const Color(0xFFEF4444),
          iconColor: Colors.white,
          titleColor: const Color(0xFFDC2626),
          descriptionColor: const Color(0xFFB91C1C),
          closeButtonColor: const Color(0xFFEF4444).withValues(alpha: 0.1),
          closeIconColor: const Color(0xFFDC2626),
          defaultIcon: Icons.error_outline,
        );

      case CendraAlertType.warning:
        return _AlertConfig(
          backgroundColor: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFF59E0B),
          shadowColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
          iconBackgroundColor: const Color(0xFFF59E0B),
          iconColor: Colors.white,
          titleColor: const Color(0xFFD97706),
          descriptionColor: const Color(0xFFB45309),
          closeButtonColor: const Color(0xFFF59E0B).withValues(alpha: 0.1),
          closeIconColor: const Color(0xFFD97706),
          defaultIcon: Icons.warning_amber_outlined,
        );

      case CendraAlertType.info:
        return _AlertConfig(
          backgroundColor: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFF3B82F6),
          shadowColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          iconBackgroundColor: const Color(0xFF3B82F6),
          iconColor: Colors.white,
          titleColor: const Color(0xFF2563EB),
          descriptionColor: const Color(0xFF1D4ED8),
          closeButtonColor: const Color(0xFF3B82F6).withValues(alpha: 0.1),
          closeIconColor: const Color(0xFF2563EB),
          defaultIcon: Icons.info_outline,
        );

      case CendraAlertType.neutral:
        return _AlertConfig(
          backgroundColor: colorScheme.surfaceContainerHighest,
          borderColor: colorScheme.outline,
          shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
          iconBackgroundColor: colorScheme.primary,
          iconColor: colorScheme.onPrimary,
          titleColor: colorScheme.onSurface,
          descriptionColor: colorScheme.onSurface.withValues(alpha: 0.8),
          closeButtonColor: colorScheme.outline.withValues(alpha: 0.1),
          closeIconColor: colorScheme.onSurface.withValues(alpha: 0.7),
          defaultIcon: Icons.notifications_outlined,
        );
    }
  }
}

/// Configuration class for alert styling
class _AlertConfig {
  final Color backgroundColor;
  final Color borderColor;
  final Color shadowColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final Color titleColor;
  final Color descriptionColor;
  final Color closeButtonColor;
  final Color closeIconColor;
  final IconData defaultIcon;

  _AlertConfig({
    required this.backgroundColor,
    required this.borderColor,
    required this.shadowColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.titleColor,
    required this.descriptionColor,
    required this.closeButtonColor,
    required this.closeIconColor,
    required this.defaultIcon,
  });
}
