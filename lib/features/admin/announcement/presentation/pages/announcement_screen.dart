import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/services/announcement_service.dart';
import '../../../../../core/models/announcement_model.dart';

class AnnouncementScreen extends StatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  State<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

class _AnnouncementScreenState extends State<AnnouncementScreen> with SingleTickerProviderStateMixin {
  final AnnouncementService _announcementService = AnnouncementService();
  String _selectedFilter = 'All';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<AnnouncementModel> _announcements = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
    
    // Load announcements from Supabase
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final announcements = await _announcementService.getAllAnnouncements();
      setState(() {
        _announcements = announcements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<AnnouncementModel> get _filteredAnnouncements {
    if (_selectedFilter == 'All') return _announcements;
    if (_selectedFilter == 'Published') {
      return _announcements.where((a) => a.isPublished).toList();
    }
    if (_selectedFilter == 'Draft') {
      return _announcements.where((a) => !a.isPublished).toList();
    }
    return _announcements;
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return AppColors.error;
      case 'medium':
        return AppColors.warning;
      case 'low':
        return AppColors.success;
      default:
        return AppColors.info;
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'event':
        return Icons.event;
      case 'facility':
        return Icons.business;
      case 'academic':
        return Icons.school;
      case 'general':
        return Icons.info_outline;
      default:
        return Icons.announcement;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : SafeArea(
        child: Column(
          children: [
            // Professional Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border(
                  bottom: BorderSide(color: AppColors.border),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Announcements',
                              style: AppTextStyles.heading2,
                            ),
                            Text(
                              '${_filteredAnnouncements.length} announcement${_filteredAnnouncements.length != 1 ? 's' : ''}',
                              style: AppTextStyles.body2.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                        onPressed: _loadAnnouncements,
                      ),
                      IconButton(
                        icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
                        onPressed: () {
                          _showFilterSheet();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', _selectedFilter == 'All'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Published', _selectedFilter == 'Published'),
                        const SizedBox(width: 8),
                        _buildFilterChip('Draft', _selectedFilter == 'Draft'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            // Announcements Feed
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: _filteredAnnouncements.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadAnnouncements,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
                          itemCount: _filteredAnnouncements.length,
                          itemBuilder: (context, index) {
                            final announcement = _filteredAnnouncements[index];
                            return _buildAnnouncementCard(announcement, index);
                          },
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreateAnnouncementDialog();
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: Text(
          'Create',
          style: AppTextStyles.button.copyWith(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load announcements',
            style: AppTextStyles.heading3.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error',
            style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAnnouncements,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedFilter = label);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body2.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncementCard(AnnouncementModel announcement, int index) {
    final isDraft = !announcement.isPublished;
    final priority = announcement.priority ?? 'medium';
    final priorityColor = _getPriorityColor(priority);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(
          color: isDraft ? AppColors.warning.withValues(alpha: 0.3) : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Priority Indicator
          Container(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            decoration: BoxDecoration(
              color: isDraft 
                  ? AppColors.warning.withValues(alpha: 0.05)
                  : priorityColor.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLG),
                topRight: Radius.circular(AppSpacing.radiusLG),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDraft 
                        ? AppColors.warning.withValues(alpha: 0.1)
                        : priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(announcement.category),
                    size: 20,
                    color: isDraft ? AppColors.warning : priorityColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        announcement.category ?? 'General',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        announcement.title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_publish',
                      child: Row(
                        children: [
                          Icon(
                            announcement.isPublished ? Icons.unpublished : Icons.publish,
                            size: 18,
                          ),
                          const SizedBox(width: 12),
                          Text(announcement.isPublished ? 'Unpublish' : 'Publish'),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: AppColors.error),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: AppColors.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) async {
                    if (value == 'delete') {
                      _showDeleteDialog(announcement.id);
                    } else if (value == 'edit') {
                      _showEditAnnouncementDialog(announcement);
                    } else if (value == 'toggle_publish') {
                      await _togglePublish(announcement);
                    }
                  },
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.paddingLG),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.content,
                  style: AppTextStyles.body1.copyWith(height: 1.5),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),

                // Meta Info
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildMetaInfo(
                      Icons.schedule_outlined,
                      announcement.getTimeAgo(),
                    ),
                    _buildMetaInfo(
                      Icons.person_outline,
                      announcement.displayAuthor,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status & Priority Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDraft 
                            ? AppColors.warning.withValues(alpha: 0.1)
                            : AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDraft 
                              ? AppColors.warning.withValues(alpha: 0.3)
                              : AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        isDraft ? 'DRAFT' : 'PUBLISHED',
                        style: AppTextStyles.captionSmall.copyWith(
                          color: isDraft ? AppColors.warning : AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: priorityColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flag,
                            size: 10,
                            color: priorityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            priority.toUpperCase(),
                            style: AppTextStyles.captionSmall.copyWith(
                              color: priorityColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Buttons
          if (!isDraft)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.paddingLG,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppColors.border),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => _showEditAnnouncementDialog(announcement),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      label: const Text('Edit'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: AppColors.border,
                  ),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () {
                        _showAnnouncementDetail(announcement);
                      },
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Full'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
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

  Widget _buildMetaInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.campaign_outlined,
              size: 64,
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No announcements yet',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'All'
                ? 'Create your first announcement'
                : 'No ${_selectedFilter.toLowerCase()} announcements',
            style: AppTextStyles.body2.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateAnnouncementDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Announcement'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text('Filter Options', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('All Announcements'),
              onTap: () {
                setState(() => _selectedFilter = 'All');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.public),
              title: const Text('Published Only'),
              onTap: () {
                setState(() => _selectedFilter = 'Published');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.drafts),
              title: const Text('Drafts Only'),
              onTap: () {
                setState(() => _selectedFilter = 'Draft');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showAnnouncementDetail(AnnouncementModel announcement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: controller,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(announcement.title, style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildMetaInfo(Icons.person, announcement.displayAuthor),
                  const SizedBox(width: 16),
                  _buildMetaInfo(Icons.schedule, announcement.getTimeAgo()),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: AppColors.border),
              const SizedBox(height: 16),
              Text(
                announcement.content,
                style: AppTextStyles.body1.copyWith(height: 1.8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreateAnnouncementDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String? selectedEventId; // null = general announcement
    bool isPublished = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Create Announcement', style: AppTextStyles.heading3),
              const SizedBox(height: 4),
              Text(
                'Announcement akan tampil di halaman News untuk semua siswa',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Judul Announcement *',
                      hintText: 'Contoh: Perubahan Jadwal Event Basketball',
                      border: const OutlineInputBorder(),
                      helperText: 'Judul singkat dan jelas',
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  
                  // Content Field
                  TextField(
                    controller: contentController,
                    decoration: InputDecoration(
                      labelText: 'Isi Announcement *',
                      hintText: 'Jelaskan informasi yang ingin disampaikan...',
                      border: const OutlineInputBorder(),
                      helperText: 'Detail lengkap announcement',
                    ),
                    maxLines: 5,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 16),
                  
                  // Event Selector (NEW!)
                  FutureBuilder<List<dynamic>>(
                    future: _loadEventsForSelection(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const LinearProgressIndicator();
                      }
                      
                      final events = snapshot.data!;
                      return DropdownButtonFormField<String>(
                        value: selectedEventId,
                        decoration: InputDecoration(
                          labelText: 'Event Terkait (Opsional)',
                          border: const OutlineInputBorder(),
                          helperText: 'Kosongkan jika announcement umum',
                          prefixIcon: const Icon(Icons.event),
                        ),
                        hint: const Text('Pilih event atau kosongkan'),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('📢 Announcement Umum (Semua Siswa)'),
                          ),
                          ...events.map((event) => DropdownMenuItem<String>(
                            value: event['id'],
                            child: Text('🎯 ${event['title']}'),
                          )),
                        ],
                        onChanged: (value) {
                          setDialogState(() => selectedEventId = value);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Preview Section
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 20, color: AppColors.info),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedEventId == null
                                ? 'Akan muncul di: Tab News (Semua Siswa)'
                                : 'Akan muncul di: Tab News + Detail Event',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.info,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Publish Switch
                  SwitchListTile(
                    title: const Text('Publish Sekarang'),
                    subtitle: Text(
                      isPublished 
                          ? 'Siswa langsung bisa lihat' 
                          : 'Simpan sebagai draft',
                      style: AppTextStyles.caption,
                    ),
                    value: isPublished,
                    activeColor: AppColors.success,
                    onChanged: (value) {
                      setDialogState(() => isPublished = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan isi harus diisi!'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                try {
                  await _announcementService.createAnnouncement(
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    eventId: selectedEventId,
                    category: selectedEventId != null ? 'Event' : 'General',
                    priority: 'medium',
                    isPublished: isPublished,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isPublished 
                            ? '✅ Announcement berhasil dipublish!' 
                            : '💾 Announcement disimpan sebagai draft',
                      ),
                      backgroundColor: AppColors.success,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  _loadAnnouncements();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Gagal membuat announcement: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: Icon(isPublished ? Icons.send : Icons.save),
              label: Text(isPublished ? 'Publish' : 'Simpan Draft'),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to load events for dropdown
  Future<List<Map<String, dynamic>>> _loadEventsForSelection() async {
    try {
      final response = await Supabase.instance.client
          .from('events')
          .select('id, title')
          .eq('is_published', true)
          .order('date', ascending: false)
          .limit(20);
      
      return List<Map<String, dynamic>>.from(response as List);
    } catch (e) {
      return [];
    }
  }

  void _showEditAnnouncementDialog(AnnouncementModel announcement) {
    final titleController = TextEditingController(text: announcement.title);
    final contentController = TextEditingController(text: announcement.content);
    bool isPublished = announcement.isPublished;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Announcement', style: AppTextStyles.heading3),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Judul Announcement *',
                      border: OutlineInputBorder(),
                    ),
                    maxLength: 100,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Isi Announcement *',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    maxLength: 500,
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Status Publish'),
                    subtitle: Text(
                      isPublished 
                          ? 'Announcement dipublish (siswa bisa lihat)' 
                          : 'Draft (siswa tidak bisa lihat)',
                      style: AppTextStyles.caption,
                    ),
                    value: isPublished,
                    activeColor: AppColors.success,
                    onChanged: (value) {
                      setDialogState(() => isPublished = value);
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                if (titleController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Judul dan isi harus diisi!'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                  return;
                }

                try {
                  await _announcementService.updateAnnouncement(
                    announcement.id,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    isPublished: isPublished,
                  );

                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Announcement berhasil diupdate!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadAnnouncements();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Gagal update: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _togglePublish(AnnouncementModel announcement) async {
    try {
      await _announcementService.togglePublish(announcement.id, announcement.isPublished);
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(announcement.isPublished
              ? 'Announcement unpublished'
              : 'Announcement published'),
          backgroundColor: AppColors.success,
        ),
      );
      _loadAnnouncements();
    } catch (e) {
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle publish: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Announcement', style: AppTextStyles.heading3),
        content: Text(
          'Are you sure you want to delete this announcement? This action cannot be undone.',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _announcementService.deleteAnnouncement(id);
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Announcement deleted successfully'),
                    backgroundColor: AppColors.success,
                  ),
                );
                _loadAnnouncements();
              } catch (e) {
                if (!mounted) return;
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
