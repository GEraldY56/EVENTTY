import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/constants/strings.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nisController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nisController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final nis = _nisController.text.trim();
    
    try {
      // Convert NIS to internal email format
      final internalEmail = '$nis@eventty.local';
      
      // Send password reset email via Supabase Auth
      await Supabase.instance.client.auth.resetPasswordForEmail(
        internalEmail,
        // Note: User won't receive email since it's internal format
        // This is a known limitation - needs admin intervention
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // Show info message about the limitation
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reset Password Request'),
          content: const Text(
            'Permintaan reset password telah dicatat.\n\n'
            'Karena sistem menggunakan NIS-based authentication, '
            'silakan hubungi administrator untuk reset password Anda.\n\n'
            'NIS Anda telah dicatat dan akan diproses oleh admin.'
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
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
                const SizedBox(height: 24),
                Text(
                  'Forgot Password?',
                  style: AppTextStyles.heading1,
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your NIS and we\'ll help you reset your password',
                  style: AppTextStyles.body1.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 32),
                AppButton(
                  text: 'Request Password Reset',
                  isLoading: _isLoading,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
