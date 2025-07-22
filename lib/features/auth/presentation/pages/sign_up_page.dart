import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/loading_overlay.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/auth/presentation/providers/sign_up_controller.dart';

enum UserRole { admin, owner, biller, waiter }

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isPasswordVisible = false;
  UserRole _selectedRole = UserRole.waiter;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      CendraAlertService.showInfo(context, 'Creating Account...');
      await ref.read(signUpControllerProvider.notifier).signUp(
            context,
            _emailController.text,
            _passwordController.text,
            _fullNameController.text,
            _phoneController.text,
            _selectedRole,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SignUpState>(signUpControllerProvider, (previous, next) {
      if (next.error != null) {
        CendraAlertService.showError(
          context,
          'Sign Up Failed',
          description: next.error!,
        );
      }
    });

    final signUpState = ref.watch(signUpControllerProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: LoadingOverlay(
        isLoading: signUpState.isLoading,
        message: 'Creating your account...',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withOpacity(0.05),
                colorScheme.secondary.withOpacity(0.05),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: screenSize.width > 1200 ? 480 : 400,
                  minHeight: screenSize.height * 0.6,
                ),
                child: Card(
                  elevation: 8,
                  shadowColor: colorScheme.shadow.withOpacity(0.2),
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
                          _buildBrandingSection(theme),
                          const SizedBox(height: 48),
                          _buildWelcomeSection(theme),
                          const SizedBox(height: 32),
                          _buildFullNameField(theme),
                          const SizedBox(height: 20),
                          _buildEmailField(theme),
                          const SizedBox(height: 20),
                          _buildPhoneField(theme),
                          const SizedBox(height: 20),
                          _buildRoleDropdown(theme),
                          const SizedBox(height: 20),
                          _buildPasswordField(theme),
                          const SizedBox(height: 32),
                          _buildSignUpButton(theme, signUpState),
                          const SizedBox(height: 24),
                          _buildFooter(context, theme),
                        ],
                      ),
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

  Widget _buildBrandingSection(ThemeData theme) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.restaurant_menu,
            size: 40,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Cendra',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Restaurant Management System',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an Account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Start your journey with us today',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildFullNameField(ThemeData theme) {
    return _buildTextFormField(
      controller: _fullNameController,
      theme: theme,
      labelText: 'Full Name',
      hintText: 'Enter your full name',
      icon: Icons.person_outline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your full name';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return _buildTextFormField(
      controller: _emailController,
      theme: theme,
      labelText: 'Email Address',
      hintText: 'Enter your email address',
      icon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email address';
        }
        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _buildPhoneField(ThemeData theme) {
    return _buildTextFormField(
      controller: _phoneController,
      theme: theme,
      labelText: 'Phone Number',
      hintText: 'Enter your phone number',
      icon: Icons.phone_outlined,
      keyboardType: TextInputType.phone,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your phone number';
        }
        return null;
      },
    );
  }

  Widget _buildRoleDropdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Role',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<UserRole>(
          value: _selectedRole,
          items: UserRole.values
              .map((role) => DropdownMenuItem(
                    value: role,
                    child: Text(role.name),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedRole = value;
              });
            }
          },
          decoration: _inputDecoration(theme).copyWith(
            prefixIcon: Icon(
              Icons.work_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          style: theme.textTheme.bodyLarge,
          decoration: _inputDecoration(theme).copyWith(
            hintText: 'Create a password',
            prefixIcon: Icon(
              Icons.lock_outline,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSignUpButton(ThemeData theme, SignUpState signUpState) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: signUpState.isLoading ? null : _signUp,
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
        child: signUpState.isLoading
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
                'Sign Up',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
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
          decoration: _inputDecoration(theme).copyWith(
            hintText: hintText,
            prefixIcon: Icon(
              icon,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(ThemeData theme) {
    return InputDecoration(
      hintStyle: TextStyle(
        color: theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      filled: true,
      fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
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
    );
  }
}

extension ColorSchemeValues on Color {
  Color withValues({double? alpha, double? red, double? green, double? blue}) {
    return Color.fromARGB(
      (alpha != null ? (alpha * 255).round() : this.alpha),
      (red != null ? (red * 255).round() : this.red),
      (green != null ? (green * 255).round() : this.green),
      (blue != null ? (blue * 255).round() : this.blue),
    );
  }
}