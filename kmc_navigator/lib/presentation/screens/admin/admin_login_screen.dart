import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/primary_button.dart';
import '../../providers/repository_providers.dart';

/// Admin login form.
///
/// V1 has no end-user accounts — this is the only login surface in the
/// app, reserved for hospital staff who manage locations/announcements.
/// Signs in via [AuthRepository.signInAdmin], which also confirms the
/// account is a registered admin (not just any Firebase user) before
/// letting the person through.
class AdminLoginScreen extends ConsumerStatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  ConsumerState<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends ConsumerState<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authRepositoryProvider).signInAdmin(
            email: _emailController.text,
            password: _passwordController.text,
          );
      if (mounted) context.goNamed(RouteNames.adminDashboard);
    } catch (error) {
      final failure = AppFailure.from(error);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.adminLoginTitle)),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.admin_panel_settings_rounded,
                    size: AppSizes.iconSizeLg * 1.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  TextFormField(
                    controller: _emailController,
                    enabled: !_isSubmitting,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: AppStrings.emailLabel,
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter an email' : null,
                  ),
                  const SizedBox(height: AppSizes.md),
                  TextFormField(
                    controller: _passwordController,
                    enabled: !_isSubmitting,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: AppStrings.passwordLabel,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Enter a password' : null,
                  ),
                  const SizedBox(height: AppSizes.lg),
                  PrimaryButton(
                    label: AppStrings.loginButton,
                    isLoading: _isSubmitting,
                    onPressed: _onLoginPressed,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
