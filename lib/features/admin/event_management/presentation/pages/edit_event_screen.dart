import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/services/event_service.dart';
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
  final _eventService = EventService();

  // Form controllers — initialized empty; populated in _loadEvent()
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _deadlineController = TextEditingController();

  // The original event loaded from the database.
  // Used to preserve fields that are not exposed in this form
  // (registered, status, imageUrl, tags, organizer, etc.)
  EventModel? _originalEvent;

  String _selectedCategory = 'Classmeet';
  bool _isLoadingEvent = true;   // true while fetching event from DB
  bool _isSubmitting = false;    // true while saving update to DB
  String? _fetchError;           // non-null when initial fetch failed

  bool _isPublished = false;
  bool _isRegistrationOpen = true;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _registrationDeadline;

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
  void initState() {
    super.initState();
    _loadEvent();
  }

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

  // ----------------------------------------------------------------
  // Data fetch
  // ----------------------------------------------------------------

  Future<void> _loadEvent() async {
    setState(() {
      _isLoadingEvent = true;
      _fetchError = null;
    });

    final event = await _eventService.getEventById(widget.eventId);

    if (!mounted) return;

    if (event == null) {
      setState(() {
        _isLoadingEvent = false;
        _fetchError = 'Event tidak ditemukan atau gagal dimuat.\nPeriksa koneksi dan coba lagi.';
      });
      return;
    }

    _populateForm(event);
  }

  /// Populate all form fields with real data from [event].
  /// Also stores the original event so un-editable fields are preserved
  /// when building the updated EventModel on submit.
  void _populateForm(EventModel event) {
    // Parse time string (stored as "HH:mm" or "09:00 AM" etc.)
    TimeOfDay parsedTime = _parseTimeString(event.time);

    setState(() {
      _originalEvent = event;
      _isLoadingEvent = false;
      _fetchError = null;

      // Text controllers
      _titleController.text = event.title;
      _descriptionController.text = event.description;
      _locationController.text = event.location;
      _capacityController.text = event.capacity.toString();

      // Date
      _selectedDate = event.date;
      _dateController.text = _formatDate(event.date);

      // Time
      _selectedTime = parsedTime;
      _timeController.text = event.time;

      // Deadline (optional)
      _registrationDeadline = event.registrationDeadline;
      _deadlineController.text = event.registrationDeadline != null
          ? _formatDate(event.registrationDeadline!)
          : '';

      // Category: if DB value is in the dropdown list use it directly,
      // otherwise fall back to first item to avoid DropdownButton assertion.
      _selectedCategory = _categories.contains(event.category)
          ? event.category
          : _categories.first;

      // Toggles
      _isPublished = event.isPublished;
      _isRegistrationOpen = event.isRegistrationOpen;
    });
  }

  // ----------------------------------------------------------------
  // Date / time pickers
  // ----------------------------------------------------------------

  Future<void> _selectDate() async {
    final initial = _selectedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = _formatDate(picked);
      });
    }
  }

  Future<void> _selectTime() async {
    final initial = _selectedTime ?? TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null && mounted) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = picked.format(context);
      });
    }
  }

  Future<void> _selectDeadline() async {
    final initial = _registrationDeadline ?? _selectedDate ?? DateTime.now();
    final lastDate = _selectedDate ?? DateTime.now().add(const Duration(days: 730));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
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

  Future<void> _handleUpdate() async {
    if (_isSubmitting) return; // prevent double submit
    if (!_formKey.currentState!.validate()) return;
    if (_originalEvent == null) return; // guard: no event loaded

    final date = _selectedDate;
    if (date == null) {
      _showSnackBar('Pilih tanggal event terlebih dahulu.', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    // Build the time string from picker result (fall back to original).
    final timeString = _selectedTime != null
        ? _selectedTime!.format(context)
        : _originalEvent!.time;

    // Construct updated EventModel using copyWith so all non-form fields
    // (registered, status, imageUrl, tags, organizer, isFeatured, isPopular,
    //  certificateEnabled, certificateType, minimumAttendance,
    //  registrationType, createdAt) are preserved from the original.
    final updatedEvent = _originalEvent!.copyWith(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      date: date,
      time: timeString,
      location: _locationController.text.trim(),
      capacity: int.parse(_capacityController.text.trim()),
      isPublished: _isPublished,
      isRegistrationOpen: _isRegistrationOpen,
      // Pass null-able deadline: clear if user left it empty
      registrationDeadline: _registrationDeadline,
    );

    final success = await _eventService.updateEvent(updatedEvent);

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Event berhasil diperbarui'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      _showSnackBar(
        'Gagal memperbarui event. Periksa koneksi dan coba lagi.',
        isError: true,
      );
    }
  }

  // ----------------------------------------------------------------
  // Helpers
  // ----------------------------------------------------------------

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  /// Parse stored time string (supports "HH:mm" and "h:mm AM/PM" formats).
  TimeOfDay _parseTimeString(String timeStr) {
    try {
      // Try "HH:mm" format
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        final hourStr = parts[0].trim();
        final minuteStr = parts[1].replaceAll(RegExp(r'[^0-9]'), '').trim();
        final isPm = timeStr.toUpperCase().contains('PM');
        final isAm = timeStr.toUpperCase().contains('AM');
        int hour = int.parse(hourStr);
        final int minute = int.parse(minuteStr.isEmpty ? '0' : minuteStr);
        if (isPm && hour != 12) hour += 12;
        if (isAm && hour == 12) hour = 0;
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (_) {
      // fall through to default
    }
    return const TimeOfDay(hour: 8, minute: 0);
  }

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
        title: Text('Edit Event', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Loading state — show centered spinner while fetching event
    if (_isLoadingEvent) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat data event...'),
          ],
        ),
      );
    }

    // Error state — show error message + retry button
    if (_fetchError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text(
                _fetchError!,
                textAlign: TextAlign.center,
                style: AppTextStyles.body1.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Coba Lagi',
                onPressed: _loadEvent,
              ),
              const SizedBox(height: 12),
              AppButton(
                text: 'Kembali',
                isOutlined: true,
                onPressed: () => context.pop(),
              ),
            ],
          ),
        ),
      );
    }

    // Main form — shown once event is loaded
    return SingleChildScrollView(
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

            // Category dropdown
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

            // Event settings toggles
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
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textSecondary),
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
                      style: AppTextStyles.body2
                          .copyWith(color: AppColors.textSecondary),
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

            // Submit button — disabled while submitting
            AppButton(
              text: _isSubmitting ? 'Menyimpan...' : 'Update Event',
              isLoading: _isSubmitting,
              onPressed: _isSubmitting ? null : _handleUpdate,
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
    );
  }
}
