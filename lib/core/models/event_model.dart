import 'package:intl/intl.dart';
import 'registration_model.dart' show RegistrationType;

/// Certificate Type Enum
enum CertificateType {
  none,              // Tidak ada sertifikat
  allParticipants,   // Semua peserta
  winners,           // Hanya pemenang
}

/// Event Model
class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime date;
  final String time;
  final String location;
  final String organizer;
  final int capacity;
  final int registered;
  final String status;
  final String? imageUrl;
  final bool isFeatured;
  final bool isPopular;
  final bool isPublished;
  final bool isRegistrationOpen;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime? registrationDeadline;
  
  // Certificate Configuration
  final bool certificateEnabled;
  final CertificateType certificateType;
  final int? minimumAttendance; // Persentase kehadiran minimum (untuk all_participants)
  
  // Registration Configuration
  final RegistrationType registrationType; // individual atau team

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.location,
    required this.organizer,
    required this.capacity,
    this.registered = 0,
    this.status = 'open',
    this.imageUrl,
    this.isFeatured = false,
    this.isPopular = false,
    this.isPublished = false,
    this.isRegistrationOpen = true,
    this.tags = const [],
    DateTime? createdAt,
    this.registrationDeadline,
    this.certificateEnabled = false,
    this.certificateType = CertificateType.none,
    this.minimumAttendance,
    this.registrationType = RegistrationType.individual,
  }) : createdAt = createdAt ?? DateTime.now();

  String get formattedDate => DateFormat('d MMMM yyyy').format(date);
  
  String get shortDate => DateFormat('d MMM').format(date);
  
  bool get isOpen => status.toLowerCase() == 'open';
  
  bool get isOngoing => status.toLowerCase() == 'ongoing';
  
  bool get isClosed => status.toLowerCase() == 'closed';
  
  bool get isFull => registered >= capacity;
  
  int get availableSlots => capacity - registered;
  
  double get registrationPercentage => (registered / capacity) * 100;
  
  // Certificate helpers
  bool get hasCertificate => certificateEnabled && certificateType != CertificateType.none;
  
  bool get isCompetition => category.toLowerCase().contains('competition') || 
                            category.toLowerCase().contains('tournament') ||
                            certificateType == CertificateType.winners;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'date': date.toIso8601String(),
        'time': time,
        'location': location,
        'organizer': organizer,
        'capacity': capacity,
        'registered': registered,
        'status': status,
        'imageUrl': imageUrl,
        'isFeatured': isFeatured,
        'isPopular': isPopular,
        'isPublished': isPublished,
        'isRegistrationOpen': isRegistrationOpen,
        'tags': tags,
        'createdAt': createdAt.toIso8601String(),
        'registrationDeadline': registrationDeadline?.toIso8601String(),
        'certificateEnabled': certificateEnabled,
        'certificateType': certificateType.name,
        'minimumAttendance': minimumAttendance,
        'registrationType': registrationType.name,
      };

  factory EventModel.fromJson(Map<String, dynamic> json) {
    CertificateType certType = CertificateType.none;
    if (json['certificateType'] != null) {
      try {
        certType = CertificateType.values.firstWhere(
          (e) => e.name == json['certificateType'],
          orElse: () => CertificateType.none,
        );
      } catch (e) {
        certType = CertificateType.none;
      }
    }
    
    RegistrationType regType = RegistrationType.individual;
    if (json['registrationType'] != null) {
      try {
        regType = RegistrationType.values.firstWhere(
          (e) => e.name == json['registrationType'],
          orElse: () => RegistrationType.individual,
        );
      } catch (e) {
        regType = RegistrationType.individual;
      }
    }
    
    // DEBUG: Safe tags parsing with error handling
    List<String> parsedTags = [];
    try {
      if (json['tags'] != null) {
        final tagsData = json['tags'];
        if (tagsData is List) {
          parsedTags = tagsData.map((e) => e.toString()).toList();
        }
      }
    } catch (e) {
      print('DEBUG EventModel.fromJson tags error for event ${json['id']}: $e');
      print('DEBUG tags type: ${json['tags'].runtimeType}');
      print('DEBUG tags value: ${json['tags']}');
      parsedTags = [];
    }
    
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      location: json['location'] as String,
      organizer: json['organizer'] as String,
      capacity: json['capacity'] as int,
      registered: json['registered'] as int? ?? 0,
      status: json['status'] as String? ?? 'open',
      imageUrl: json['imageUrl'] as String?,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isPopular: json['isPopular'] as bool? ?? false,
      isPublished: json['isPublished'] as bool? ?? false,
      isRegistrationOpen: json['isRegistrationOpen'] as bool? ?? true,
      tags: parsedTags,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      registrationDeadline: json['registrationDeadline'] != null
          ? DateTime.parse(json['registrationDeadline'] as String)
          : null,
      certificateEnabled: json['certificateEnabled'] as bool? ?? false,
      certificateType: certType,
      minimumAttendance: json['minimumAttendance'] as int?,
      registrationType: regType,
    );
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? date,
    String? time,
    String? location,
    String? organizer,
    int? capacity,
    int? registered,
    String? status,
    String? imageUrl,
    bool? isFeatured,
    bool? isPopular,
    bool? isPublished,
    bool? isRegistrationOpen,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? registrationDeadline,
    bool? certificateEnabled,
    CertificateType? certificateType,
    int? minimumAttendance,
    RegistrationType? registrationType,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      organizer: organizer ?? this.organizer,
      capacity: capacity ?? this.capacity,
      registered: registered ?? this.registered,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      isPopular: isPopular ?? this.isPopular,
      isPublished: isPublished ?? this.isPublished,
      isRegistrationOpen: isRegistrationOpen ?? this.isRegistrationOpen,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      registrationDeadline: registrationDeadline ?? this.registrationDeadline,
      certificateEnabled: certificateEnabled ?? this.certificateEnabled,
      certificateType: certificateType ?? this.certificateType,
      minimumAttendance: minimumAttendance ?? this.minimumAttendance,
      registrationType: registrationType ?? this.registrationType,
    );
  }
}
