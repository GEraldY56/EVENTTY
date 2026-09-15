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
        'event_id': eventId,
        'event_title': eventTitle,
        'event_category': eventCategory,
        'participant_id': participantId,
        'participant_name': participantName,
        'participant_nis': participantNis,
        'template_id': templateId,
        'event_date': eventDate.toIso8601String(),
        'issued_date': issuedDate.toIso8601String(),
        'certificate_number': certificateNumber,
        'signed_by': signedBy,
        'additional_info': additionalInfo,
        'achievement': achievement,
      };

  factory CertificateModel.fromJson(Map<String, dynamic> json) => CertificateModel(
        id: json['id'] as String,
        eventId: json['event_id'] as String,
        eventTitle: json['event_title'] as String,
        eventCategory: json['event_category'] as String? ?? 'Event',
        participantId: json['participant_id'] as String,
        participantName: json['participant_name'] as String,
        participantNis: json['participant_nis'] as String,
        templateId: json['template_id'] as String,
        eventDate: json['event_date'] != null
            ? DateTime.parse(json['event_date'] as String)
            : DateTime.now(),
        issuedDate: json['issued_date'] != null
            ? DateTime.parse(json['issued_date'] as String)
            : DateTime.now(),
        certificateNumber: json['certificate_number'] as String,
        signedBy: json['signed_by'] as String? ?? 'OSIS SMKN 20 Jakarta',
        additionalInfo: json['additional_info'] as String?,
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
        'layout_type': layoutType.name,
        'background_color': backgroundColor,
        'border_color': borderColor,
        'text_color': textColor,
        'accent_color': accentColor,
        'has_logo': hasLogo,
        'has_border': hasBorder,
        'has_signature': hasSignature,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  factory CertificateTemplateModel.fromJson(Map<String, dynamic> json) =>
      CertificateTemplateModel(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String,
        layoutType: CertificateLayoutType.values.firstWhere(
          (e) => e.name == json['layout_type'],
          orElse: () => CertificateLayoutType.modern,
        ),
        backgroundColor: json['background_color'] as String? ?? '#FFFFFF',
        borderColor: json['border_color'] as String? ?? '#6B4F3A',
        textColor: json['text_color'] as String? ?? '#1A1A1A',
        accentColor: json['accent_color'] as String? ?? '#C89B6D',
        hasLogo: json['has_logo'] as bool? ?? true,
        hasBorder: json['has_border'] as bool? ?? true,
        hasSignature: json['has_signature'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: json['updated_at'] != null
            ? DateTime.parse(json['updated_at'] as String)
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
