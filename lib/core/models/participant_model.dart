/// Participant Model
class ParticipantModel {
  final String id;
  final String eventId;
  final String studentId;
  final String studentName;
  final String studentNis;
  final String studentClass;
  final String email;
  final String phone;
  final DateTime registrationDate;
  final ParticipantStatus status;
  final bool hasCertificate;
  final String? certificateId;
  final String? notes;
  final ParticipantPlacement? placement; // 1st, 2nd, 3rd, or participant

  ParticipantModel({
    required this.id,
    required this.eventId,
    required this.studentId,
    required this.studentName,
    required this.studentNis,
    required this.studentClass,
    required this.email,
    required this.phone,
    DateTime? registrationDate,
    this.status = ParticipantStatus.pending,
    this.hasCertificate = false,
    this.certificateId,
    this.notes,
    this.placement,
  }) : registrationDate = registrationDate ?? DateTime.now();

  bool get isPending => status == ParticipantStatus.pending;
  bool get isApproved => status == ParticipantStatus.approved;
  bool get isRejected => status == ParticipantStatus.rejected;
  bool get isAttended => status == ParticipantStatus.attended;
  bool get isWinner => placement != null && 
      (placement == ParticipantPlacement.first || 
       placement == ParticipantPlacement.second || 
       placement == ParticipantPlacement.third);

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'studentId': studentId,
        'studentName': studentName,
        'studentNis': studentNis,
        'studentClass': studentClass,
        'email': email,
        'phone': phone,
        'registrationDate': registrationDate.toIso8601String(),
        'status': status.name,
        'hasCertificate': hasCertificate,
        'certificateId': certificateId,
        'notes': notes,
        'placement': placement?.name,
      };

  factory ParticipantModel.fromJson(Map<String, dynamic> json) => ParticipantModel(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        studentId: json['studentId'] as String,
        studentName: json['studentName'] as String,
        studentNis: json['studentNis'] as String,
        studentClass: json['studentClass'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        registrationDate: DateTime.parse(json['registrationDate'] as String),
        status: ParticipantStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => ParticipantStatus.pending,
        ),
        hasCertificate: json['hasCertificate'] as bool? ?? false,
        certificateId: json['certificateId'] as String?,
        notes: json['notes'] as String?,
        placement: json['placement'] != null
            ? ParticipantPlacement.values.firstWhere(
                (e) => e.name == json['placement'],
                orElse: () => ParticipantPlacement.participant,
              )
            : null,
      );

  ParticipantModel copyWith({
    String? id,
    String? eventId,
    String? studentId,
    String? studentName,
    String? studentNis,
    String? studentClass,
    String? email,
    String? phone,
    DateTime? registrationDate,
    ParticipantStatus? status,
    bool? hasCertificate,
    String? certificateId,
    String? notes,
    ParticipantPlacement? placement,
  }) {
    return ParticipantModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentNis: studentNis ?? this.studentNis,
      studentClass: studentClass ?? this.studentClass,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      certificateId: certificateId ?? this.certificateId,
      notes: notes ?? this.notes,
      placement: placement ?? this.placement,
    );
  }
}

enum ParticipantPlacement {
  first,       // Juara 1
  second,      // Juara 2
  third,       // Juara 3
  participant, // Peserta biasa
}

enum ParticipantStatus {
  pending,
  approved,
  rejected,
  attended,
}

extension ParticipantStatusExtension on ParticipantStatus {
  String get displayName {
    switch (this) {
      case ParticipantStatus.pending:
        return 'Pending';
      case ParticipantStatus.approved:
        return 'Approved';
      case ParticipantStatus.rejected:
        return 'Rejected';
      case ParticipantStatus.attended:
        return 'Attended';
    }
  }
}

extension ParticipantPlacementExtension on ParticipantPlacement {
  String get displayName {
    switch (this) {
      case ParticipantPlacement.first:
        return 'Juara 1';
      case ParticipantPlacement.second:
        return 'Juara 2';
      case ParticipantPlacement.third:
        return 'Juara 3';
      case ParticipantPlacement.participant:
        return 'Peserta';
    }
  }
}
