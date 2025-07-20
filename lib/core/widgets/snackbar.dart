import 'package:flutter/material.dart';
import 'cendra_alert_service.dart';

/// @deprecated Use CendraAlertService instead for better UX
/// This function is kept for backward compatibility but will be removed in future versions
@Deprecated(
  'Use CendraAlertService.showSuccess() or CendraAlertService.showError() instead',
)
void showSnackbar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  // Migrate to new alert system
  if (isError) {
    CendraAlertService.showError(context, 'Error', description: message);
  } else {
    CendraAlertService.showSuccess(context, 'Success', description: message);
  }
}
