import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider untuk menyimpan context event yang akan dikirim ke Messages screen
class MessageContext {
  final String? eventId;
  final String? eventTitle;
  final String? initialMessage;

  MessageContext({
    this.eventId,
    this.eventTitle,
    this.initialMessage,
  });
}

final messageContextProvider = StateProvider<MessageContext?>((ref) => null);
