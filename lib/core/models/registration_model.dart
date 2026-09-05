/// Registration Type Enum
enum RegistrationType {
  individual,  // Pendaftaran individ
  team,        // Pendaftaran team/group
}

/// Registration Status Enum
enum RegistrationStatus {
  pending,    // Menunggu konfirmasi
  confirmed,  // Dikonfirmasi
  attended,   // Sudah hadir
  cancelled,  // Dibatalkan
}

/// Team Member Model
class TeamMember {
  final String studentId;
  final String name;
  final String nis;
  final String kelas;

  TeamMember({
    required this.studentId,
    required this.name,
    required this.nis,
    required this.kelas,
  });

  Map<String, dynamic> toJson() => {
        'studentId': studentId,
        'name': name,
        'nis': nis,
        'kelas': kelas,
      };

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        studentId: json['studentId'] as String,
        name: json['name'] as String,
        nis: json['nis'] as String,
        kelas: json['kelas'] as String,
      );
}

/// Registration Model
/// Mendukung INDIVIDUAL dan TEAM registration
class RegistrationModel {
  final String id;
  final String eventId;
  final RegistrationType type;
  
  // INDIVIDUAL fields
  final String? userId;           // For individual
  final String? userName;         // For individual
  
  // TEAM fields
  final String? teamName;         // For team (e.g., "XI RPL 1" or "Team Basket A")
  final String? className;        // For team (e.g., "XI RPL 1")
  final String? leaderId;         // Team leader student ID
  final String? leaderName;       // Team leader name
  final List<TeamMember>? members; // All team members including leader
  
  // Common fields
  final Map<String, dynamic> formData;
  final DateTime registrationDate;
  RegistrationStatus status;

  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.type,
    this.userId,
    this.userName,
    this.teamName,
    this.className,
    this.leaderId,
    this.leaderName,
    this.members,
    required this.formData,
    DateTime? registrationDate,
    this.status = RegistrationStatus.pending,
  }) : registrationDate = registrationDate ?? DateTime.now();

  // Helper getters
  bool get isIndividual => type == RegistrationType.individual;
  bool get isTeam => type == RegistrationType.team;
  int get memberCount => members?.length ?? 1;
  
  // Get all student IDs (for checking duplicates and My Events)
  List<String> get allStudentIds {
    if (isIndividual) {
      return userId != null ? [userId!] : [];
    } else {
      return members?.map((m) => m.studentId).toList() ?? [];
    }
  }
  
  // Check if a student is part of this registration
  bool includesStudent(String studentId) {
    return allStudentIds.contains(studentId);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'type': type.name,
        'userId': userId,
        'userName': userName,
        'teamName': teamName,
        'className': className,
        'leaderId': leaderId,
        'leaderName': leaderName,
        'members': members?.map((m) => m.toJson()).toList(),
        'formData': formData,
        'registrationDate': registrationDate.toIso8601String(),
        'status': status.name,
      };

  factory RegistrationModel.fromJson(Map<String, dynamic> json) {
    return RegistrationModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      type: RegistrationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => RegistrationType.individual,
      ),
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      teamName: json['teamName'] as String?,
      className: json['className'] as String?,
      leaderId: json['leaderId'] as String?,
      leaderName: json['leaderName'] as String?,
      members: json['members'] != null
          ? (json['members'] as List).map((m) => TeamMember.fromJson(m as Map<String, dynamic>)).toList()
          : null,
      formData: json['formData'] as Map<String, dynamic>,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      status: RegistrationStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RegistrationStatus.pending,
      ),
    );
  }

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    RegistrationType? type,
    String? userId,
    String? userName,
    String? teamName,
    String? className,
    String? leaderId,
    String? leaderName,
    List<TeamMember>? members,
    Map<String, dynamic>? formData,
    DateTime? registrationDate,
    RegistrationStatus? status,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      teamName: teamName ?? this.teamName,
      className: className ?? this.className,
      leaderId: leaderId ?? this.leaderId,
      leaderName: leaderName ?? this.leaderName,
      members: members ?? this.members,
      formData: formData ?? this.formData,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
    );
  }
}

/// Registration Result Model
class RegistrationResult {
  final bool success;
  final String message;
  final String? registrationId;

  RegistrationResult({
    required this.success,
    required this.message,
    this.registrationId,
  });
}

extension RegistrationStatusExtension on RegistrationStatus {
  String get displayName {
    switch (this) {
      case RegistrationStatus.pending:
        return 'Menunggu Konfirmasi';
      case RegistrationStatus.confirmed:
        return 'Dikonfirmasi';
      case RegistrationStatus.attended:
        return 'Sudah Hadir';
      case RegistrationStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

extension RegistrationTypeExtension on RegistrationType {
  String get displayName {
    switch (this) {
      case RegistrationType.individual:
        return 'Individual';
      case RegistrationType.team:
        return 'Team';
    }
  }
}
