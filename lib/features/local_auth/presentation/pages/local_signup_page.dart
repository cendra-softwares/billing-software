import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seo_biling/core/widgets/loading_overlay.dart';
import 'package:seo_biling/core/widgets/cendra_alert_service.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_providers.dart';
import 'package:seo_biling/features/local_auth/presentation/providers/local_auth_controller.dart';

class LocalSignupPage extends ConsumerStatefulWidget {
  const LocalSignupPage({super.key});

  @override
  ConsumerState<LocalSignupPage> createState() => _LocalSignupPageState();
}

class _LocalSignupPageState extends ConsumerState<LocalSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(); // New controller for full name
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoginMode = false; // New state to toggle between signup and login

  @override
  void dispose() {
    _fullNameController.dispose(); // Dispose new controller
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _authenticate() async {
    if (_formKey.currentState!.validate()) {
      final controller = ref.read(localAuthControllerProvider.notifier);
      if (_isLoginMode) {
        await controller.login(_emailController.text, _passwordController.text);
      } else {
        await controller.signup(
          _emailController.text,
          _passwordController.text,
          _fullNameController.text, // Pass full name
        );
      }

      // After successful authentication, navigate to the root to allow LocalAuthGate to re-evaluate
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
          _isLoginMode ? 'Login Failed' : 'Signup Failed',
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
      body: LoadingOverlay(
        isLoading: authState.isLoading,
        message: _isLoginMode ? 'Signing you in...' : 'Signing you up...',
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary.withValues(alpha: 0.05),
                colorScheme.secondary.withValues(alpha: 0.05),
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
                          _buildBrandingSection(theme),
                          const SizedBox(height: 48),
                          _buildWelcomeSection(theme),
                          const SizedBox(height: 32),
                          if (!_isLoginMode) ...[ // Only show full name field in signup mode
                            _buildFullNameField(theme),
                            const SizedBox(height: 20),
                          ],
                          _buildEmailField(theme),
                          const SizedBox(height: 20),
                          _buildPasswordField(theme),
                          const SizedBox(height: 16),
                          _buildOptionsRow(theme),
                          const SizedBox(height: 32),
                          _buildAuthButton(theme, authState.isLoading),
                          const SizedBox(height: 24),
                          _buildFooter(theme),
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

  Widget _buildFullNameField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Full Name',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _fullNameController,
          keyboardType: TextInputType.name,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter your full name',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.person_outline,
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
            if (!_isLoginMode && (value == null || value.isEmpty)) {
              return 'Please enter your full name';
            }
            return null;
          },
        ),
      ],
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
          'Local Management System',
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
          _isLoginMode ? 'Welcome back' : 'Create your account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isLoginMode ? 'Sign in to your account to continue' : 'Sign up to get started',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email Address',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter your email address',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.email_outlined,
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
            if (value == null || value.isEmpty) {
              return 'Please enter your email address';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordField(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Numeric Password',
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          keyboardType: TextInputType.number,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: 'Enter your numeric password',
            hintStyle: TextStyle(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
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
            if (value == null || value.isEmpty) {
              return 'Please enter your numeric password';
            }
            if (value.length < 4 || !RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Password must be a 4-digit number';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOptionsRow(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              // Removed "Remember me" checkbox as it's not functional for this basic auth
            ],
          ),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              _isLoginMode = !_isLoginMode; // Toggle between login and signup
              _formKey.currentState?.reset(); // Clear form fields on toggle
              _emailController.clear();
              _passwordController.clear();
            });
          },
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: Text(
            _isLoginMode ? 'Don\'t have an account? Sign Up' : 'Already have an account? Sign In',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton(ThemeData theme, bool isLoading) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : _authenticate,
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
                _isLoginMode ? 'Sign In' : 'Sign Up',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter(ThemeData theme) {
    return Column(
      children: [
        Divider(
          color: theme.colorScheme.outline.withOpacity(0.2),
          thickness: 1,
        ),
        const SizedBox(height: 16),
        Text(
          'Offline-first authentication powered by Isar',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.security,
              size: 16,
              color: theme.colorScheme.primary.withOpacity(0.7),
            ),
            const SizedBox(width: 4),
            Text(
              'Your data is protected locally',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }
}