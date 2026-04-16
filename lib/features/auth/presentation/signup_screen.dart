import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:landlord_os/core/constants/app_colors.dart';
import 'package:landlord_os/core/utils/validators.dart';
import 'package:landlord_os/features/auth/presentation/auth_controller.dart';
import 'package:landlord_os/shared/widgets/app_button.dart';
import 'package:landlord_os/core/extensions/l10n_ext.dart';
import 'package:landlord_os/shared/widgets/app_text_field.dart';

/// Account creation screen.
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          fullName: _nameCtrl.text.trim().isNotEmpty
              ? _nameCtrl.text.trim()
              : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
      if (next.hasValue && next.value != null) {
        context.go('/dashboard');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_work_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    context.l10n.createAccount,
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.createYourAccount,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 40),
                  AppTextField(
                    label: context.l10n.fullName,
                    controller: _nameCtrl,
                    prefixIcon: Icons.person_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: context.l10n.email,
                    controller: _emailCtrl,
                    validator: Validators.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: context.l10n.password,
                    controller: _passwordCtrl,
                    validator: (v) {
                      final base = Validators.required(v);
                      if (base != null) return base;
                      if (v != null && v.length < 6) {
                        return context.l10n.passwordTooShort;
                      }
                      return null;
                    },
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                  ),
                  const SizedBox(height: 24),
                  AppButton(
                    label: context.l10n.createAccount,
                    onPressed: _submit,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text('${context.l10n.alreadyHaveAccount} ${context.l10n.signIn}'),
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
