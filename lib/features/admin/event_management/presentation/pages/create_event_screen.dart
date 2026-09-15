import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/models/registration_model.dart' show RegistrationType;
import '../../../../../core/services/event_service.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _eventService = EventService();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _minimumAttendanceController = TextEditingController();

  String _selectedCategory = 'Classmeet';
  bool _isSubmitting = false;
  bool _publishImmediately = false;
  bool _openRegistrationImmediately = true;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _registrationDeadline;

  // Certificate configuration
  bool _certificateEnabled = false;
  CertificateType _certificateType = CertificateType.none;

  final List<String> _categories = [
    'Classmeet',
    'Sports Competition',
    'Seminar',
    'Workshop',
    'Career Day',
    'Science Fair',
    'English Competition',
    'Art Festival',
  ];

  // ----------------------------------------------------------------
  // Lifecycle
  // ----------------------------------------------------------------

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _deadlineController.dispose();
    _minimumAttendanceController.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------------
  // Date / time pickers
  // ----------------------------------------------------------------

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);

        // If deadline is after new event date, clear it
        if (_registrationDeadline != null &&
            _registrationDeadline!.isAfter(picked)) {
          _registrationDeadline = null;
          _deadlineController.clear();
        }
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDeadline() async {
    // Deadline must be on or before the event date
    final lastDate =
        _selectedDate ?? DateTime.now().add(const Duration(days: 730));
    final initial = _registrationDeadline ?? DateTime.now();

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(lastDate) ? lastDate : initial,
      firstDate: DateTime.now(),
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      setState(() {
        _registrationDeadline = picked;
        _deadlineController.text = _formatDate(picked);
      });
    }
  }

  // ----------------------------------------------------------------
  // Submit
  // ----------------------------------------------------------------

  Future<void> _handleCreate() async {
    if (_isSubmitting) return; // prevent double submit
    if (!_formKey.currentState!.validate()) return;

    // Extra guards not covered by form validators
    if (_selectedDate == null) {
      _showSnackBar('Pilih tanggal event terlebih dahulu.', isError: true);
      return;
    }
    if (_selectedTime == null) {
      _showSnackBar('Pilih waktu event terlebih dahulu.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    // Parse capacity (already validated by form validator)
    final capacity = int.parse(_capacityController.text.trim());

    // Parse optional minimum attendance
    int? minimumAttendance;
    final minAttText = _minimumAttendanceController.text.trim();
    if (minAttText.isNotEmpty) {
      minimumAttendance = int.tryParse(minAttText);
    }

    // Determine certificate type:
    // If certificate is disabled, force CertificateType.none
    final certType =
        _certificateEnabled ? _certificateType : CertificateType.none;

    // Build EventModel. 'id' is set to empty string as a placeholder —
    // EventService.createEvent() strips it before the INSERT so the
    // database generates a UUID via DEFAULT uuid_generate_v4().
    final newEvent = EventModel(
      id: '',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      date: _selectedDate!,
      time: _selectedTime!.format(context),
      location: _locationController.text.trim(),
      organizer: 'OSIS SMKN 20 Jakarta',
      capacity: capacity,
      registered: 0,
      status: 'open',
      isPublished: _publishImmediately,
      isRegistrationOpen: _openRegistrationImmediately,
      registrationDeadline: _registrationDeadline,
      certificateEnabled: _certificateEnabled,
      certificateType: certType,
      minimumAttendance: minimumAttendance,
      registrationType: RegistrationType.individual,
    );

    final success = await _eventService.createEvent(newEvent);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _publishImmediately
                ? '✅ Event berhasil dibuat dan dipublikasikan'
                : '✅ Event berhasil dibuat sebagai draft',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop(); // pop only on real success
    } else {
      _showSnackBar(
        'Gagal membuat event. Periksa koneksi dan coba lagi.',
        isError: true,
      );
      // do NOT pop — stay on screen so admin can retry
    }
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

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
        title: Text('Create Event', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              AppTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'Enter event title',
                prefixIcon: Icons.title,
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'This field is required'
                        : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Category
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusLG),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category, style: AppTextStyles.body1),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter event description',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'This field is required'
                        : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Location
              AppTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter event location',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) =>
                    (value == null || value.trim().isEmpty)
                        ? 'This field is required'
                        : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Capacity
              AppTextField(
                controller: _capacityController,
                label: 'Capacity',
                hint: 'Enter participant capacity',
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  final capacity = int.tryParse(value.trim());
                  if (capacity == null || capacity <= 0) {
                    return 'Please enter a valid capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Date picker
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: AppTextField(
                    controller: _dateController,
                    label: 'Event Date',
                    hint: 'Select event date',
                    prefixIcon: Icons.calendar_today,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'This field is required'
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Time picker
              GestureDetector(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: AppTextField(
                    controller: _timeController,
                    label: 'Event Time',
                    hint: 'Select event time',
                    prefixIcon: Icons.access_time,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'This field is required'
                            : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Registration deadline (optional)
              GestureDetector(
                onTap: _selectDeadline,
                child: AbsorbPointer(
                  child: AppTextField(
                    controller: _deadlineController,
                    label: 'Registration Deadline (Optional)',
                    hint: 'Select registration deadline',
                    prefixIcon: Icons.event_busy,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Publication settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Publication Settings',
                        style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title:
                          Text('Publish immediately', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Event will be visible to students',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      value: _publishImmediately,
                      onChanged: (value) {
                        setState(() => _publishImmediately = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: Text('Open registration',
                          style: AppTextStyles.body1),
                      subtitle: Text(
                        'Students can register for this event',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      value: _openRegistrationImmediately,
                      onChanged: (value) {
                        setState(
                            () => _openRegistrationImmediately = value ?? true);
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),

              // Certificate settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.workspace_premium,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Certificate Settings',
                            style: AppTextStyles.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: Text('Enable certificate',
                          style: AppTextStyles.body1),
                      subtitle: Text(
                        'Participants can receive certificates',
                        style: AppTextStyles.body2
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      value: _certificateEnabled,
                      onChanged: (value) {
                        setState(() {
                          _certificateEnabled = value ?? false;
                          if (!_certificateEnabled) {
                            _certificateType = CertificateType.none;
                          }
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    if (_certificateEnabled) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        'Certificate Type',
                        style: AppTextStyles.body1
                            .copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<CertificateType>(
                        title: Text('All Participants',
                            style: AppTextStyles.body1),
                        subtitle: Text(
                          'All participants who attend will receive certificates',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        value: CertificateType.allParticipants,
                        groupValue: _certificateType,
                        onChanged: (value) {
                          setState(() =>
                              _certificateType =
                                  value ?? CertificateType.none);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<CertificateType>(
                        title:
                            Text('Winners Only', style: AppTextStyles.body1),
                        subtitle: Text(
                          'Only 1st, 2nd, and 3rd place winners receive certificates',
                          style: AppTextStyles.caption
                              .copyWith(color: AppColors.textSecondary),
                        ),
                        value: CertificateType.winners,
                        groupValue: _certificateType,
                        onChanged: (value) {
                          setState(() =>
                              _certificateType =
                                  value ?? CertificateType.none);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      if (_certificateType ==
                          CertificateType.allParticipants) ...[
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _minimumAttendanceController,
                          label: 'Minimum Attendance % (Optional)',
                          hint: 'e.g., 80 for 80%',
                          prefixIcon: Icons.percent,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return null; // optional
                            }
                            final pct = int.tryParse(value.trim());
                            if (pct == null || pct < 0 || pct > 100) {
                              return 'Enter a value between 0 and 100';
                            }
                            return null;
                          },
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit button — disabled while submitting
              AppButton(
                text: _isSubmitting
                    ? 'Menyimpan...'
                    : (_publishImmediately
                        ? 'Create & Publish Event'
                        : 'Create as Draft'),
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _handleCreate,
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Cancel',
                isOutlined: true,
                onPressed: _isSubmitting ? null : () => context.pop(),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
