import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/models/certificate_model.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../widgets/certificate_preview_widget.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  CertificateLayoutType _selectedLayout = CertificateLayoutType.modern;
  bool _hasLogo = true;
  bool _hasBorder = true;
  bool _hasSignature = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Template', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Template Info Section
              Text('Template Information', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              AppTextField(
                controller: _nameController,
                label: 'Template Name',
                hint: 'e.g., Modern Certificate',
                prefixIcon: Icons.design_services,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'This field is required' : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your template...',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'This field is required' : null,
              ),

              const SizedBox(height: 32),

              // Layout Type Section
              Text('Layout Type', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              _buildLayoutSelector(),

              const SizedBox(height: 32),

              // Template Options
              Text('Template Options', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text('Include Logo', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Show organization logo on certificate',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: _hasLogo,
                      onChanged: (value) {
                        setState(() => _hasLogo = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Include Border', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Add decorative border to certificate',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: _hasBorder,
                      onChanged: (value) {
                        setState(() => _hasBorder = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Include Signature', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Show signature section on certificate',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      value: _hasSignature,
                      onChanged: (value) {
                        setState(() => _hasSignature = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Preview Section
              Text('Preview', style: AppTextStyles.heading3),
              const SizedBox(height: 16),

              CertificatePreviewWidget(
                templateId: 'preview',
                participantName: 'JOHN DOE',
                eventTitle: 'SAMPLE EVENT',
                eventDate: '1 January 2026',
                certificateNumber: 'CERT-2026-XXX',
              ),

              const SizedBox(height: 32),

              // Actions
              AppButton(
                text: 'Create Template',
                isLoading: _isLoading,
                onPressed: _handleCreate,
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Cancel',
                isOutlined: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLayoutSelector() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: CertificateLayoutType.values.map((layout) {
        final isSelected = _selectedLayout == layout;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedLayout = layout);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary10 : AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.design_services,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  layout.displayName,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Template created successfully')),
      );
      context.pop();
    }
  }
}
