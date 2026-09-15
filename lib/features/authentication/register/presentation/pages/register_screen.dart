import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../../core/services/nis_auth_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nisController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nisAuthService = NISAuthService();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _nisController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fullName = _fullNameController.text.trim();
    final nis = _nisController.text.trim();
    final password = _passwordController.text;

    try {
      // Register using NISAuthService
      await _nisAuthService.registerWithNIS(
        fullName: fullName,
        nis: nis,
        password: password,
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate back to login
      context.pop();
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Register to get started',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _fullNameController,
                  label: AppStrings.fullName,
                  hint: 'Enter your full name',
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return AppStrings.fieldRequired;
                    if (value!.trim().length < 3) {
                      return 'Nama lengkap minimal 3 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.paddingLG),
                AppTextField(
                  controller: _nisController,
                  label: 'NIS',
                  hint: 'Enter your 5-digit NIS',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return AppStrings.fieldRequired;
                    if (!RegExp(r'^\d{5}$').hasMatch(value!)) {
                      return 'NIS must be exactly 5 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.paddingLG),
                AppTextField(
                  controller: _passwordController,
                  label: AppStrings.password,
                  hint: 'Enter your password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return AppStrings.fieldRequired;
                    if (value!.length < 6) return AppStrings.passwordTooShort;
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.paddingLG),
                AppTextField(
                  controller: _confirmPasswordController,
                  label: AppStrings.confirmPassword,
                  hint: 'Confirm your password',
                  prefixIcon: Icons.lock_outlined,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(
                        () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                  validator: (value) {
                    if (value?.isEmpty ?? true) return AppStrings.fieldRequired;
                    if (value != _passwordController.text) {
                      return AppStrings.passwordNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                AppButton(
                  text: AppStrings.register,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.alreadyHaveAccount,
                      style: AppTextStyles.body2,
                    ),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        AppStrings.login,
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
