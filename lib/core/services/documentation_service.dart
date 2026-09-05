import '../models/documentation_model.dart';

/// Documentation Service
/// Mengelola dokumentasi event (Google Drive links)
class DocumentationService {
  // Singleton pattern
  static final DocumentationService _instance = DocumentationService._internal();
  factory DocumentationService() => _instance;
  DocumentationService._internal();

  // In-memory storage (one documentation per event)
  final Map<String, DocumentationModel> _documentations = {};

  /// Get documentation by event ID
  Future<DocumentationModel?> getDocumentationByEventId(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _documentations[eventId];
  }

  /// Check if event has documentation
  Future<bool> hasDocumentation(String eventId) async {
    return _documentations.containsKey(eventId);
  }

  /// Create documentation for event (Admin)
  Future<DocumentationModel> createDocumentation(DocumentationModel documentation) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _documentations[documentation.eventId] = documentation;
    return documentation;
  }

  /// Update documentation (Admin)
  Future<DocumentationModel?> updateDocumentation(DocumentationModel documentation) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_documentations.containsKey(documentation.eventId)) {
      _documentations[documentation.eventId] = documentation.copyWith(
        updatedAt: DateTime.now(),
      );
      return _documentations[documentation.eventId];
    }
    
    return null;
  }

  /// Delete documentation (Admin)
  Future<bool> deleteDocumentation(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_documentations.containsKey(eventId)) {
      _documentations.remove(eventId);
      return true;
    }
    
    return false;
  }

  /// Get all documentations (Admin)
  Future<List<DocumentationModel>> getAllDocumentations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _documentations.values.toList();
  }

  /// Validate Google Drive URL
  bool isValidGoogleDriveUrl(String url) {
    if (url.isEmpty) return false;
    
    return url.startsWith('http://') || url.startsWith('https://');
  }

  /// Seed mock documentations
  void seedMockDocumentations() {
    _documentations.addAll({
      '1': DocumentationModel(
        id: 'doc_1',
        eventId: '1',
        title: 'Classmeet 2024 Documentation',
        description: 'Lihat foto dan video dokumentasi kegiatan Classmeet 2024. Berbagai kompetisi seru dan momen tak terlupakan!',
        googleDriveUrl: 'https://drive.google.com/drive/folders/example-classmeet-2024',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      '2': DocumentationModel(
        id: 'doc_2',
        eventId: '2',
        title: 'Career Day 2024 Documentation',
        description: 'Dokumentasi lengkap Career Day 2024 termasuk sesi seminar, workshop, dan foto bersama pembicara.',
        googleDriveUrl: 'https://drive.google.com/drive/folders/example-career-day-2024',
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      '3': DocumentationModel(
        id: 'doc_3',
        eventId: '3',
        title: 'Basketball Tournament Documentation',
        description: 'Foto dan video pertandingan Basketball Tournament. Lihat aksi-aksi seru para pemain!',
        googleDriveUrl: 'https://drive.google.com/drive/folders/example-basketball-2024',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    });
  }
}
