import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/chat_service.dart';
import '../../../../../core/services/eventty_bot_service.dart';
import '../../../../../core/providers/message_context_provider.dart';
import '../../../../../core/providers/auth_provider.dart';


class StudentMessagesScreen extends ConsumerStatefulWidget {
  const StudentMessagesScreen({super.key});

  @override
  ConsumerState<StudentMessagesScreen> createState() => _StudentMessagesScreenState();
}

/// Custom painter for WhatsApp-style message tail/pointer
class _MessageTailPainter extends CustomPainter {
  final Color color;
  final bool isFromMe;

  _MessageTailPainter({required this.color, required this.isFromMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    
    if (isFromMe) {
      // Tail for sent messages (right side)
      path.moveTo(0, 0);
      path.lineTo(0, size.height - 8);
      path.quadraticBezierTo(
        size.width / 2, size.height - 4,
        size.width, size.height,
      );
      path.lineTo(0, size.height - 2);
    } else {
      // Tail for received messages (left side)
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height - 8);
      path.quadraticBezierTo(
        size.width / 2, size.height - 4,
        0, size.height,
      );
      path.lineTo(size.width, size.height - 2);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StudentMessagesScreenState extends ConsumerState<StudentMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  final EventtyBotService _botService = EventtyBotService();
  
  late String _conversationId;
  List<ChatMessage> _messages = [];
  bool _isTyping = false; // For typing indicator
  bool _showAdminSuggestion = false; // Show "Hubungi Admin" button
  String? _currentEventId; // Track current event context
  String _conversationMode = 'bot'; // Track conversation mode: 'bot' or 'admin'
  String? _lastBotMessageId; // Track which bot message has the admin button
  
  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  void _initializeChat() {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? 'unknown';
    final userName = authService.userName ?? 'Student';

    // Check if there's a message context from event (Tanya Admin)
    final messageContext = ref.read(messageContextProvider);
    if (messageContext != null) {
      _currentEventId = messageContext.eventId;
    }
    
    // Get or create conversation
    _conversationId = _chatService.getOrCreateConversation(
      userId: userId,
      userName: userName,
    );

    // Get conversation mode
    _conversationMode = _chatService.getConversationMode(_conversationId);

    // Load existing messages
    _messages = _chatService.getMessages(_conversationId);

    // Listen to message updates
    _chatService.getMessagesStream(_conversationId).listen((messages) {
      if (mounted) {
        setState(() {
          _messages = _chatService.getMessages(_conversationId);
          // Update mode from service (in case it changed)
          _conversationMode = _chatService.getConversationMode(_conversationId);
        });
        _scrollToBottom();
      }
    });

    // Mark as read
    _chatService.markAsRead(_conversationId, userId);

    // If coming from event detail (Tanya Admin), set initial message
    if (messageContext != null && messageContext.initialMessage != null) {
      _messageController.text = messageContext.initialMessage!;
      
      // Clear context after build is complete
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(messageContextProvider.notifier).state = null;
      });
    }

    // Send welcome message if first time
    if (_messages.isEmpty) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _chatService.sendMessage(
          conversationId: _conversationId,
          senderId: 'bot',
          senderName: 'Eventty Bot',
          senderRole: 'bot',
          message: 'Halo! 👋 Saya Eventty Bot, asisten virtual OSIS.\n\nSaya bisa membantu Anda dengan informasi tentang event. Silakan tanyakan apa saja! 😊\n\nJika saya tidak bisa menjawab, Anda bisa langsung berbicara dengan Admin OSIS.',
        );
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? 'unknown';
    final userName = authService.userName ?? 'Student';
    final message = _messageController.text.trim();

    _messageController.clear();

    // Send student message
    await _chatService.sendMessage(
      conversationId: _conversationId,
      senderId: userId,
      senderName: userName,
      senderRole: 'student',
      message: message,
    );

    _scrollToBottom();
    
    // CRITICAL: Check conversation mode before calling bot
    if (_conversationMode == 'bot') {
      // BOT MODE: Process with bot service
      setState(() => _isTyping = true);
      
      // Get bot response
      final botResponse = await _botService.processMessage(message, eventId: _currentEventId);
      
      // Hide typing indicator
      setState(() => _isTyping = false);
      
      // Send bot response
      await _chatService.sendMessage(
        conversationId: _conversationId,
        senderId: 'bot',
        senderName: 'Eventty Bot',
        senderRole: 'bot',
        message: botResponse.message,
      );
      
      // Show admin suggestion if bot can't answer - STORE LAST BOT MESSAGE ID
      if (botResponse.suggestAdmin) {
        // Get the last message (bot message we just sent)
        final messages = _chatService.getMessages(_conversationId);
        if (messages.isNotEmpty) {
          final lastBotMessage = messages.last;
          setState(() {
            _showAdminSuggestion = true;
            _lastBotMessageId = lastBotMessage.id; // Store which message has button
          });
        }
      }
    } else {
      // ADMIN MODE: Don't call bot, just save message
      // Admin will receive and reply manually
      // Do nothing - message already saved above
    }
    
    _scrollToBottom();
  }

  void _requestAdmin() async {
    setState(() => _showAdminSuggestion = false);
    
    // Switch to admin mode
    await _chatService.setConversationMode(_conversationId, 'admin');
    setState(() => _conversationMode = 'admin');
    
    // Send system notification as centered message
    await _chatService.sendMessage(
      conversationId: _conversationId,
      senderId: 'system',
      senderName: 'System',
      senderRole: 'system',
      message: '👤 Terhubung dengan Admin OSIS\nBot tidak aktif selama chat dengan Admin',
    );
  }

  void _switchToBotMode() async {
    // Switch back to bot mode
    await _chatService.setConversationMode(_conversationId, 'bot');
    setState(() => _conversationMode = 'bot');
    
    // Send system notification as centered message
    await _chatService.sendMessage(
      conversationId: _conversationId,
      senderId: 'system',
      senderName: 'System',
      senderRole: 'system',
      message: '🤖 Eventty Bot aktif',
    );
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // CRITICAL: false = navbar TIDAK naik!
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            // Avatar with online status (modern WhatsApp style)
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                ),
                // Online status indicator (modern WhatsApp style)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981), // Green
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.card, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Eventty Assistant',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Typing indicator or online status
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      _isTyping ? '🤖 Bot mengetik...' : '🤖 Bot & 👤 Admin',
                      key: ValueKey(_isTyping),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: _isTyping 
                            ? const Color(0xFF8B5CF6)
                            : const Color(0xFF10B981),
                        fontSize: 12,
                        fontStyle: _isTyping ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.card,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.home),
        ),
        actions: [
          // More options
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (context) => Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Handle bar (modern design)
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.info_outline, color: AppColors.primary),
                        title: const Text('Info Kontak'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: Icon(Icons.search, color: AppColors.textSecondary),
                        title: const Text('Cari Chat'),
                        onTap: () => Navigator.pop(context),
                      ),
                      ListTile(
                        leading: Icon(Icons.delete_outline, color: AppColors.error),
                        title: const Text('Hapus Chat'),
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation();
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.block, color: AppColors.error),
                        title: const Text('Blokir'),
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _conversationMode == 'bot' 
                  ? const Color(0xFFF3E8FF) // Light purple for bot
                  : const Color(0xFFDBEAFE), // Light blue for admin (NOT RED!)
              border: Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _conversationMode == 'bot' 
                      ? Icons.smart_toy_rounded 
                      : Icons.support_agent_rounded,
                  color: _conversationMode == 'bot' 
                      ? const Color(0xFF8B5CF6) 
                      : const Color(0xFF3B82F6), // Blue for admin
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _conversationMode == 'bot' 
                        ? '🤖 Eventty Bot aktif' 
                        : '👤 Terhubung dengan Admin OSIS',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: _conversationMode == 'bot' 
                          ? const Color(0xFF8B5CF6) 
                          : const Color(0xFF3B82F6), // Blue for admin
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_conversationMode == 'admin' ? 1 : 0), // +1 for action button when admin mode
              itemBuilder: (context, index) {
                // Show "Kembali ke Eventty Bot" button as LAST item when admin mode
                if (_conversationMode == 'admin' && index == _messages.length) {
                  return _buildBackToBotButton();
                }
                
                final message = _messages[index];
                final authService = ref.read(authServiceProvider);
                final isFromMe = message.senderId == authService.userId;
                
                // Show date separator if needed (WhatsApp style)
                bool showDateSeparator = false;
                if (index == 0) {
                  showDateSeparator = true;
                } else {
                  final previousMessage = _messages[index - 1];
                  showDateSeparator = !_isSameDay(
                    message.timestamp,
                    previousMessage.timestamp,
                  );
                }
                
                return Column(
                  children: [
                    if (showDateSeparator) _buildDateSeparator(message.timestamp),
                    _buildMessageBubble(message, isFromMe),
                  ],
                );
              },
            ),
          ),

          // Typing indicator (modern WhatsApp style)
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildTypingDot(0),
                        const SizedBox(width: 4),
                        _buildTypingDot(1),
                        const SizedBox(width: 4),
                        _buildTypingDot(2),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Input Area (Simple - Text + Send only)
          Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), // Push up when keyboard shows
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.card,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Text input field (Simple design)
                    Expanded(
                      child: Container(
                        constraints: const BoxConstraints(maxHeight: 120),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.border.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: TextField(
                          controller: _messageController,
                          decoration: const InputDecoration(
                            hintText: 'Tulis pesan...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: AppTextStyles.body1.copyWith(fontSize: 15),
                          maxLines: null,
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send button (Modern)
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                        onPressed: _sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar - FIXED (tidak naik saat keyboard)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowMedium,
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: 2, // Messages is index 2
          onTap: (index) => _onNavTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.card,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textTertiary,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          iconSize: AppSpacing.iconMD,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Events',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_outlined),
              activeIcon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.workspace_premium_outlined),
              activeIcon: Icon(Icons.workspace_premium),
              label: 'Certificate',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  void _onNavTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.events);
        break;
      case 2:
        // Already on messages
        break;
      case 3:
        context.go(RouteNames.certificate);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
    }
  }

  Widget _buildMessageBubble(ChatMessage message, bool isFromMe) {
    final time = '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    
    // Determine sender emoji and color
    String senderEmoji = '';
    Color senderColor = AppColors.primary;
    bool isBot = message.senderRole == 'bot';
    bool isAdmin = message.senderRole == 'admin';
    bool isSystem = message.senderRole == 'system';
    
    // Check if this bot message should show "Hubungi Admin" button
    bool shouldShowAdminButton = isBot && 
                                 _showAdminSuggestion && 
                                 _conversationMode == 'bot' &&
                                 message.id == _lastBotMessageId;
    
    if (isBot) {
      senderEmoji = '🤖 ';
      senderColor = const Color(0xFF8B5CF6); // Purple for bot
    } else if (isAdmin) {
      senderEmoji = '👤 ';
      senderColor = const Color(0xFF3B82F6); // Blue for admin (NOT RED - red means error!)
    } else if (isSystem) {
      senderEmoji = '';
      senderColor = const Color(0xFF6B7280); // Gray for system
    }
    
    // System messages - centered with special styling
    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                message.message.contains('Admin') 
                    ? Icons.person_outline 
                    : Icons.smart_toy_outlined,
                size: 14,
                color: const Color(0xFF6B7280),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  message.message,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Regular messages (student, bot, admin)
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: isFromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // WhatsApp-style tail/pointer
          if (!isFromMe)
            CustomPaint(
              painter: _MessageTailPainter(
                color: isBot 
                    ? const Color(0xFFF3E8FF) // Light purple for bot
                    : isAdmin 
                        ? const Color(0xFFDBEAFE) // Light blue for admin
                        : AppColors.card,
                isFromMe: false,
              ),
              size: const Size(8, 20),
            ),
          // Message bubble with modern design
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            decoration: BoxDecoration(
              // Gradient background for sent messages
              gradient: isFromMe
                  ? LinearGradient(
                      colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              // Different colors for bot/admin
              color: isFromMe 
                  ? null 
                  : isBot 
                      ? const Color(0xFFF3E8FF) // Light purple for bot
                      : isAdmin
                          ? const Color(0xFFDBEAFE) // Light blue for admin
                          : AppColors.card,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isFromMe ? 20 : 4),
                bottomRight: Radius.circular(isFromMe ? 4 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
              border: isFromMe ? null : Border.all(
                color: isBot
                    ? const Color(0xFF8B5CF6).withValues(alpha: 0.2)
                    : isAdmin
                        ? const Color(0xFF3B82F6).withValues(alpha: 0.2) // Blue border for admin
                        : AppColors.border.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isFromMe)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '$senderEmoji${message.senderName}',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: senderColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                Text(
                  message.message,
                  style: AppTextStyles.body1.copyWith(
                    color: isFromMe 
                        ? Colors.white 
                        : isSystem
                            ? const Color(0xFF065F46)
                            : AppColors.textPrimary,
                    fontSize: isSystem ? 12 : 14.5,
                    height: 1.4,
                    fontStyle: isSystem ? FontStyle.italic : FontStyle.normal,
                  ),
                  textAlign: isSystem ? TextAlign.center : TextAlign.start,
                ),
                
                // "Hubungi Admin" button INSIDE bot bubble
                if (shouldShowAdminButton) ...[
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: _requestAdmin,
                    borderRadius: BorderRadius.circular(25),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6),
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B5CF6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hubungi Admin',
                            style: AppTextStyles.captionSmall.copyWith(
                              color: const Color(0xFF8B5CF6),
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                
                if (!isSystem)
                  const SizedBox(height: 2),
                if (!isSystem)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isFromMe
                              ? Colors.white.withValues(alpha: 0.7)
                              : AppColors.textTertiary.withValues(alpha: 0.7),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      if (isFromMe) ...[
                        const SizedBox(width: 3),
                        Icon(
                          message.isRead ? Icons.done_all : Icons.done,
                          size: 14,
                          color: message.isRead
                              ? const Color(0xFF34D399)
                              : Colors.white.withValues(alpha: 0.7),
                        ),
                      ],
                    ],
                  ),
              ],
            ),
          ),
          // WhatsApp-style tail/pointer for sent messages
          if (isFromMe && !isSystem)
            CustomPaint(
              painter: _MessageTailPainter(
                color: AppColors.primary,
                isFromMe: true,
              ),
              size: const Size(8, 20),
            ),
        ],
      ),
    );
  }

  // Date separator (Today, Yesterday, etc.) - WhatsApp style
  Widget _buildDateSeparator(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Hari Ini';
    } else if (messageDate == yesterday) {
      dateText = 'Kemarin';
    } else {
      // Format: "Sen, 28 Agt"
      final days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'];
      dateText = '${days[date.weekday % 7]}, ${date.day} ${months[date.month - 1]}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            dateText,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  // Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Typing indicator dot (animated) - WhatsApp style
  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        final offset = (value * 2 * pi); // One full cycle
        final animatedValue = (index * 0.3 + offset) % (2 * pi);
        final scale = 0.7 + (0.3 * (1 + sin(animatedValue))) / 2;
        
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted && _isTyping) {
          setState(() {}); // Re-trigger animation
        }
      },
    );
  }

  // Quick action button (modern design)
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withValues(alpha: 0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: AppTextStyles.captionSmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build "Kembali ke Eventty Bot" button as system action in chat
  Widget _buildBackToBotButton() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _switchToBotMode,
            borderRadius: BorderRadius.circular(25),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: const Color(0xFF8B5CF6),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF8B5CF6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kembali ke Eventty Bot',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: const Color(0xFF8B5CF6),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Chat', style: AppTextStyles.heading3),
        content: Text(
          'Apakah Anda yakin ingin menghapus semua pesan dalam chat ini?',
          style: AppTextStyles.body1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
