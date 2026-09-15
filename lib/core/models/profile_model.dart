/// Profile Model - Maps to profiles table in Database V3.2
class ProfileModel {
  final String id;
  final String email;
  final String fullName;
  final String role; // 'student' or 'admin'
  final String? avatarUrl;
  final String? phone;
  final String? nis; // 5 digit for students
  final String? major; // Jurusan: RPL, TKJ, etc
  final int? semester; // 1-6
  final DateTime createdAt;
  final DateTime updatedAt;

  ProfileModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.avatarUrl,
    this.phone,
    this.nis,
    this.major,
    this.semester,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Helper getters
  bool get isStudent => role == 'student';
  bool get isAdmin => role == 'admin';
  String get displayName => fullName;
  String get initials {
    final names = fullName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return fullName.substring(0, 1).toUpperCase();
  }

  /// Convert to JSON for Supabase (snake_case)
  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'role': role,
        'avatar_url': avatarUrl,
        'phone': phone,
        'nis': nis,
        'major': major,
        'semester': semester,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };

  /// Create from JSON from Supabase (snake_case)
  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        role: json['role'] as String,
        avatarUrl: json['avatar_url'] as String?,
        phone: json['phone'] as String?,
        nis: json['nis'] as String?,
        major: json['major'] as String?,
        semester: json['semester'] as int?,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
            : DateTime.now(),
      );

  ProfileModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? avatarUrl,
    String? phone,
    String? nis,
    String? major,
    int? semester,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      nis: nis ?? this.nis,
      major: major ?? this.major,
      semester: semester ?? this.semester,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
