import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/announcement_model.dart';

class AnnouncementService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get all announcements (admin)
  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('''
            *,
            author_profile:profiles!announcements_author_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  // Get published announcements only (for students)
  Future<List<AnnouncementModel>> getPublishedAnnouncements({int? limit}) async {
    try {
      var query = _supabase
          .from('announcements')
          .select('''
            *,
            author_profile:profiles!announcements_author_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('is_published', true)
          .order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;

      return (response as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch published announcements: $e');
    }
  }

  // Get announcement by ID
  Future<AnnouncementModel> getAnnouncementById(String id) async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('''
            *,
            author_profile:profiles!announcements_author_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('id', id)
          .single();

      return AnnouncementModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch announcement: $e');
    }
  }

  // Get announcements by event ID
  Future<List<AnnouncementModel>> getAnnouncementsByEvent(String eventId) async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('''
            *,
            author_profile:profiles!announcements_author_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .eq('event_id', eventId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => AnnouncementModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch event announcements: $e');
    }
  }

  // Create announcement
  Future<AnnouncementModel> createAnnouncement({
    required String title,
    required String content,
    String? eventId,
    String? category,
    String? priority,
    bool isPinned = false,
    bool isPublished = true,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user profile for author name
      final profile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();

      final data = {
        'title': title,
        'content': content,
        'event_id': eventId,
        'category': category ?? 'General',
        'priority': priority ?? 'medium',
        'author': profile['full_name'] ?? 'Admin',
        'author_id': user.id,
        'is_pinned': isPinned,
        'is_published': isPublished,
      };

      final response = await _supabase
          .from('announcements')
          .insert(data)
          .select('''
            *,
            author_profile:profiles!announcements_author_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .single();

      return AnnouncementModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  // Update announcement
  Future<AnnouncementModel> updateAnnouncement(
    String id, {
    String? title,
    String? content,
    String? category,
    String? priority,
    bool? isPinned,
    bool? isPublished,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (category != null) data['category'] = category;
      if (priority != null) data['priority'] = priority;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _supabase
          .from('announcements')
          .update(data)
          .eq('id', id)
          .select('''
            *,
            author_profile:profiles!announcements_author_id_fkey(
              full_name,
              avatar_url
            )
          ''')
          .single();

      return AnnouncementModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  // Delete announcement
  Future<void> deleteAnnouncement(String id) async {
    try {
      await _supabase.from('announcements').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  // Toggle pin status
  Future<void> togglePin(String id, bool isPinned) async {
    try {
      await _supabase
          .from('announcements')
          .update({'is_pinned': !isPinned})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to toggle pin: $e');
    }
  }

  // Toggle publish status
  Future<void> togglePublish(String id, bool isPublished) async {
    try {
      await _supabase
          .from('announcements')
          .update({'is_published': !isPublished})
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to toggle publish status: $e');
    }
  }

  // Get announcement statistics (admin)
  Future<Map<String, int>> getStatistics() async {
    try {
      final allResponse = await _supabase
          .from('announcements')
          .select('id')
          .count();

      final publishedResponse = await _supabase
          .from('announcements')
          .select('id')
          .eq('is_published', true)
          .count();

      final pinnedResponse = await _supabase
          .from('announcements')
          .select('id')
          .eq('is_pinned', true)
          .count();

      return {
        'total': allResponse.count,
        'published': publishedResponse.count,
        'draft': allResponse.count - publishedResponse.count,
        'pinned': pinnedResponse.count,
      };
    } catch (e) {
      throw Exception('Failed to fetch statistics: $e');
    }
  }
}
