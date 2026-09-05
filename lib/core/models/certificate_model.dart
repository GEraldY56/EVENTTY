import 'package:intl/intl.dart';

/// Certificate Model
class CertificateModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventCategory;
  final String participantId;
  final String participantName;
  final String participantNis;
  final String templateId;
  final DateTime eventDate;
  final DateTime issuedDate;
  final String certificateNumber;
  final String signedBy;
  final String? additionalInfo;
  final String? achievement; // For winners: Juara 1, 2, 3, or Peserta

  // Alias for consistency with CertificateService
  String get studentId => participantId;
  String get studentName => participantName;

  CertificateModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.eventCategory,
    required this.participantId,
    required this.participantName,
    required this.participantNis,
    required this.templateId,
    DateTime? eventDate,
    DateTime? issuedDate,
    required this.certificateNumber,
    this.signedBy = 'OSIS SMKN 20 Jakarta',
    this.additionalInfo,
    this.achievement,
  })  : eventDate = eventDate ?? DateTime.now(),
        issuedDate = issuedDate ?? DateTime.now();

  String get formattedEventDate => DateFormat('d MMMM yyyy').format(eventDate);
  
  String get formattedIssuedDate => DateFormat('d MMMM yyyy').format(issuedDate);
  
  String get monthYear => DateFormat('MMMM yyyy').format(issuedDate);

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'eventCategory': eventCategory,
        'participantId': participantId,
        'participantName': participantName,
        'participantNis': participantNis,
        'templateId': templateId,
        'eventDate': eventDate.toIso8601String(),
        'issuedDate': issuedDate.toIso8601String(),
        'certificateNumber': certificateNumber,
        'signedBy': signedBy,
        'additionalInfo': additionalInfo,
        'achievement': achievement,
      };

  factory CertificateModel.fromJson(Map<String, dynamic> json) => CertificateModel(
        id: json['id'] as String,
        eventId: json['eventId'] as String,
        eventTitle: json['eventTitle'] as String,
        eventCategory: json['eventCategory'] as String? ?? 'Event',
        participantId: json['participantId'] as String,
        participantName: json['participantName'] as String,
        participantNis: json['participantNis'] as String,
        templateId: json['templateId'] as String,
        eventDate: json['eventDate'] != null
            ? DateTime.parse(json['eventDate'] as String)
            : DateTime.now(),
        issuedDate: json['issuedDate'] != null
            ? DateTime.parse(json['issuedDate'] as String)
            : DateTime.now(),
        certificateNumber: json['certificateNumber'] as String,
        signedBy: json['signedBy'] as String? ?? 'OSIS SMKN 20 Jakarta',
        additionalInfo: json['additionalInfo'] as String?,
        achievement: json['achievement'] as String?,
      );

  CertificateModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? eventCategory,
    String? participantId,
    String? participantName,
    String? participantNis,
    String? templateId,
    DateTime? eventDate,
    DateTime? issuedDate,
    String? certificateNumber,
    String? signedBy,
    String? additionalInfo,
    String? achievement,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventCategory: eventCategory ?? this.eventCategory,
      participantId: participantId ?? this.participantId,
      participantName: participantName ?? this.participantName,
      participantNis: participantNis ?? this.participantNis,
      templateId: templateId ?? this.templateId,
      eventDate: eventDate ?? this.eventDate,
      issuedDate: issuedDate ?? this.issuedDate,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      signedBy: signedBy ?? this.signedBy,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      achievement: achievement ?? this.achievement,
    );
  }
}

/// Certificate Template Model
class CertificateTemplateModel {
  final String id;
  final String name;
  final String description;
  final CertificateLayoutType layoutType;
  final String backgroundColor;
  final String borderColor;
  final String textColor;
  final String accentColor;
  final bool hasLogo;
  final bool hasBorder;
  final bool hasSignature;
  final DateTime createdAt;
  final DateTime? updatedAt;

  CertificateTemplateModel({
    required this.id,
    required this.name,
    required this.description,
    this.layoutType = CertificateLayoutType.modern,
    this.backgroundColor = '#FFFFFF',
    this.borderColor = '#6B4F3A',
    this.textColor = '#1A1A1A',
    this.accentColor = '#C89B6D',
    this.hasLogo = true,
    this.hasBorder = true,
    this.hasSignature = true,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'layoutType': layoutType.name,
        'backgroundColor': backgroundColor,
        'borderColor': borderColor,
        'textColor': textColor,
        'accentColor': accentColor,
        'hasLogo': hasLogo,
        'hasBorder': hasBorder,
        'hasSignature': hasSignature,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory CertificateTemplateModel.fromJson(Map<String, dynamic> json) =>
      CertificateTemplateModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        layoutType: CertificateLayoutType.values.firstWhere(
          (e) => e.name == json['layoutType'],
          orElse: () => CertificateLayoutType.modern,
        ),
        backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
        borderColor: json['borderColor'] as String? ?? '#6B4F3A',
        textColor: json['textColor'] as String? ?? '#1A1A1A',
        accentColor: json['accentColor'] as String? ?? '#C89B6D',
        hasLogo: json['hasLogo'] as bool? ?? true,
        hasBorder: json['hasBorder'] as bool? ?? true,
        hasSignature: json['hasSignature'] as bool? ?? true,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}

enum CertificateLayoutType {
  modern,
  classic,
  elegant,
  minimalist,
}

extension CertificateLayoutTypeExtension on CertificateLayoutType {
  String get displayName {
    switch (this) {
      case CertificateLayoutType.modern:
        return 'Modern';
      case CertificateLayoutType.classic:
        return 'Classic';
      case CertificateLayoutType.elegant:
        return 'Elegant';
      case CertificateLayoutType.minimalist:
        return 'Minimalist';
    }
  }
}
