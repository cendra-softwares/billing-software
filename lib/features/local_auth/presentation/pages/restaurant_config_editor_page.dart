import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/loading_overlay.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/isar/models/local_schema_model.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart';

class RestaurantConfigEditorPage extends ConsumerStatefulWidget {
  final RestaurantConfig? initialConfig;

  const RestaurantConfigEditorPage({super.key, this.initialConfig});

  @override
  ConsumerState<RestaurantConfigEditorPage> createState() =>
      _RestaurantConfigEditorPageState();
}

class _RestaurantConfigEditorPageState
    extends ConsumerState<RestaurantConfigEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _primaryColorController = TextEditingController();
  final _secondaryColorController = TextEditingController();
  final _accentColorController = TextEditingController();
  final _logoUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialConfig != null) {
      _primaryColorController.text = widget.initialConfig!.primaryColor;
      _secondaryColorController.text = widget.initialConfig!.secondaryColor;
      _accentColorController.text = widget.initialConfig!.accentColor;
      _logoUrlController.text = widget.initialConfig!.logoUrl ?? '';
    }
  }

  @override
  void dispose() {
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _accentColorController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveConfig() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(localAuthControllerProvider.notifier);
      final currentRestaurant = ref.read(currentRestaurantProvider);

      if (currentRestaurant == null) {
        CendraAlertService.showError(
          context,
          'Error',
          description: 'No linked restaurant found to update configuration.',
        );
        return;
      }

      // Create a new config object or update existing one
      final updatedConfig = widget.initialConfig ?? RestaurantConfig();

      // Use the text from the controller if not empty, otherwise keep the existing value
      updatedConfig.primaryColor = _primaryColorController.text.isNotEmpty
          ? _primaryColorController.text
          : updatedConfig.primaryColor;

      updatedConfig.secondaryColor = _secondaryColorController.text.isNotEmpty
          ? _secondaryColorController.text
          : updatedConfig.secondaryColor;

      updatedConfig.accentColor = _accentColorController.text.isNotEmpty
          ? _accentColorController.text
          : updatedConfig.accentColor;

      updatedConfig.logoUrl = _logoUrlController.text.isNotEmpty
          ? _logoUrlController.text
          : updatedConfig.logoUrl;

      print("Saving config: ${updatedConfig.accentColor}"); // Logging

      // Link to the current restaurant if it's a new config
      if (updatedConfig.restaurant.value == null) {
        updatedConfig.restaurant.value = currentRestaurant;
      }

      await controller.updateRestaurantConfig(updatedConfig);

      if (!mounted) return;
      if (controller.debugState.error == null) {
        // Check if the update was successful
        CendraAlertService.showSuccess(
          context,
          'Success',
          description: 'Restaurant configuration saved successfully!',
        );
        Navigator.of(context).pop(); // Go back to dashboard
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(localAuthControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Edit Restaurant Configuration',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        message: 'Saving configuration...',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: screenSize.width > 1200 ? 600 : 500,
              ),
              child: Card(
                elevation: 8,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: const EdgeInsets.all(48.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: colorScheme.surface,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Configuration Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          theme,
                          _primaryColorController,
                          'Primary Color (Hex)',
                          '#RRGGBB',
                          Icons.color_lens_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          theme,
                          _secondaryColorController,
                          'Secondary Color (Hex)',
                          '#RRGGBB',
                          Icons.color_lens_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          theme,
                          _accentColorController,
                          'Accent Color (Hex)',
                          '#RRGGBB',
                          Icons.color_lens_outlined,
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          theme,
                          _logoUrlController,
                          'Logo URL',
                          'Enter logo image URL',
                          Icons.image_outlined,
                        ),
                        const SizedBox(height: 48),
                        _buildSaveButton(theme, authState.isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    ThemeData theme,
    TextEditingController controller,
    String label,
    String hint,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(ThemeData theme, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveConfig,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 2,
          shadowColor: theme.colorScheme.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Save Configuration',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}
