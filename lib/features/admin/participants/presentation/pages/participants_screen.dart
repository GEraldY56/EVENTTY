import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/registration_service.dart';
import '../../../../../core/services/event_service.dart';
import '../../../../../core/models/registration_model.dart';
import '../../../../../core/models/event_model.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  const ParticipantsScreen({super.key});

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> with SingleTickerProviderStateMixin {
  final RegistrationService _registrationService = RegistrationService();
  final EventService _eventService = EventService();
  
  late TabController _tabController;
  List<EventModel> _events = [];
  List<RegistrationModel> _allRegistrations = [];
  List<RegistrationModel> _filteredRegistrations = [];
  
  String? _selectedEventId;
  RegistrationStatus? _selectedStatus;
  String _searchQuery = '';
  
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load all events
    final events = await _eventService.getAllEvents();
    
    // Get all registrations (mock - in real app, get from backend)
    // For now, we'll show empty state or use existing registrations
    final allRegs = _registrationService.registrationsStream;
    
    if (mounted) {
      setState(() {
        _events = events;
        _isLoading = false;
      });
      
      // Listen to registration stream
      allRegs.listen((registrations) {
        if (mounted) {
          setState(() {
            _allRegistrations = registrations;
            _applyFilters();
          });
        }
      });
      
      // Initial load
      _allRegistrations = await _registrationService.getAllRegistrations();
      _applyFilters();
    }
  }

  void _onTabChanged() {
    _applyFilters();
  }

  void _applyFilters() {
    List<RegistrationModel> filtered = _allRegistrations;
    
    // Filter by tab (Individual vs Team)
    if (_tabController.index == 0) {
      filtered = filtered.where((r) => r.isIndividual).toList();
    } else {
      filtered = filtered.where((r) => r.isTeam).toList();
    }
    
    // Filter by event
    if (_selectedEventId != null) {
      filtered = filtered.where((r) => r.eventId == _selectedEventId).toList();
    }
    
    // Filter by status
    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final query = _searchQuery.toLowerCase();
        if (r.isIndividual) {
          return (r.userName?.toLowerCase().contains(query) ?? false) ||
                 (r.userId?.toLowerCase().contains(query) ?? false);
        } else {
          return (r.teamName?.toLowerCase().contains(query) ?? false) ||
                 (r.leaderName?.toLowerCase().contains(query) ?? false) ||
                 (r.className?.toLowerCase().contains(query) ?? false) ||
                 (r.members?.any((m) => 
                   m.name.toLowerCase().contains(query) ||
                   m.nis.toLowerCase().contains(query)
                 ) ?? false);
        }
      }).toList();
    }
    
    setState(() {
      _filteredRegistrations = filtered;
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Participants', style: AppTextStyles.heading3),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Individual'),
            Tab(text: 'Team'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filters
          _buildFilters(),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildIndividualList(),
                      _buildTeamList(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.paddingLG),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Column(
        children: [
          // Search
          TextField(
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
            decoration: InputDecoration(
              hintText: 'Cari nama, NIS, atau kelas...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Event and Status filters
          Row(
            children: [
              Expanded(
                child: _buildEventFilter(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusFilter(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEventFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedEventId,
      decoration: InputDecoration(
        labelText: 'Filter Event',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Semua Event'),
        ),
        ..._events.map((event) => DropdownMenuItem<String>(
          value: event.id,
          child: Text(
            event.title,
            overflow: TextOverflow.ellipsis,
          ),
        )),
      ],
      onChanged: (value) {
        setState(() => _selectedEventId = value);
        _applyFilters();
      },
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<RegistrationStatus>(
      value: _selectedStatus,
      decoration: InputDecoration(
        labelText: 'Filter Status',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      items: [
        const DropdownMenuItem<RegistrationStatus>(
          value: null,
          child: Text('Semua Status'),
        ),
        ...RegistrationStatus.values.map((status) => DropdownMenuItem<RegistrationStatus>(
          value: status,
          child: Text(status.displayName),
        )),
      ],
      onChanged: (value) {
        setState(() => _selectedStatus = value);
        _applyFilters();
      },
    );
  }

  Widget _buildIndividualList() {
    if (_filteredRegistrations.isEmpty) {
      return _buildEmptyState('Tidak ada pendaftaran individual');
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        itemCount: _filteredRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _filteredRegistrations[index];
          final event = _events.firstWhere(
            (e) => e.id == registration.eventId,
            orElse: () => EventModel(
              id: '',
              title: 'Unknown Event',
              description: '',
              category: '',
              date: DateTime.now(),
              time: '',
              location: '',
              organizer: '',
              capacity: 0,
            ),
          );
          
          return _buildIndividualCard(registration, event);
        },
      ),
    );
  }

  Widget _buildTeamList() {
    if (_filteredRegistrations.isEmpty) {
      return _buildEmptyState('Tidak ada pendaftaran team');
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.paddingLG),
        itemCount: _filteredRegistrations.length,
        itemBuilder: (context, index) {
          final registration = _filteredRegistrations[index];
          final event = _events.firstWhere(
            (e) => e.id == registration.eventId,
            orElse: () => EventModel(
              id: '',
              title: 'Unknown Event',
              description: '',
              category: '',
              date: DateTime.now(),
              time: '',
              location: '',
              organizer: '',
              capacity: 0,
            ),
          );
          
          return _buildTeamCard(registration, event);
        },
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
              Icons.people_outline,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada pendaftaran untuk kategori ini',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndividualCard(RegistrationModel registration, EventModel event) {
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
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person,
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
                        registration.userName ?? '-',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'NIS: ${registration.userId ?? '-'}',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(registration.status),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Event Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.event, 'Event', event.title),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.class_, 'Kelas', registration.formData['kelas'] as String? ?? '-'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.phone, 'No. HP', registration.formData['phone'] as String? ?? '-'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.email, 'Email', registration.formData['email'] as String? ?? '-'),
                if (registration.formData['reason'] != null && (registration.formData['reason'] as String).isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.edit_note, 'Alasan', registration.formData['reason'] as String),
                ],
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                if (registration.status == RegistrationStatus.pending) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRegistration(registration),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRegistration(registration),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                if (registration.status != RegistrationStatus.pending)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewDetails(registration, event),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Lihat Detail'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamCard(RegistrationModel registration, EventModel event) {
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
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups,
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
                        registration.teamName ?? '-',
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${registration.memberCount} anggota',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(registration.status),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // Event & Team Info
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.event, 'Event', event.title),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.class_, 'Kelas', registration.className ?? '-'),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.person_pin, 'Ketua', registration.leaderName ?? '-'),
                
                const SizedBox(height: 16),
                
                // Team Members
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      leading: const Icon(
                        Icons.people_outline,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        'Daftar Anggota (${registration.memberCount})',
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      children: [
                        ...registration.members?.map((member) {
                          final isLeader = member.studentId == registration.leaderId;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLeader 
                                  ? AppColors.primary.withValues(alpha: 0.05)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isLeader 
                                    ? AppColors.primary.withValues(alpha: 0.3)
                                    : AppColors.border.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isLeader 
                                        ? AppColors.primary 
                                        : AppColors.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isLeader ? Icons.star : Icons.person,
                                    size: 16,
                                    color: isLeader ? Colors.white : AppColors.primary,
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
          ),
          
          const Divider(height: 1),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Row(
              children: [
                if (registration.status == RegistrationStatus.pending) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectRegistration(registration),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Tolak'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveRegistration(registration),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Setujui'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
                if (registration.status != RegistrationStatus.pending)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewDetails(registration, event),
                      icon: const Icon(Icons.info_outline, size: 18),
                      label: const Text('Lihat Detail'),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RegistrationStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: AppTextStyles.captionSmall.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
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

  Future<void> _approveRegistration(RegistrationModel registration) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Setujui Pendaftaran'),
        content: Text(
          registration.isTeam
              ? 'Apakah Anda yakin ingin menyetujui pendaftaran team ${registration.teamName}?'
              : 'Apakah Anda yakin ingin menyetujui pendaftaran ${registration.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Ya, Setujui'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _registrationService.updateRegistrationStatus(
        registrationId: registration.id,
        status: RegistrationStatus.confirmed,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendaftaran berhasil disetujui'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menyetujui pendaftaran'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _rejectRegistration(RegistrationModel registration) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tolak Pendaftaran'),
        content: Text(
          registration.isTeam
              ? 'Apakah Anda yakin ingin menolak pendaftaran team ${registration.teamName}?'
              : 'Apakah Anda yakin ingin menolak pendaftaran ${registration.userName}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Ya, Tolak'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _registrationService.updateRegistrationStatus(
        registrationId: registration.id,
        status: RegistrationStatus.cancelled,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pendaftaran berhasil ditolak'),
              backgroundColor: AppColors.success,
            ),
          );
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menolak pendaftaran'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _viewDetails(RegistrationModel registration, EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(registration.isTeam ? 'Detail Team' : 'Detail Pendaftaran'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Event: ${event.title}'),
              const SizedBox(height: 8),
              Text('Status: ${registration.status.displayName}'),
              const SizedBox(height: 8),
              Text('Tanggal Daftar: ${registration.registrationDate.toString().split('.')[0]}'),
              // Add more details as needed
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
