/// Documentation Model
/// Dokumentasi untuk setiap event (link ke Google Drive)
class DocumentationModel {
  final String id;
  final String eventId;
  final String title;
  final String description;
  final String googleDriveUrl;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DocumentationModel({
    required this.id,
    required this.eventId,
    required this.title,
    required this.description,
    required this.googleDriveUrl,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasUrl => googleDriveUrl.isNotEmpty;
  
  bool get isValidUrl {
    return googleDriveUrl.isNotEmpty && 
           (googleDriveUrl.startsWith('http://') || 
            googleDriveUrl.startsWith('https://'));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'title': title,
        'description': description,
        'googleDriveUrl': googleDriveUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory DocumentationModel.fromJson(Map<String, dynamic> json) => DocumentationModel(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        googleDriveUrl: json['googleDriveUrl'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  DocumentationModel copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    String? googleDriveUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      googleDriveUrl: googleDriveUrl ?? this.googleDriveUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
