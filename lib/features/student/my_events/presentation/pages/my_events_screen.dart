import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/registration_service.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/registration_model.dart';
import '../../../../../core/models/event_model.dart';
import '../../../../../core/providers/auth_provider.dart';


class MyEventsScreen extends ConsumerStatefulWidget {
  const MyEventsScreen({super.key});

  @override
  ConsumerState<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends ConsumerState<MyEventsScreen> {
  final RegistrationService _registrationService = RegistrationService();
  final EventService _eventService = EventService();
  
  List<RegistrationModel> _registrations = [];
  Map<String, EventModel> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMyEvents();
  }

  Future<void> _loadMyEvents() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? '';

    // Get user's registrations
    final registrations =
    await _registrationService.getUserRegistrations(userId);

    // Load event details for each registration
    final Map<String, EventModel> eventMap = {};
    for (final reg in registrations) {
      final event = await _eventService.getEventById(reg.eventId);
      if (event != null) {
        eventMap[reg.eventId] = event;
      }
    }

    if (mounted) {
      setState(() {
        _registrations = registrations;
        _events = eventMap;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Events', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _registrations.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadMyEvents,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                    itemCount: _registrations.length,
                    itemBuilder: (context, index) {
                      final registration = _registrations[index];
                      final event = _events[registration.eventId];
                      
                      if (event == null) {
                        return const SizedBox.shrink();
                      }

                      return _buildEventCard(registration, event);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada event terdaftar',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Daftar event untuk melihat di sini',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/student'),
            icon: const Icon(Icons.explore),
            label: const Text('Jelajahi Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(RegistrationModel registration, EventModel event) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                // Event Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    registration.isTeam ? Icons.groups : Icons.person,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.formattedDate,
                            style: AppTextStyles.captionSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(registration.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    registration.status.displayName,
                    style: AppTextStyles.captionSmall.copyWith(
                      color: _getStatusColor(registration.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Registration Details
          if (registration.isTeam) ...[
            _buildTeamInfo(registration),
          ] else ...[
            _buildIndividualInfo(registration),
          ],

          const Divider(height: 1),

          // Actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/student/event/${event.id}'),
                    icon: const Icon(Icons.info_outline, size: 18),
                    label: const Text('Detail Event'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (registration.status == RegistrationStatus.pending)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _cancelRegistration(registration),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Batalkan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualInfo(RegistrationModel registration) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pendaftaran Individual',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Nama', registration.userName ?? '-'),
          _buildInfoRow('Kelas', registration.formData['kelas'] as String? ?? '-'),
          if (registration.formData['phone'] != null)
            _buildInfoRow('No. HP', registration.formData['phone'] as String),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(RegistrationModel registration) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Pendaftaran Team',
                style: AppTextStyles.body2.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${registration.memberCount} anggota',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildInfoRow('Team', registration.teamName ?? '-'),
          _buildInfoRow('Kelas', registration.className ?? '-'),
          _buildInfoRow('Ketua', registration.leaderName ?? '-'),
          
          const SizedBox(height: 8),
          
          // Team Members Expansion
          Container(
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                leading: Icon(
                  Icons.people_outline,
                  size: 20,
                  color: AppColors.primary,
                ),
                title: Text(
                  'Lihat Anggota',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                children: [
                  ...registration.members?.asMap().entries.map((entry) {
                    final member = entry.value;
                    final isLeader = member.studentId == registration.leaderId;
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isLeader 
                            ? AppColors.primary.withValues(alpha: 0.05)
                            : AppColors.card,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isLeader 
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.border.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isLeader 
                                  ? AppColors.primary 
                                  : AppColors.primary.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLeader ? Icons.star : Icons.person,
                              size: 14,
                              color: isLeader ? Colors.white : AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 10),
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
                          if (isLeader)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Ketua',
                                style: AppTextStyles.captionSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList() ?? [],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            ': ',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RegistrationStatus status) {
    switch (status) {
      case RegistrationStatus.pending:
        return AppColors.warning;
      case RegistrationStatus.confirmed:
        return AppColors.success;
      case RegistrationStatus.attended:
        return AppColors.info;
      case RegistrationStatus.cancelled:
        return AppColors.error;
    }
  }

  Future<void> _cancelRegistration(RegistrationModel registration) async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? '';
    
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pendaftaran'),
        content: Text(
          registration.isTeam
              ? 'Apakah Anda yakin ingin membatalkan pendaftaran team ini?'
              : 'Apakah Anda yakin ingin membatalkan pendaftaran?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _registrationService.cancelRegistration(
        registration.id,
        userId,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendaftaran berhasil dibatalkan'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadMyEvents();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal membatalkan pendaftaran'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }
}
