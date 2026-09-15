import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';

/// News Service (Maps to announcements table in Database V3.2)
/// Mengelola CRUD announcements yang dibuat oleh Admin dengan Supabase
/// NOTE: NewsModel is kept for UI compatibility but queries announcements table
class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all published announcements
  Future<List<NewsModel>> getPublishedNews() async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('*')
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements: $e');
    }
  }

  /// Get announcement by ID
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('*')
          .eq('id', id)
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get announcements by event (filtered)
  Future<List<NewsModel>> getNewsByEvent(String eventId) async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('*')
          .eq('event_id', eventId)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch announcements by event: $e');
    }
  }

  /// Create announcement (Admin)
  Future<NewsModel> createNews({
    required String title,
    required String content,
    String? eventId,
    bool isPinned = false,
    bool isPublished = true,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final data = {
        'title': title,
        'content': content,
        'author_id': user.id,
        'event_id': eventId,
        'is_pinned': isPinned,
        'is_published': isPublished,
      };

      final response = await _supabase
          .from('announcements')
          .insert(data)
          .select()
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create announcement: $e');
    }
  }

  /// Update announcement (Admin)
  Future<NewsModel> updateNews(
    String id, {
    String? title,
    String? content,
    String? eventId,
    bool? isPinned,
    bool? isPublished,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (eventId != null) data['event_id'] = eventId;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _supabase
          .from('announcements')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update announcement: $e');
    }
  }

  /// Delete announcement (Admin)
  Future<void> deleteNews(String id) async {
    try {
      await _supabase.from('announcements').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete announcement: $e');
    }
  }

  /// Get all announcements (Admin - including draft)
  Future<List<NewsModel>> getAllNewsForAdmin() async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all announcements: $e');
    }
  }

  /// Get pinned announcements
  Future<List<NewsModel>> getPinnedNews() async {
    try {
      final response = await _supabase
          .from('announcements')
          .select('*')
          .eq('is_pinned', true)
          .eq('is_published', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch pinned announcements: $e');
    }
  }
}
