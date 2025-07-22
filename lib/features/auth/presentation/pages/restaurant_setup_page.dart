import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/core/widgets/loading_overlay.dart';
import 'package:seo_biling/features/auth/presentation/providers/restaurant_setup_controller.dart';

class RestaurantSetupPage extends ConsumerStatefulWidget {
  const RestaurantSetupPage({super.key});

  @override
  ConsumerState<RestaurantSetupPage> createState() =>
      _RestaurantSetupPageState();
}

class _RestaurantSetupPageState extends ConsumerState<RestaurantSetupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _createRestaurant() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(restaurantSetupControllerProvider.notifier)
          .createRestaurant(
            context,
            _nameController.text,
            _locationController.text,
            _emailController.text,
            _phoneController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<RestaurantSetupState>(restaurantSetupControllerProvider,
        (previous, next) {
      if (next.error != null) {
        CendraAlertService.showError(
          context,
          'Creation Failed',
          description: next.error!,
        );
      }
    });

    final state = ref.watch(restaurantSetupControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LoadingOverlay(
        isLoading: state.isLoading,
        message: 'Setting up your restaurant...',
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(48.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(theme),
                        const SizedBox(height: 32),
                        _buildTextFormField(
                          controller: _nameController,
                          theme: theme,
                          labelText: 'Restaurant Name',
                          hintText: 'Enter your restaurant\'s name',
                          icon: Icons.storefront_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _locationController,
                          theme: theme,
                          labelText: 'Location',
                          hintText: 'Enter your restaurant\'s address',
                          icon: Icons.location_on_outlined,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a location';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _emailController,
                          theme: theme,
                          labelText: 'Contact Email',
                          hintText: 'Enter a contact email',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _buildTextFormField(
                          controller: _phoneController,
                          theme: theme,
                          labelText: 'Contact Phone',
                          hintText: 'Enter a contact phone number',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 32),
                        _buildCreateButton(theme, state),
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

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        Icon(
          Icons.business_center_outlined,
          size: 60,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          'Set Up Your Restaurant',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Provide some basic details to get started.',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCreateButton(ThemeData theme, RestaurantSetupState state) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: state.isLoading ? null : _createRestaurant,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: state.isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                'Create Restaurant',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required ThemeData theme,
    required String labelText,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
    );
  }
}