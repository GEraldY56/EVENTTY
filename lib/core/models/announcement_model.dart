class AnnouncementModel {
  final String id;
  final String title;
  final String content;
  final String? eventId;
  final String? category;
  final String? priority;
  final String author;
  final String? authorId;
  final bool isPinned;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Joined data from profiles table
  final String? authorFullName;
  final String? authorAvatarUrl;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    this.eventId,
    this.category,
    this.priority,
    required this.author,
    this.authorId,
    this.isPinned = false,
    this.isPublished = true,
    required this.createdAt,
    required this.updatedAt,
    this.authorFullName,
    this.authorAvatarUrl,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    // Handle author_profile from join
    final authorProfile = json['author_profile'];
    
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      eventId: json['event_id'] as String?,
      category: json['category'] as String? ?? 'General',
      priority: json['priority'] as String? ?? 'medium',
      author: json['author'] as String,
      authorId: json['author_id'] as String?,
      isPinned: json['is_pinned'] as bool? ?? false,
      isPublished: json['is_published'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorFullName: authorProfile != null ? authorProfile['full_name'] as String? : null,
      authorAvatarUrl: authorProfile != null ? authorProfile['avatar_url'] as String? : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'event_id': eventId,
      'category': category,
      'priority': priority,
      'author': author,
      'author_id': authorId,
      'is_pinned': isPinned,
      'is_published': isPublished,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? content,
    String? eventId,
    String? category,
    String? priority,
    String? author,
    String? authorId,
    bool? isPinned,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorFullName,
    String? authorAvatarUrl,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      eventId: eventId ?? this.eventId,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      isPinned: isPinned ?? this.isPinned,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorFullName: authorFullName ?? this.authorFullName,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
    );
  }

  // Helper getters
  String get displayAuthor => authorFullName ?? author;
  
  String get statusText => isPublished ? 'Published' : 'Draft';
  
  String get priorityText {
    switch (priority?.toLowerCase()) {
      case 'high':
        return 'High Priority';
      case 'medium':
        return 'Medium Priority';
      case 'low':
        return 'Low Priority';
      default:
        return 'Normal';
    }
  }

  String getTimeAgo() {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
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
}
