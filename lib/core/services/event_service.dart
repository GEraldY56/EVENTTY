import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/event_model.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

class EventService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // ============================================================
  // GET ALL EVENTS
  // ============================================================
  Future<List<EventModel>> getAllEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .order('date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching events', e);
      return [];
    }
  }

  // ============================================================
  // GET FEATURED EVENTS
  // ============================================================
  Future<List<EventModel>> getFeaturedEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('is_featured', true)
          .order('date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching featured events', e);
      return [];
    }
  }

  // ============================================================
  // GET POPULAR EVENTS
  // ============================================================
  Future<List<EventModel>> getPopularEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('is_popular', true)
          .order('date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching popular events', e);
      return [];
    }
  }

  // ============================================================
  // GET EVENT BY ID
  // ============================================================
  Future<EventModel?> getEventById(String id) async {
    try {
      final response = await _supabase
          .from('events')
          .select()
          .eq('id', id)
          .single();

      return EventModel.fromJson(response);
    } catch (e) {
      AppLogger.error('Error fetching event by ID', e);
      return null;
    }
  }

  // ============================================================
  // GET EVENTS BY CATEGORY
  // ============================================================
  Future<List<EventModel>> getEventsByCategory(String category) async {
    try {
      if (category.toLowerCase() == 'all') {
        return await getAllEvents();
      }

      final response = await _supabase
          .from('events')
          .select()
          .ilike('category', category)
          .order('date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching events by category', e);
      return [];
    }
  }

  // ============================================================
  // SEARCH EVENTS
  // ============================================================
  Future<List<EventModel>> searchEvents(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllEvents();
      }

      final search = query.trim();

      final response = await _supabase
          .from('events')
          .select()
          .or(
            'title.ilike.%$search%,'
            'description.ilike.%$search%,'
            'category.ilike.%$search%',
          )
          .order('date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error searching events', e);
      return [];
    }
  }

  // ============================================================
  // REGISTER FOR EVENT
  // ============================================================
  //
  // Untuk sementara method ini tetap dipertahankan agar halaman
  // lama EVENTTY tidak error.
  //
  // Nanti proses registrasi utama akan dipindahkan ke
  // registration_service.dart pada STEP 8B.
  // ============================================================
  Future<bool> registerForEvent(
    String eventId,
    String userId,
  ) async {
    try {
      final event = await getEventById(eventId);

      if (event == null || event.isFull) {
        return false;
      }

      await _supabase
          .from('events')
          .update({
            'registered': event.registered + 1,
          })
          .eq('id', eventId);

      return true;
    } catch (e) {
      AppLogger.error('Error registering for event', e);
      return false;
    }
  }

  // ============================================================
  // CREATE EVENT
  // ============================================================
  // Strip 'id' from the insert payload so the database generates
  // a UUID via DEFAULT uuid_generate_v4(). Passing an empty string
  // for 'id' would cause a Supabase UUID format error.
  // ============================================================
  Future<bool> createEvent(EventModel event) async {
    try {
      final payload = event.toJson()..remove('id');
      final response = await _supabase
          .from('events')
          .insert(payload)
          .select()
          .single();

      // Send notification if event is published
      if (event.isPublished) {
        final eventId = response['id'] as String;
        _sendEventPublishedNotification(
          eventId: eventId,
          eventTitle: event.title,
        );
      }

      return true;
    } catch (e) {
      AppLogger.error('Error creating event', e);
      return false;
    }
  }

  /// Send notification when event is published (fire-and-forget)
  void _sendEventPublishedNotification({
    required String eventId,
    required String eventTitle,
  }) {
    // Fire-and-forget: don't await, don't block main operation
    Future(() async {
      try {
        final notificationService = NotificationService();
        
        // Get all student user IDs
        final studentsResponse = await _supabase
            .from('profiles')
            .select('id')
            .eq('role', 'student');
        
        final studentIds = (studentsResponse as List)
            .map((profile) => profile['id'] as String)
            .toList();
        
        if (studentIds.isEmpty) return;
        
        await notificationService.notifyEventPublished(
          eventId: eventId,
          eventTitle: eventTitle,
          targetUserIds: studentIds,
        );
      } catch (e) {
        // Silent fail - don't break event creation
        AppLogger.error('Failed to send event published notification', e);
      }
    });
  }

  // ============================================================
  // UPDATE EVENT
  // ============================================================
  Future<bool> updateEvent(EventModel event) async {
    try {
      await _supabase
          .from('events')
          .update(event.toJson())
          .eq('id', event.id);

      return true;
    } catch (e) {
      AppLogger.error('Error updating event', e);
      return false;
    }
  }

  // ============================================================
  // DELETE EVENT
  // ============================================================
  Future<bool> deleteEvent(String eventId) async {
    try {
      await _supabase
          .from('events')
          .delete()
          .eq('id', eventId);

      return true;
    } catch (e) {
      AppLogger.error('Error deleting event', e);
      return false;
    }
  }

  // ============================================================
  // GET EVENTS BY STATUS
  // ============================================================
  Future<List<EventModel>> getEventsByStatus(String status) async {
    try {
      if (status.toLowerCase() == 'all') {
        return await getAllEvents();
      }

      final response = await _supabase
          .from('events')
          .select()
          .eq('status', status)
          .order('date', ascending: true);

      return (response as List)
          .map((json) => EventModel.fromJson(json))
          .toList();
    } catch (e) {
      AppLogger.error('Error fetching events by status', e);
      return [];
    }
  }

  // ============================================================
  // LEGACY AI METHODS
  // ============================================================
  //
  // Untuk sementara method ini dipertahankan agar fitur AI lama
  // yang masih memanggilnya tidak langsung rusak.
  //
  // Nanti bisa kita migrasikan ke data Supabase juga.
  // ============================================================

  List<Map<String, dynamic>> getMockEvents() {
    return [];
  }

  Map<String, dynamic>? getEventByIdSync(String eventId) {
    return null;
  }
}