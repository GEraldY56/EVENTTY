/// News Model
class NewsModel {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final NewsCategory category;
  final String authorId;
  final String authorName;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final bool isPublished;
  final bool isImportant;
  final String? imageUrl;
  final NewsTarget target;
  final String? targetEventId; // Jika target = EVENT_PARTICIPANTS
  final int views;
  final List<String> tags;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.category,
    required this.authorId,
    required this.authorName,
    DateTime? createdAt,
    this.publishedAt,
    this.updatedAt,
    this.isPublished = false,
    this.isImportant = false,
    this.imageUrl,
    this.target = NewsTarget.allStudents,
    this.targetEventId,
    this.views = 0,
    this.tags = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  String get readTime {
    final words = content.split(' ').length;
    final minutes = (words / 200).ceil();
    return '$minutes min read';
  }

  String get timeAgo {
    final now = DateTime.now();
    final date = publishedAt ?? createdAt;
    final difference = now.difference(date);

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'excerpt': excerpt,
        'category': category.name,
        'authorId': authorId,
        'authorName': authorName,
        'createdAt': createdAt.toIso8601String(),
        'publishedAt': publishedAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'isPublished': isPublished,
        'isImportant': isImportant,
        'imageUrl': imageUrl,
        'target': target.name,
        'targetEventId': targetEventId,
        'views': views,
        'tags': tags,
      };

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // DEBUG: Safe tags parsing
    List<String> parsedTags = [];
    try {
      if (json['tags'] != null) {
        final tagsData = json['tags'];
        if (tagsData is List) {
          parsedTags = tagsData.map((e) => e.toString()).toList();
        }
      }
    } catch (e) {
      print('DEBUG NewsModel.fromJson tags error for news ${json['id']}: $e');
      print('DEBUG tags type: ${json['tags'].runtimeType}');
      parsedTags = [];
    }
    
    return NewsModel(
        id: json['id'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        excerpt: json['excerpt'] as String,
        category: NewsCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => NewsCategory.announcement,
        ),
        authorId: json['authorId'] as String,
        authorName: json['authorName'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        publishedAt: json['publishedAt'] != null
            ? DateTime.parse(json['publishedAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        isPublished: json['isPublished'] as bool? ?? false,
        isImportant: json['isImportant'] as bool? ?? false,
        imageUrl: json['imageUrl'] as String?,
        target: NewsTarget.values.firstWhere(
          (e) => e.name == json['target'],
          orElse: () => NewsTarget.allStudents,
        ),
        targetEventId: json['targetEventId'] as String?,
        views: json['views'] as int? ?? 0,
        tags: parsedTags,
      );
  }

  NewsModel copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    NewsCategory? category,
    String? authorId,
    String? authorName,
    DateTime? createdAt,
    DateTime? publishedAt,
    DateTime? updatedAt,
    bool? isPublished,
    bool? isImportant,
    String? imageUrl,
    NewsTarget? target,
    String? targetEventId,
    int? views,
    List<String>? tags,
  }) {
    return NewsModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      createdAt: createdAt ?? this.createdAt,
      publishedAt: publishedAt ?? this.publishedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublished: isPublished ?? this.isPublished,
      isImportant: isImportant ?? this.isImportant,
      imageUrl: imageUrl ?? this.imageUrl,
      target: target ?? this.target,
      targetEventId: targetEventId ?? this.targetEventId,
      views: views ?? this.views,
      tags: tags ?? this.tags,
    );
  }
}

enum NewsCategory {
  event,
  academic,
  achievement,
  announcement,
  general,
}

enum NewsTarget {
  allStudents,         // Semua student
  eventParticipants,   // Peserta event tertentu
}

extension NewsCategoryExtension on NewsCategory {
  String get displayName {
    switch (this) {
      case NewsCategory.event:
        return 'Event';
      case NewsCategory.academic:
        return 'Academic';
      case NewsCategory.achievement:
        return 'Achievement';
      case NewsCategory.announcement:
        return 'Announcement';
      case NewsCategory.general:
        return 'General';
    }
  }
}

extension NewsTargetExtension on NewsTarget {
  String get displayName {
    switch (this) {
      case NewsTarget.allStudents:
        return 'All Students';
      case NewsTarget.eventParticipants:
        return 'Event Participants';
    }
  }
}
