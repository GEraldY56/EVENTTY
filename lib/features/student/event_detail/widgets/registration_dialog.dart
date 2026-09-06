import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/text_styles.dart';
import '../../../../core/models/event_model.dart';
import '../../../../core/models/registration_model.dart';
import '../../../../core/utils/logger.dart';

class EventRegistrationDialog extends StatefulWidget {
  final EventModel event;
  final String userName;
  final String userNis;
  final String userId;
  final String userKelas;
  final Function(Map<String, dynamic>) onSubmit;

  const EventRegistrationDialog({
    super.key,
    required this.event,
    required this.userName,
    required this.userNis,
    required this.userId,
    required this.userKelas,
    required this.onSubmit,
  });

  @override
  State<EventRegistrationDialog> createState() => _EventRegistrationDialogState();
}

class _EventRegistrationDialogState extends State<EventRegistrationDialog> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Individual registration fields
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _kelasController = TextEditingController();
  final _reasonController = TextEditingController();
  
  // Team registration fields
  final _teamNameController = TextEditingController();
  final _classNameController = TextEditingController();
  final List<TeamMemberInput> _teamMembers = [];
  
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _kelasFocus = FocusNode();
  final _reasonFocus = FocusNode();
  
  bool _agreedToTerms = false;
  bool _isSubmitting = false;
  
  // Validation states for checkmark animation
  bool _kelasValid = false;
  bool _phoneValid = false;
  bool _emailValid = false;
  bool _teamNameValid = false;

  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    // Pre-fill class for team registration
    _classNameController.text = widget.userKelas;
    
    // Add leader as first member for team registration
    if (widget.event.registrationType == RegistrationType.team) {
      _teamMembers.add(TeamMemberInput(
        studentId: widget.userId,
        name: widget.userName,
        nis: widget.userNis,
        kelas: widget.userKelas,
        isLeader: true,
      ));
    }
    
    // Add listeners for real-time validation
    if (widget.event.registrationType == RegistrationType.individual) {
      _kelasController.text = widget.userKelas;
      _kelasController.addListener(_validateKelas);
      _phoneController.addListener(_validatePhone);
      _emailController.addListener(_validateEmail);
      _kelasValid = widget.userKelas.isNotEmpty;
    } else {
      _teamNameController.addListener(_validateTeamName);
    }
  }

  void _validateKelas() {
    setState(() {
      _kelasValid = _kelasController.text.trim().isNotEmpty;
    });
  }

  void _validatePhone() {
    setState(() {
      _phoneValid = _phoneController.text.trim().length >= 10;
    });
  }

  void _validateEmail() {
    setState(() {
      _emailValid = _emailController.text.trim().contains('@');
    });
  }

  void _validateTeamName() {
    setState(() {
      _teamNameValid = _teamNameController.text.trim().isNotEmpty;
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _kelasController.dispose();
    _reasonController.dispose();
    _teamNameController.dispose();
    _classNameController.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _kelasFocus.dispose();
    _reasonFocus.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  void _addTeamMember() {
    showDialog(
      context: context,
      builder: (context) => _TeamMemberDialog(
        onAdd: (member) {
          setState(() {
            _teamMembers.add(member);
          });
        },
        existingMembers: _teamMembers,
        className: _classNameController.text.trim(),
      ),
    );
  }

  void _removeTeamMember(int index) {
    if (_teamMembers[index].isLeader) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Ketua tidak dapat dihapus'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    
    setState(() {
      _teamMembers.removeAt(index);
    });
  }

  void _handleSubmit() async {
    // Debug logging
    AppLogger.debug('Registration form submission', {
      'formValid': _formKey.currentState!.validate(),
      'termsAgreed': _agreedToTerms,
      'eventType': widget.event.registrationType.toString(),
    });
    
    if (!_formKey.currentState!.validate()) {
      // Shake animation for error
      _shakeController.forward().then((_) => _shakeController.reverse());
      AppLogger.debug('Form validation failed');
      return;
    }
    
    // Team-specific validation
    if (widget.event.registrationType == RegistrationType.team) {
      AppLogger.debug('Team member count: ${_teamMembers.length}');
      if (_teamMembers.length < 2) {
        _shakeController.forward().then((_) => _shakeController.reverse());
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Team minimal harus memiliki 2 anggota'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        AppLogger.debug('Team validation failed: Less than 2 members');
        return;
      }
    }
    
    if (!_agreedToTerms) {
      _shakeController.forward().then((_) => _shakeController.reverse());
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Mohon setujui syarat dan ketentuan'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      AppLogger.debug('Terms not agreed');
      return;
    }

    setState(() => _isSubmitting = true);
    AppLogger.debug('Submitting registration...');

    Map<String, dynamic> formData;
    
    if (widget.event.registrationType == RegistrationType.individual) {
      formData = {
        'type': 'individual',
        'fullName': widget.userName,
        'nis': widget.userNis,
        'kelas': _kelasController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'reason': _reasonController.text.trim(),
      };
      AppLogger.debug('Individual form data', formData);
    } else {
      formData = {
        'type': 'team',
        'teamName': _teamNameController.text.trim(),
        'className': _classNameController.text.trim(),
        'members': _teamMembers.map((m) => {
          'studentId': m.studentId,
          'name': m.name,
          'nis': m.nis,
          'kelas': m.kelas,
        }).toList(),
        'memberCount': _teamMembers.length,
      };
      AppLogger.debug('Team form data', formData);
    }

    // Delay to show loading state
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    AppLogger.debug('Calling onSubmit callback');
    widget.onSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    final isTeam = widget.event.registrationType == RegistrationType.team;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      child: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final offset = _shakeController.value * 10;
          return Transform.translate(
            offset: Offset(_shakeController.isAnimating ? (offset - 5) : 0, 0),
            child: child,
          );
        },
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modern Header with gradient
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isTeam ? Icons.groups_rounded : Icons.person_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isTeam ? 'Daftar Team' : 'Daftar Event',
                          style: AppTextStyles.heading3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.event.title,
                          style: AppTextStyles.body2.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isTeam ? 'Pendaftaran Team' : 'Pendaftaran Individual',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Render form based on registration type
                  if (isTeam) ..._buildTeamForm() else ..._buildIndividualForm(),

                  const SizedBox(height: 20),

                  // Modern Terms & Conditions
                  InkWell(
                    onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _agreedToTerms 
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _agreedToTerms ? AppColors.primary : AppColors.border,
                          width: _agreedToTerms ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _agreedToTerms ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _agreedToTerms ? AppColors.primary : AppColors.border,
                                width: 2,
                              ),
                            ),
                            child: _agreedToTerms
                                ? const Icon(Icons.check, size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Saya setuju dengan syarat dan ketentuan yang berlaku',
                              style: AppTextStyles.body2.copyWith(
                                color: _agreedToTerms ? AppColors.primary : AppColors.textPrimary,
                                fontWeight: _agreedToTerms ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Modern Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: AppColors.border, width: 1.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: AppTextStyles.button.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primary,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.check_circle_outline, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Daftar Sekarang',
                                        style: AppTextStyles.button.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
      ),
    );
  }

  // Build Individual Registration Form
  List<Widget> _buildIndividualForm() {
    return [
      // Nama Lengkap (Read-only)
      _buildReadOnlyField(
        label: 'Nama Lengkap',
        value: widget.userName,
        icon: Icons.person_rounded,
      ),
      const SizedBox(height: 16),

      // NIS (Read-only)
      _buildReadOnlyField(
        label: 'NIS',
        value: widget.userNis,
        icon: Icons.badge_rounded,
      ),
      const SizedBox(height: 16),

      // Kelas
      _buildModernTextField(
        controller: _kelasController,
        focusNode: _kelasFocus,
        label: 'Kelas',
        hint: 'XII RPL 1',
        icon: Icons.class_rounded,
        isValid: _kelasValid,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Kelas harus diisi';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
      ),
      const SizedBox(height: 16),

      // No. HP
      _buildModernTextField(
        controller: _phoneController,
        focusNode: _phoneFocus,
        label: 'No. HP',
        hint: '08123456789',
        icon: Icons.phone_rounded,
        isValid: _phoneValid,
        keyboardType: TextInputType.phone,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'No. HP harus diisi';
          }
          if (value.trim().length < 10) {
            return 'No. HP minimal 10 digit';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => _emailFocus.requestFocus(),
      ),
      const SizedBox(height: 16),

      // Email
      _buildModernTextField(
        controller: _emailController,
        focusNode: _emailFocus,
        label: 'Email',
        hint: 'nama@email.com',
        icon: Icons.email_rounded,
        isValid: _emailValid,
        keyboardType: TextInputType.emailAddress,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Email harus diisi';
          }
          if (!value.contains('@')) {
            return 'Email tidak valid';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (_) => _reasonFocus.requestFocus(),
      ),
      const SizedBox(height: 16),

      // Alasan
      _buildModernTextField(
        controller: _reasonController,
        focusNode: _reasonFocus,
        label: 'Alasan Mengikuti (Opsional)',
        hint: 'Ceritakan motivasi Anda...',
        icon: Icons.edit_note_rounded,
        maxLines: 3,
        textInputAction: TextInputAction.done,
      ),
    ];
  }

  // Build Team Registration Form
  List<Widget> _buildTeamForm() {
    return [
      // Team Name
      _buildModernTextField(
        controller: _teamNameController,
        label: 'Nama Team',
        hint: 'Team Basket A',
        icon: Icons.groups_rounded,
        isValid: _teamNameValid,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Nama team harus diisi';
          }
          return null;
        },
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: 16),

      // Class Name (Read-only for team, pre-filled)
      _buildReadOnlyField(
        label: 'Kelas',
        value: widget.userKelas,
        icon: Icons.class_rounded,
      ),
      const SizedBox(height: 16),

      // Leader Info
      _buildReadOnlyField(
        label: 'Ketua Team',
        value: '${widget.userName} (${widget.userNis})',
        icon: Icons.person_pin_rounded,
      ),
      const SizedBox(height: 20),

      // Team Members Section
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Anggota Team',
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_teamMembers.length} orang',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // List team members
            ...List.generate(_teamMembers.length, (index) {
              final member = _teamMembers[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: member.isLeader 
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: member.isLeader 
                        ? AppColors.primary 
                        : AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: member.isLeader
                            ? AppColors.primary
                            : AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        member.isLeader ? Icons.star : Icons.person,
                        size: 16,
                        color: member.isLeader ? Colors.white : AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            member.name,
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'NIS: ${member.nis}',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!member.isLeader)
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: AppColors.error,
                        onPressed: () => _removeTeamMember(index),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            
            const SizedBox(height: 12),
            
            // Add Member Button
            OutlinedButton.icon(
              onPressed: _addTeamMember,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Tambah Anggota'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  // Modern read-only field
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.lock_outline, size: 16, color: AppColors.textTertiary),
            ],
          ),
        ),
      ],
    );
  }

  // Modern text field with floating label and validation checkmark
  Widget _buildModernTextField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String label,
    required String hint,
    required IconData icon,
    bool isValid = false,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    TextInputAction? textInputAction,
    Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: AppTextStyles.body1.copyWith(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: AppColors.textTertiary.withValues(alpha: 0.6)),
            filled: true,
            fillColor: AppColors.card,
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            suffixIcon: isValid
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF10B981),
                      size: 24,
                    ),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: validator,
        ),
      ],
    );
  }
}

// Team Member Input Model
class TeamMemberInput {
  final String studentId;
  final String name;
  final String nis;
  final String kelas;
  final bool isLeader;

  TeamMemberInput({
    required this.studentId,
    required this.name,
    required this.nis,
    required this.kelas,
    this.isLeader = false,
  });
}

// Team Member Dialog for adding members
class _TeamMemberDialog extends StatefulWidget {
  final Function(TeamMemberInput) onAdd;
  final List<TeamMemberInput> existingMembers;
  final String className;

  const _TeamMemberDialog({
    required this.onAdd,
    required this.existingMembers,
    required this.className,
  });

  @override
  State<_TeamMemberDialog> createState() => _TeamMemberDialogState();
}

class _TeamMemberDialogState extends State<_TeamMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nisController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _nisController.dispose();
    super.dispose();
  }

  void _handleAdd() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check duplicate NIS
    final nis = _nisController.text.trim();
    if (widget.existingMembers.any((m) => m.nis == nis)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('NIS sudah terdaftar di team ini'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final member = TeamMemberInput(
      studentId: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      nis: nis,
      kelas: widget.className,
    );

    widget.onAdd(member);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Tambah Anggota Team'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                hintText: 'Masukkan nama lengkap',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama harus diisi';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nisController,
              decoration: const InputDecoration(
                labelText: 'NIS',
                hintText: 'Masukkan NIS',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'NIS harus diisi';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: _handleAdd,
          child: const Text('Tambah'),
        ),
      ],
    );
  }
}
