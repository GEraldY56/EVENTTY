import 'package:supabase_flutter/supabase_flutter.dart';

/// Bookmark Service
/// Manages event bookmarks/favorites for students via Supabase.
class BookmarkService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all bookmarked event IDs for a user
  Future<List<String>> getBookmarkedEvents(String userId) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select('event_id')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => item['event_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if an event is bookmarked
  Future<bool> isBookmarked(String userId, String eventId) async {
    try {
      final response = await _supabase
          .from('bookmarks')
          .select('id')
          .eq('user_id', userId)
          .eq('event_id', eventId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  /// Add event to bookmarks
  Future<bool> addBookmark(String userId, String eventId) async {
    try {
      await _supabase.from('bookmarks').insert({
        'user_id': userId,
        'event_id': eventId,
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove event from bookmarks
  Future<bool> removeBookmark(String userId, String eventId) async {
    try {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId)
          .eq('event_id', eventId);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Toggle bookmark status
  Future<bool> toggleBookmark(String userId, String eventId) async {
    final isCurrentlyBookmarked =
        await isBookmarked(userId, eventId);

    if (isCurrentlyBookmarked) {
      return await removeBookmark(userId, eventId);
    } else {
      return await addBookmark(userId, eventId);
    }
  }

  /// Clear all bookmarks for a user
  Future<bool> clearAllBookmarks(String userId) async {
    try {
      await _supabase
          .from('bookmarks')
          .delete()
          .eq('user_id', userId);

      return true;
    } catch (e) {
      return false;
    }
  }
}