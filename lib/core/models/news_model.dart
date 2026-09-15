/// News Model (Maps to announcements table in Database V3.2)
/// Kept as NewsModel for UI compatibility but maps to announcements
class NewsModel {
  final String id;
  final String? eventId; // Can be null for general announcements
  final String authorId;
  final String title;
  final String content;
  final bool isPinned;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsModel({
    required this.id,
    this.eventId,
    required this.authorId,
    required this.title,
    required this.content,
    this.isPinned = false,
    this.isPublished = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get readTime {
    final words = content.split(' ').length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays ~/ 365 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays ~/ 30 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  bool get isEventSpecific => eventId != null;
  bool get isGeneral => eventId == null;

  /// Convert to JSON for Supabase (snake_case)
  Map<String, dynamic> toJson() => {
        'id': id,
        'event_id': eventId,
        'author_id': authorId,
        'title': title,
        'content': content,
        'is_pinned': isPinned,
        'is_published': isPublished,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Create from JSON from Supabase (snake_case)
  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String?,
      authorId: json['author_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      isPinned: json['is_pinned'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  NewsModel copyWith({
    String? id,
    String? eventId,
    String? authorId,
    String? title,
    String? content,
    bool? isPinned,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NewsModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      isPinned: isPinned ?? this.isPinned,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
