import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/news_model.dart';

/// News Service
/// Mengelola CRUD news/article yang dibuat oleh Admin dengan Supabase
class NewsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Get all published news
  Future<List<NewsModel>> getPublishedNews() async {
    try {
      final response = await _supabase
          .from('news')
          .select('*')
          .eq('is_published', true)
          .order('publish_date', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch news: $e');
    }
  }

  /// Get news by ID
  Future<NewsModel?> getNewsById(String id) async {
    try {
      final response = await _supabase
          .from('news')
          .select('*')
          .eq('id', id)
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Get news by category
  Future<List<NewsModel>> getNewsByCategory(String category) async {
    try {
      final response = await _supabase
          .from('news')
          .select('*')
          .eq('category', category)
          .eq('is_published', true)
          .order('publish_date', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch news by category: $e');
    }
  }

  /// Create news (Admin)
  Future<NewsModel> createNews({
    required String title,
    required String content,
    required String excerpt,
    required String category,
    String? imageUrl,
    bool isPinned = false,
    bool isPublished = true,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user profile for author info
      final profile = await _supabase
          .from('profiles')
          .select('full_name')
          .eq('id', user.id)
          .single();

      final data = {
        'title': title,
        'content': content,
        'category': category,
        'author': profile['full_name'] ?? 'Admin',
        'author_id': user.id,
        'image_url': imageUrl,
        'is_pinned': isPinned,
        'is_published': isPublished,
        'views': 0,
      };

      final response = await _supabase
          .from('news')
          .insert(data)
          .select()
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create news: $e');
    }
  }

  /// Update news (Admin)
  Future<NewsModel> updateNews(
    String id, {
    String? title,
    String? content,
    String? category,
    String? imageUrl,
    bool? isPinned,
    bool? isPublished,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (category != null) data['category'] = category;
      if (imageUrl != null) data['image_url'] = imageUrl;
      if (isPinned != null) data['is_pinned'] = isPinned;
      if (isPublished != null) data['is_published'] = isPublished;

      final response = await _supabase
          .from('news')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return NewsModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update news: $e');
    }
  }

  /// Delete news (Admin)
  Future<void> deleteNews(String id) async {
    try {
      await _supabase.from('news').delete().eq('id', id);
    } catch (e) {
      throw Exception('Failed to delete news: $e');
    }
  }

  /// Increment view count
  Future<void> incrementViews(String id) async {
    try {
      await _supabase.rpc('increment_news_views', params: {'news_id': id});
    } catch (e) {
      // Fallback: get current views and increment
      try {
        final news = await getNewsById(id);
        if (news != null) {
          await _supabase
              .from('news')
              .update({'views': news.views + 1})
              .eq('id', id);
        }
      } catch (_) {}
    }
  }

  /// Get all news (Admin - including draft)
  Future<List<NewsModel>> getAllNewsForAdmin() async {
    try {
      final response = await _supabase
          .from('news')
          .select('*')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NewsModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch all news: $e');
    }
  }
}
