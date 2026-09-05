import 'event_service.dart';

/// AI Chat Service - Smart chatbot yang bisa memahami konteks dan menjawab pertanyaan tentang event
class AiChatService {
  final EventService _eventService = EventService();

  /// Process user message and generate intelligent response
  Future<String> processMessage(String userMessage) async {
    final message = userMessage.toLowerCase().trim();

    // Detect intent
    final intent = _detectIntent(message);

    switch (intent) {
      case ChatIntent.greeting:
        return _generateGreeting();
      
      case ChatIntent.askAboutEvent:
        return await _handleEventQuestion(message);
      
      case ChatIntent.askEventList:
        return await _handleEventListQuestion();
      
      case ChatIntent.askRegistration:
        return await _handleRegistrationQuestion(message);
      
      case ChatIntent.askDeadline:
        return await _handleDeadlineQuestion(message);
      
      case ChatIntent.askLocation:
        return await _handleLocationQuestion(message);
      
      case ChatIntent.askCategory:
        return await _handleCategoryQuestion(message);
      
      case ChatIntent.thankYou:
        return _generateThankYouResponse();
      
      case ChatIntent.help:
        return _generateHelpResponse();
      
      default:
        return _generateDefaultResponse(message);
    }
  }

  /// Detect user intent from message
  ChatIntent _detectIntent(String message) {
    // Greeting patterns
    if (_containsAny(message, ['halo', 'hai', 'hi', 'hello', 'selamat'])) {
      return ChatIntent.greeting;
    }

    // Thank you patterns
    if (_containsAny(message, ['terima kasih', 'thanks', 'makasih', 'oke', 'ok', 'siap'])) {
      return ChatIntent.thankYou;
    }

    // Help patterns
    if (_containsAny(message, ['bantuan', 'help', 'bantu', 'bisa bantu'])) {
      return ChatIntent.help;
    }

    // Event list patterns
    if (_containsAny(message, ['event apa saja', 'ada event apa', 'daftar event', 'list event', 'event tersedia', 'event yang ada'])) {
      return ChatIntent.askEventList;
    }

    // Registration patterns
    if (_containsAny(message, ['cara daftar', 'daftar', 'registrasi', 'pendaftaran', 'register', 'ikut event'])) {
      return ChatIntent.askRegistration;
    }

    // Deadline patterns
    if (_containsAny(message, ['deadline', 'batas waktu', 'kapan tutup', 'terakhir daftar', 'sampai kapan'])) {
      return ChatIntent.askDeadline;
    }

    // Location patterns
    if (_containsAny(message, ['dimana', 'lokasi', 'tempat', 'venue', 'di mana'])) {
      return ChatIntent.askLocation;
    }

    // Category patterns
    if (_containsAny(message, ['kategori', 'jenis', 'tipe event', 'macam'])) {
      return ChatIntent.askCategory;
    }

    // Specific event question
    if (_containsAny(message, ['basket', 'classmeet', 'career', 'workshop', 'seminar', 'kompetisi', 'event', 'lomba'])) {
      return ChatIntent.askAboutEvent;
    }

    return ChatIntent.unknown;
  }

  /// Check if message contains any of the keywords
  bool _containsAny(String message, List<String> keywords) {
    return keywords.any((keyword) => message.contains(keyword));
  }

  /// Extract event name from message
  String? _extractEventName(String message) {
    final events = _eventService.getMockEvents();
    
    for (final event in events) {
      final eventName = event['title']!.toLowerCase();
      final keywords = eventName.split(' ');
      
      // Check if message contains any keyword from event name
      for (final keyword in keywords) {
        if (message.contains(keyword.toLowerCase())) {
          return event['id'];
        }
      }
    }
    
    // Check for common event nicknames
    if (message.contains('basket')) return 'event_0';
    if (message.contains('classmeet') || message.contains('class meet')) return 'event_1';
    if (message.contains('career') || message.contains('karir')) return 'event_2';
    
    return null;
  }

  /// Generate greeting response
  String _generateGreeting() {
    final greetings = [
      'Halo! 👋 Selamat datang di EVENTTY. Ada yang bisa saya bantu?',
      'Hai! Saya asisten virtual EVENTTY. Mau tanya tentang event apa nih? 😊',
      'Halo! Saya siap membantu Anda dengan informasi event di SMKN 20 Jakarta. Silakan tanya! 🎉',
    ];
    greetings.shuffle();
    return greetings.first;
  }

  /// Generate thank you response
  String _generateThankYouResponse() {
    final responses = [
      'Sama-sama! Senang bisa membantu 😊',
      'Terima kasih kembali! Jangan ragu untuk bertanya lagi ya! 👍',
      'Siap! Semoga sukses di eventnya! 🎉',
    ];
    responses.shuffle();
    return responses.first;
  }

  /// Generate help response
  String _generateHelpResponse() {
    return '''Saya bisa membantu Anda dengan:

📅 **Informasi Event**
- Daftar event yang tersedia
- Detail event tertentu
- Jadwal dan waktu

📝 **Pendaftaran**
- Cara mendaftar event
- Syarat dan ketentuan

📍 **Lokasi & Tempat**
- Tempat pelaksanaan event

⏰ **Deadline**
- Batas waktu pendaftaran

Silakan tanya apa saja tentang event! 😊''';
  }

  /// Handle event-specific question
  Future<String> _handleEventQuestion(String message) async {
    final eventId = _extractEventName(message);
    
    if (eventId == null) {
      return 'Maaf, saya tidak menemukan event yang Anda maksud. Bisa sebutkan nama eventnya dengan lebih jelas? 🤔';
    }

    final event = _eventService.getEventByIdSync(eventId);
    
    if (event == null) {
      return 'Maaf, event tidak ditemukan. Coba lihat daftar event yang tersedia dengan mengetik "event apa saja"';
    }

    // Generate comprehensive event info
    return '''📌 **${event['title']}**

📅 **Waktu**: ${event['date']} | ${event['time']}
📍 **Lokasi**: ${event['location']}
👥 **Kategori**: ${event['category']}

📝 **Deskripsi**:
${event['description']}

✅ **Status**: ${event['participants']}/${event['maxParticipants']} peserta terdaftar
⏰ **Deadline**: ${event['registrationDeadline']}

Mau daftar? Klik tombol "Daftar" di halaman event! 🎉''';
  }

  /// Handle event list question
  Future<String> _handleEventListQuestion() async {
    final events = _eventService.getMockEvents();
    
    if (events.isEmpty) {
      return 'Saat ini belum ada event yang tersedia. Pantau terus untuk update terbaru! 📢';
    }

    final eventList = StringBuffer('📋 **Event yang Tersedia**:\n\n');
    
    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      eventList.writeln('${i + 1}. **${event['title']}**');
      eventList.writeln('   📅 ${event['date']}');
      eventList.writeln('   👥 ${event['category']}');
      eventList.writeln('   ✅ ${event['participants']}/${event['maxParticipants']} peserta\n');
    }
    
    eventList.writeln('Mau tahu detail event tertentu? Sebutkan nama eventnya! 😊');
    
    return eventList.toString();
  }

  /// Handle registration question
  Future<String> _handleRegistrationQuestion(String message) async {
    final eventId = _extractEventName(message);
    
    if (eventId != null) {
      final event = _eventService.getEventByIdSync(eventId);
      if (event != null) {
        return '''📝 **Cara Daftar ${event['title']}**:

1. Buka halaman detail event
2. Klik tombol "Daftar Sekarang"
3. Isi formulir pendaftaran
4. Submit dan tunggu konfirmasi

⏰ **Deadline**: ${event['registrationDeadline']}
✅ **Kuota**: ${event['participants']}/${event['maxParticipants']} tersedia

Buruan daftar sebelum kehabisan slot! 🎉''';
      }
    }

    return '''📝 **Cara Pendaftaran Event**:

1. **Pilih Event** - Lihat event yang tersedia
2. **Buka Detail** - Klik event yang diminati
3. **Daftar** - Klik tombol "Daftar Sekarang"
4. **Isi Form** - Lengkapi data pendaftaran
5. **Submit** - Kirim dan tunggu konfirmasi

💡 **Tips**: Daftar lebih awal agar tidak kehabisan kuota!

Mau daftar event apa? 😊''';
  }

  /// Handle deadline question
  Future<String> _handleDeadlineQuestion(String message) async {
    final eventId = _extractEventName(message);
    
    if (eventId != null) {
      final event = _eventService.getEventByIdSync(eventId);
      if (event != null) {
        return '''⏰ **Deadline ${event['title']}**:

Pendaftaran ditutup: **${event['registrationDeadline']}**

Pelaksanaan: **${event['date']}** | ${event['time']}

Sisa kuota: **${event['maxParticipants'] - event['participants']}** slot

Buruan daftar sebelum terlambat! ⚡''';
      }
    }

    // General deadline info
    final events = _eventService.getMockEvents();
    final deadlineList = StringBuffer('⏰ **Deadline Event**:\n\n');
    
    for (final event in events) {
      deadlineList.writeln('📌 **${event['title']}**');
      deadlineList.writeln('   Ditutup: ${event['registrationDeadline']}\n');
    }
    
    return deadlineList.toString();
  }

  /// Handle location question
  Future<String> _handleLocationQuestion(String message) async {
    final eventId = _extractEventName(message);
    
    if (eventId != null) {
      final event = _eventService.getEventByIdSync(eventId);
      if (event != null) {
        return '''📍 **Lokasi ${event['title']}**:

${event['location']}

📅 **Tanggal**: ${event['date']}
⏰ **Waktu**: ${event['time']}

Jangan sampai salah lokasi ya! 😊''';
      }
    }

    return '''📍 **Lokasi Event**:

Semua event diadakan di **SMKN 20 Jakarta**.

Lokasi spesifik akan disebutkan di detail masing-masing event (lapangan, aula, dll).

Mau tahu lokasi event tertentu? Sebutkan nama eventnya! 😊''';
  }

  /// Handle category question
  Future<String> _handleCategoryQuestion(String message) async {
    final categories = <String, List<String>>{};
    final events = _eventService.getMockEvents();
    
    for (final event in events) {
      final category = event['category']!;
      if (!categories.containsKey(category)) {
        categories[category] = [];
      }
      categories[category]!.add(event['title']!);
    }

    final categoryList = StringBuffer('🏷️ **Kategori Event**:\n\n');
    
    categories.forEach((category, eventNames) {
      categoryList.writeln('📌 **$category**:');
      for (final name in eventNames) {
        categoryList.writeln('   • $name');
      }
      categoryList.writeln();
    });
    
    categoryList.writeln('Mau info detail event tertentu? Sebutkan namanya! 😊');
    
    return categoryList.toString();
  }

  /// Generate default response with context awareness
  String _generateDefaultResponse(String message) {
    // Check if asking about something specific
    if (message.contains('?')) {
      return '''Hmm, saya kurang paham pertanyaannya 🤔

Saya bisa membantu dengan:
• Informasi event yang tersedia
• Detail event tertentu
• Cara pendaftaran
• Deadline pendaftaran
• Lokasi event

Coba tanya dengan kata kunci yang lebih jelas ya! 😊''';
    }

    return '''Maaf, saya kurang mengerti maksudnya 😅

Ketik **"bantuan"** untuk melihat apa yang bisa saya bantu!

Atau langsung tanya tentang:
• Event yang tersedia
• Cara pendaftaran
• Deadline event
• Lokasi event''';
  }
}

/// Chat intent enum
enum ChatIntent {
  greeting,
  thankYou,
  help,
  askAboutEvent,
  askEventList,
  askRegistration,
  askDeadline,
  askLocation,
  askCategory,
  unknown,
}
