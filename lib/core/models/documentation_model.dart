/// Documentation Model - Maps to event_documentation table in Database V3.2
class DocumentationModel {
  final String id;
  final String eventId;
  final String title;
  final String? description;
  final String fileType;
  final String fileUrl;
  final int? fileSize;
  final String? uploadedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentationModel({
    required this.id,
    required this.eventId,
    required this.title,
    this.description,
    required this.fileType,
    required this.fileUrl,
    this.fileSize,
    this.uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  bool get hasUrl => fileUrl.isNotEmpty;

  bool get isValidUrl {
    return fileUrl.isNotEmpty &&
        (fileUrl.startsWith('http://') || fileUrl.startsWith('https://'));
  }

  String get fileSizeFormatted {
    if (fileSize == null) return 'Unknown size';
    final kb = fileSize! / 1024;
    final mb = kb / 1024;
    if (mb >= 1) {
      return '${mb.toStringAsFixed(2)} MB';
    } else {
      return '${kb.toStringAsFixed(2)} KB';
    }
  }

  /// Convert to JSON for Supabase (snake_case)
  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'title': title,
        'description': description,
        'file_type': fileType,
        'file_url': fileUrl,
        'file_size': fileSize,
        'uploaded_by': uploadedBy,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Create from JSON from Supabase (snake_case)
  factory DocumentationModel.fromJson(Map<String, dynamic> json) =>
      DocumentationModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        fileType: json['file_type'] as String,
        fileUrl: json['file_url'] as String,
        fileSize: json['file_size'] as int?,
        uploadedBy: json['uploaded_by'] as String?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );

  DocumentationModel copyWith({
    String? id,
    String? eventId,
    String? title,
    String? description,
    String? fileType,
    String? fileUrl,
    int? fileSize,
    String? uploadedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DocumentationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      fileType: fileType ?? this.fileType,
      fileUrl: fileUrl ?? this.fileUrl,
      fileSize: fileSize ?? this.fileSize,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
