import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';

class EditEventScreen extends StatefulWidget {
  final String eventId;

  const EditEventScreen({super.key, required this.eventId});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Sample Event');
  final _descriptionController = TextEditingController(text: 'Sample description');
  final _locationController = TextEditingController(text: 'SMKN 20 Jakarta');
  final _capacityController = TextEditingController(text: '100');
  final _dateController = TextEditingController(text: '15/12/2026');
  final _timeController = TextEditingController(text: '09:00 AM');
  final _deadlineController = TextEditingController(text: '10/12/2026');
  
  String _selectedCategory = 'Classmeet';
  bool _isLoading = false;
  bool _isPublished = true;
  bool _isRegistrationOpen = true;
  DateTime? _selectedDate = DateTime(2026, 12, 15);
  TimeOfDay? _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  DateTime? _registrationDeadline = DateTime(2026, 12, 10);

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
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
      initialTime: _selectedTime ?? TimeOfDay.now(),
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
      initialDate: _registrationDeadline ?? DateTime.now(),
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

  Future<void> _handleUpdate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated successfully')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Edit Event', style: AppTextStyles.heading3),
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
              
              // Publication Settings
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
                    Text('Event Settings', style: AppTextStyles.titleMedium),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: Text('Published', style: AppTextStyles.body1),
                      subtitle: Text(
                        _isPublished 
                            ? 'Event is visible to students' 
                            : 'Event is hidden (draft)',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() => _isPublished = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: Text('Registration Open', style: AppTextStyles.body1),
                      subtitle: Text(
                        _isRegistrationOpen 
                            ? 'Students can register' 
                            : 'Registration is closed',
                        style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      ),
                      value: _isRegistrationOpen,
                      onChanged: (value) {
                        setState(() => _isRegistrationOpen = value);
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Update Event',
                isLoading: _isLoading,
                onPressed: _handleUpdate,
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
