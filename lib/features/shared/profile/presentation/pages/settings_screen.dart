import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Settings', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        children: [
          const SizedBox(height: AppSpacing.paddingLG),

          // Notifications Section
          Text(
            'Notifications',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.paddingMD),

          _buildSettingCard(
            'Enable Notifications',
            'Receive notifications about events and updates',
            Icons.notifications_outlined,
            Switch(
              value: _notificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                  if (!value) {
                    _emailNotifications = false;
                    _pushNotifications = false;
                  }
                });
              },
              activeColor: AppColors.primary,
            ),
          ),

          _buildSettingCard(
            'Email Notifications',
            'Get notified via email',
            Icons.email_outlined,
            Switch(
              value: _emailNotifications && _notificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() => _emailNotifications = value);
                    }
                  : null,
              activeColor: AppColors.primary,
            ),
          ),

          _buildSettingCard(
            'Push Notifications',
            'Receive push notifications',
            Icons.phone_android,
            Switch(
              value: _pushNotifications && _notificationsEnabled,
              onChanged: _notificationsEnabled
                  ? (value) {
                      setState(() => _pushNotifications = value);
                    }
                  : null,
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // Appearance Section
          Text(
            'Appearance',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.paddingMD),

          _buildSettingCard(
            'Dark Mode',
            'Enable dark theme',
            Icons.dark_mode_outlined,
            Switch(
              value: ref.watch(isDarkModeProvider),
              onChanged: (value) {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
              activeColor: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppSpacing.sectionGap),

          // About Section
          Text(
            'About',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: AppSpacing.paddingMD),

          _buildSettingCard(
            'App Version',
            'Version 1.0.0',
            Icons.info_outline,
            null,
          ),

          _buildSettingCard(
            'Terms & Conditions',
            'Read our terms and conditions',
            Icons.description_outlined,
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
            onTap: () {
              _showInfoDialog(
                context,
                'Terms & Conditions',
                'Terms and conditions content will be displayed here.',
              );
            },
          ),

          _buildSettingCard(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip_outlined,
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
            onTap: () {
              _showInfoDialog(
                context,
                'Privacy Policy',
                'Privacy policy content will be displayed here.',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard(
    String title,
    String subtitle,
    IconData icon,
    Widget? trailing, {
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary10,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMD),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: AppTextStyles.titleMedium),
        subtitle: Text(subtitle, style: AppTextStyles.body2),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.heading3),
        content: Text(content, style: AppTextStyles.body1),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
