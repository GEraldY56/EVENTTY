import '../models/event_model.dart';
import '../models/registration_model.dart';
import 'event_service.dart';

/// Eventty Bot Service - AI Bot untuk menjawab pertanyaan tentang event
class EventtyBotService {
  final EventService _eventService = EventService();

  /// Process user message and generate bot response
  Future<BotResponse> processMessage(String message, {String? eventId}) async {
    final lowerMessage = message.toLowerCase().trim();
    
    // If eventId provided, get specific event
    EventModel? event;
    if (eventId != null) {
      event = await _eventService.getEventById(eventId);
    }
    
    // Check greeting
    if (_isGreeting(lowerMessage)) {
      return BotResponse(
        canAnswer: true,
        message: 'Halo! 👋 Saya Eventty Bot, asisten virtual OSIS.\n\nSaya bisa membantu Anda dengan informasi tentang event, seperti:\n• Tanggal dan waktu\n• Lokasi\n• Kuota peserta\n• Status pendaftaran\n• Aturan dan persyaratan\n• Sertifikat\n\nSilakan tanyakan apa saja! 😊',
      );
    }
    
    // If specific event, try to answer about it
    if (event != null) {
      final response = _answerAboutEvent(lowerMessage, event);
      if (response != null) return response;
    }
    
    // Try to find event by name in message
    if (_containsEventKeyword(lowerMessage)) {
      final allEvents = await _eventService.getAllEvents();
      for (var evt in allEvents) {
        if (lowerMessage.contains(evt.title.toLowerCase()) ||
            lowerMessage.contains(evt.category.toLowerCase())) {
          final response = _answerAboutEvent(lowerMessage, evt);
          if (response != null) return response;
        }
      }
    }
    
    // General questions
    if (lowerMessage.contains('event') && (lowerMessage.contains('apa') || lowerMessage.contains('ada'))) {
      return await _listAvailableEvents();
    }
    
    // Cannot answer
    return BotResponse(
      canAnswer: false,
      message: 'Maaf, saya belum bisa menjawab pertanyaan ini. 😅\n\nApakah Anda ingin berbicara dengan Admin OSIS?',
      suggestAdmin: true,
    );
  }

  bool _isGreeting(String message) {
    final greetings = ['halo', 'hai', 'hi', 'hello', 'assalamualaikum', 'selamat', 'pagi', 'siang', 'sore', 'malam'];
    return greetings.any((greeting) => message.startsWith(greeting));
  }

  bool _containsEventKeyword(String message) {
    final keywords = ['classmeet', 'basket', 'career', 'seminar', 'workshop', 'kompetisi', 'lomba', 'turnamen'];
    return keywords.any((keyword) => message.contains(keyword));
  }

  BotResponse? _answerAboutEvent(String message, EventModel event) {
    // Tanggal
    if (message.contains('kapan') || message.contains('tanggal') || message.contains('waktu')) {
      return BotResponse(
        canAnswer: true,
        message: '📅 **${event.title}**\n\nTanggal: ${_formatDate(event.date)}\nWaktu: ${event.time}\nLokasi: ${event.location}',
      );
    }
    
    // Lokasi
    if (message.contains('dimana') || message.contains('lokasi') || message.contains('tempat')) {
      return BotResponse(
        canAnswer: true,
        message: '📍 **${event.title}**\n\nLokasi: ${event.location}\nOrganizer: ${event.organizer}',
      );
    }
    
    // Kuota
    if (message.contains('kuota') || message.contains('peserta') || message.contains('kapasitas')) {
      final available = event.capacity - event.registered;
      return BotResponse(
        canAnswer: true,
        message: '👥 **${event.title}**\n\nKuota: ${event.capacity} peserta\nTerdaftar: ${event.registered} peserta\nSisa: $available peserta\n\nStatus: ${event.status == 'open' ? '✅ Pendaftaran Dibuka' : '❌ Pendaftaran Ditutup'}',
      );
    }
    
    // Status pendaftaran
    if (message.contains('status') || message.contains('bisa daftar') || message.contains('masih buka')) {
      return BotResponse(
        canAnswer: true,
        message: '📋 **${event.title}**\n\nStatus Pendaftaran: ${event.status == 'open' ? '✅ DIBUKA' : '❌ DITUTUP'}\n\n${event.status == 'open' ? 'Anda bisa mendaftar sekarang!' : 'Maaf, pendaftaran sudah ditutup.'}',
      );
    }
    
    // Sertifikat
    if (message.contains('sertifikat') || message.contains('surat')) {
      String certInfo;
      if (event.certificateEnabled) {
        switch (event.certificateType) {
          case CertificateType.allParticipants:
            certInfo = '✅ Sertifikat diberikan kepada SEMUA PESERTA yang hadir.';
            break;
          case CertificateType.winners:
            certInfo = '🏆 Sertifikat hanya diberikan kepada PEMENANG.';
            break;
          default:
            certInfo = '❌ Event ini tidak menyediakan sertifikat.';
        }
      } else {
        certInfo = '❌ Event ini tidak menyediakan sertifikat.';
      }
      
      return BotResponse(
        canAnswer: true,
        message: '🎓 **${event.title}**\n\n$certInfo',
      );
    }
    
    // Aturan
    if (message.contains('aturan') || message.contains('syarat') || message.contains('ketentuan')) {
      return BotResponse(
        canAnswer: true,
        message: '📜 **${event.title}**\n\nUntuk melihat aturan dan persyaratan lengkap, silakan:\n1. Buka Event Detail\n2. Klik "Aturan & Persyaratan"\n\nAtau tanyakan langsung ke Admin OSIS untuk penjelasan lebih detail.',
      );
    }
    
    // Cara daftar
    if (message.contains('cara daftar') || message.contains('bagaimana daftar') || message.contains('daftar')) {
      return BotResponse(
        canAnswer: true,
        message: '📝 **Cara Mendaftar ${event.title}**\n\n1. Buka Event Detail\n2. Klik tombol "Daftar Sekarang"\n3. Isi formulir pendaftaran\n4. Submit\n\nJenis Pendaftaran: ${event.registrationType == RegistrationType.individual ? 'INDIVIDUAL' : 'TEAM'}',
      );
    }
    
    return null;
  }

  Future<BotResponse> _listAvailableEvents() async {
    final events = await _eventService.getAllEvents();
    final openEvents = events.where((e) => e.status == 'open').toList();
    
    if (openEvents.isEmpty) {
      return BotResponse(
        canAnswer: true,
        message: '📅 Saat ini belum ada event yang dibuka.\n\nPantau terus halaman Events untuk update terbaru!',
      );
    }
    
    String message = '📅 **Event yang Tersedia:**\n\n';
    for (var event in openEvents) {
      message += '• ${event.title}\n  ${_formatDate(event.date)} | ${event.location}\n\n';
    }
    message += 'Tanyakan detail event yang ingin Anda ketahui!';
    
    return BotResponse(
      canAnswer: true,
      message: message,
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Bot Response Model
class BotResponse {
  final bool canAnswer;
  final String message;
  final bool suggestAdmin;

  BotResponse({
    required this.canAnswer,
    required this.message,
    this.suggestAdmin = false,
  });
}
