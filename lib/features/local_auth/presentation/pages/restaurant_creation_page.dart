import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/loading_overlay.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_controller.dart';

class RestaurantCreationPage extends ConsumerStatefulWidget {
  const RestaurantCreationPage({super.key});

  @override
  ConsumerState<RestaurantCreationPage> createState() => _RestaurantCreationPageState();
}

class _RestaurantCreationPageState extends ConsumerState<RestaurantCreationPage> {
  final _formKey = GlobalKey<FormState>();
  final _restaurantNameController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _primaryColorController = TextEditingController();
  final _secondaryColorController = TextEditingController();
  final _accentColorController = TextEditingController();
  final _logoUrlController = TextEditingController();

  @override
  void dispose() {
    _restaurantNameController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _locationController.dispose();
    _primaryColorController.dispose();
    _secondaryColorController.dispose();
    _accentColorController.dispose();
    _logoUrlController.dispose();
    super.dispose();
  }

  Future<void> _createRestaurant() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(localAuthControllerProvider.notifier);
      await controller.createRestaurant(
        _restaurantNameController.text,
        _locationController.text,
        _contactEmailController.text,
        _contactPhoneController.text,
        primaryColor: _primaryColorController.text.isEmpty ? null : _primaryColorController.text,
        secondaryColor: _secondaryColorController.text.isEmpty ? null : _secondaryColorController.text,
        accentColor: _accentColorController.text.isEmpty ? null : _accentColorController.text,
        logoUrl: _logoUrlController.text.isEmpty ? null : _logoUrlController.text,
      );

      // After successful restaurant creation, navigate to the root to allow LocalAuthGate to re-evaluate
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<LocalAuthState>(localAuthControllerProvider, (previous, next) {
      if (next.error != null) {
        CendraAlertService.showError(
          context,
          'Restaurant Creation Failed',
          description: next.error!,
        );
      }
    });

    final authState = ref.watch(localAuthControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Setup Your Restaurant',
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
        message: 'Creating your restaurant...',
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
                          'Restaurant Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(theme, _restaurantNameController, 'Restaurant Name', 'Enter restaurant name', Icons.restaurant),
                        const SizedBox(height: 20),
                        _buildTextField(theme, _locationController, 'Location', 'Enter location', Icons.location_on_outlined),
                        const SizedBox(height: 20),
                        _buildTextField(theme, _contactEmailController, 'Contact Email', 'Enter contact email', Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20),
                        _buildTextField(theme, _contactPhoneController, 'Contact Phone', 'Enter contact phone number', Icons.phone_outlined, keyboardType: TextInputType.phone),
                        const SizedBox(height: 48),
                        Text(
                          'Restaurant Configuration (Optional)',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(theme, _primaryColorController, 'Primary Color (Hex)', '#RRGGBB', Icons.color_lens_outlined),
                        const SizedBox(height: 20),
                        _buildTextField(theme, _secondaryColorController, 'Secondary Color (Hex)', '#RRGGBB', Icons.color_lens_outlined),
                        const SizedBox(height: 20),
                        _buildTextField(theme, _accentColorController, 'Accent Color (Hex)', '#RRGGBB', Icons.color_lens_outlined),
                        const SizedBox(height: 20),
                        _buildTextField(theme, _logoUrlController, 'Logo URL', 'Enter logo image URL', Icons.image_outlined),
                        const SizedBox(height: 48),
                        _buildCreateButton(theme, authState.isLoading),
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

  Widget _buildTextField(ThemeData theme, TextEditingController controller, String label, String hint, IconData icon, {TextInputType keyboardType = TextInputType.text}) {
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
          validator: (value) {
            if (label == 'Restaurant Name' && (value == null || value.isEmpty)) {
              return 'Please enter a restaurant name';
            }
            if (label == 'Contact Email' && value != null && value.isNotEmpty && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCreateButton(ThemeData theme, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _createRestaurant,
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
                'Create Restaurant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }
}