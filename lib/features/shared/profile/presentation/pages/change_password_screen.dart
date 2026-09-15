import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/supabase_auth_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = SupabaseAuthService();

  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // ----------------------------------------------------------------
  // Lifecycle
  // ----------------------------------------------------------------

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Submit
  // ----------------------------------------------------------------

  Future<void> _handleChangePassword() async {
    if (_isSubmitting) return; // prevent double submit
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Call Supabase Auth updateUser with new password.
    // IMPORTANT LIMITATION: Supabase Auth does NOT verify the current password.
    // The current password field is for user confirmation/UX only.
    // updateUser() will succeed if the user has an active authenticated session.
    final success = await _authService.updatePassword(
      _newPasswordController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Password berhasil diubah'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(); // pop only on real success
    } else {
      _showSnackBar(
        'Gagal mengubah password. Periksa koneksi dan coba lagi.',
        isError: true,
      );
      // do NOT pop — stay on screen so user can retry
    }
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
      ),
    );
  }

  // ----------------------------------------------------------------
  // Build
  // ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Change Password', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.paddingLG),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.paddingLG),
                decoration: BoxDecoration(
                  color: AppColors.info10,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Password must be at least 6 characters long',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Current Password
              // Note: This field is for user confirmation only.
              // Supabase Auth updateUser() does NOT verify current password.
              AppTextField(
                controller: _currentPasswordController,
                label: 'Current Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureCurrentPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter current password';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.paddingLG),

              // New Password
              AppTextField(
                controller: _newPasswordController,
                label: 'New Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureNewPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter new password';
                  }
                  if (value.trim().length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (value.trim() == _currentPasswordController.text.trim()) {
                    return 'New password must be different from current';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.paddingLG),

              // Confirm Password
              AppTextField(
                controller: _confirmPasswordController,
                label: 'Confirm New Password',
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please confirm new password';
                  }
                  if (value.trim() != _newPasswordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppSpacing.sectionGap),

              // Change Password Button — disabled while submitting
              AppButton(
                onPressed: _isSubmitting ? null : _handleChangePassword,
                text: _isSubmitting ? 'Mengubah password...' : 'Change Password',
                isLoading: _isSubmitting,
              ),

              const SizedBox(height: AppSpacing.paddingMD),

              // Cancel Button
              AppButton(
                onPressed: _isSubmitting ? null : () => context.pop(),
                text: 'Cancel',
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
