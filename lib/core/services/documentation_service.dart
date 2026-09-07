import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/documentation_model.dart';

/// Documentation Service
/// Mengelola dokumentasi event (Google Drive links)
class DocumentationService {
  final _supabase = Supabase.instance.client;

  /// Get documentation by event ID
  Future<DocumentationModel?> getDocumentationByEventId(String eventId) async {
    try {
      final response = await _supabase
          .from('event_documentation')
          .select()
          .eq('event_id', eventId)
          .maybeSingle();
      
      if (response == null) return null;
      return DocumentationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to get documentation: $e');
    }
  }

  /// Check if event has documentation
  Future<bool> hasDocumentation(String eventId) async {
    try {
      final doc = await getDocumentationByEventId(eventId);
      return doc != null;
    } catch (e) {
      return false;
    }
  }

  /// Create documentation for event (Admin)
  Future<DocumentationModel> createDocumentation(DocumentationModel documentation) async {
    try {
      final data = {
        'event_id': documentation.eventId,
        'title': documentation.title,
        'description': documentation.description,
        'google_drive_url': documentation.googleDriveUrl,
      };

      final response = await _supabase
          .from('event_documentation')
          .insert(data)
          .select()
          .single();

      return DocumentationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create documentation: $e');
    }
  }

  /// Update documentation (Admin)
  Future<DocumentationModel?> updateDocumentation(DocumentationModel documentation) async {
    try {
      final data = {
        'title': documentation.title,
        'description': documentation.description,
        'google_drive_url': documentation.googleDriveUrl,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('event_documentation')
          .update(data)
          .eq('event_id', documentation.eventId)
          .select()
          .single();

      return DocumentationModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to update documentation: $e');
    }
  }

  /// Delete documentation (Admin)
  Future<bool> deleteDocumentation(String eventId) async {
    try {
      await _supabase
          .from('event_documentation')
          .delete()
          .eq('event_id', eventId);
      return true;
    } catch (e) {
      throw Exception('Failed to delete documentation: $e');
    }
  }

  /// Get all documentations (Admin)
  Future<List<DocumentationModel>> getAllDocumentations() async {
    try {
      final response = await _supabase
          .from('event_documentation')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => DocumentationModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to get documentations: $e');
    }
  }

  /// Validate Google Drive URL
  bool isValidGoogleDriveUrl(String url) {
    if (url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }
}
