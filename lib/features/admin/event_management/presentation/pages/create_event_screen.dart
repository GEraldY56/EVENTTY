import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _deadlineController = TextEditingController();
  
  String _selectedCategory = 'Classmeet';
  bool _isLoading = false;
  bool _publishImmediately = false;
  bool _openRegistrationImmediately = true;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _registrationDeadline;
  
  // Certificate configuration
  bool _certificateEnabled = false;
  CertificateType _certificateType = CertificateType.none;
  final _minimumAttendanceController = TextEditingController();

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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: _selectedDate ?? DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _registrationDeadline = picked;
        _deadlineController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _handleCreate() async {
    if (!_formKey.currentState!.validate()) return;

    // Use the selected values (for future API implementation)
    final eventData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'location': _locationController.text,
      'capacity': _capacityController.text,
      'date': _selectedDate?.toIso8601String(),
      'time': _selectedTime?.format(context),
      'registrationDeadline': _registrationDeadline?.toIso8601String(),
      'publishImmediately': _publishImmediately,
      'openRegistration': _openRegistrationImmediately,
      'certificateEnabled': _certificateEnabled,
      'certificateType': _certificateType.name,
      'minimumAttendance': _minimumAttendanceController.text.isNotEmpty 
          ? int.tryParse(_minimumAttendanceController.text) 
          : null,
    };

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      // In real implementation, eventData would be sent to backend
      debugPrint('Event data: $eventData');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _publishImmediately 
                ? 'Event created and published successfully' 
                : 'Event created as draft',
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Create Event', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Event Title',
                hint: 'Enter event title',
                prefixIcon: Icons.title,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'This field is required' : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Category', style: AppTextStyles.titleMedium),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
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
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter event description',
                prefixIcon: Icons.description,
                maxLines: 4,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'This field is required' : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              AppTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter event location',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'This field is required' : null,
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              AppTextField(
                controller: _capacityController,
                label: 'Capacity',
                hint: 'Enter participant capacity',
                prefixIcon: Icons.people,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'This field is required';
                  final capacity = int.tryParse(value!);
                  if (capacity == null || capacity <= 0) {
                    return 'Please enter a valid capacity';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              
              // Date Picker
              GestureDetector(
                onTap: _selectDate,
                child: AbsorbPointer(
                  child: AppTextField(
                    controller: _dateController,
                    label: 'Event Date',
                    hint: 'Select event date',
                    prefixIcon: Icons.calendar_today,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'This field is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              
              // Time Picker
              GestureDetector(
                onTap: _selectTime,
                child: AbsorbPointer(
                  child: AppTextField(
                    controller: _timeController,
                    label: 'Event Time',
                    hint: 'Select event time',
                    prefixIcon: Icons.access_time,
                    validator: (value) =>
                        value?.isEmpty ?? true ? 'This field is required' : null,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              
              // Registration Deadline
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
              
              // Publish Options
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
                    Text('Publication Settings', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: Text('Publish immediately', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Event will be visible to students',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                      value: _publishImmediately,
                      onChanged: (value) {
                        setState(() => _publishImmediately = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                    CheckboxListTile(
                      title: Text('Open registration', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Students can register for this event',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                      value: _openRegistrationImmediately,
                      onChanged: (value) {
                        setState(() => _openRegistrationImmediately = value ?? true);
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.paddingLG),
              
              // Certificate Settings
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
                        Icon(Icons.workspace_premium, color: AppColors.primary, size: 20),
                        const SizedBox(width: 8),
                        Text('Certificate Settings', style: AppTextStyles.titleMedium),
                      ],
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      title: Text('Enable certificate', style: AppTextStyles.body1),
                      subtitle: Text(
                        'Participants can receive certificates',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
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
                      Text('Certificate Type', style: AppTextStyles.body1.copyWith(
                        fontWeight: FontWeight.w600,
                      )),
                      const SizedBox(height: 8),
                      
                      RadioListTile<CertificateType>(
                        title: Text('All Participants', style: AppTextStyles.body1),
                        subtitle: Text(
                          'All participants who attend will receive certificates',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        value: CertificateType.allParticipants,
                        groupValue: _certificateType,
                        onChanged: (value) {
                          setState(() => _certificateType = value ?? CertificateType.none);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      RadioListTile<CertificateType>(
                        title: Text('Winners Only', style: AppTextStyles.body1),
                        subtitle: Text(
                          'Only 1st, 2nd, and 3rd place winners receive certificates',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        value: CertificateType.winners,
                        groupValue: _certificateType,
                        onChanged: (value) {
                          setState(() => _certificateType = value ?? CertificateType.none);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      if (_certificateType == CertificateType.allParticipants) ...[
                        const SizedBox(height: 12),
                        AppTextField(
                          controller: _minimumAttendanceController,
                          label: 'Minimum Attendance % (Optional)',
                          hint: 'e.g., 80 for 80%',
                          prefixIcon: Icons.percent,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: _publishImmediately ? 'Create & Publish Event' : 'Create as Draft',
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
}
