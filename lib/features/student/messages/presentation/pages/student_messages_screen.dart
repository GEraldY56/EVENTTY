import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/chat_service.dart';
import '../../../../../core/providers/message_context_provider.dart';
import '../../../../../core/providers/auth_provider.dart';

class StudentMessagesScreen extends ConsumerStatefulWidget {
  const StudentMessagesScreen({super.key});

  @override
  ConsumerState<StudentMessagesScreen> createState() => _StudentMessagesScreenState();
}

class _StudentMessagesScreenState extends ConsumerState<StudentMessagesScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatService _chatService = ChatService();
  
  late String? _conversationId;
  List<ChatMessage> _messages = [];
  bool _isOperationalHours = false;
  
  @override
  void initState() {
    super.initState();
    _checkOperationalHours();
    _initializeChat();
  }

  void _checkOperationalHours() {
    final now = TimeOfDay.now();
    final operationalStart = const TimeOfDay(hour: 6, minute: 0);
    final operationalEnd = const TimeOfDay(hour: 15, minute: 0);
    
    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = operationalStart.hour * 60 + operationalStart.minute;
    final endMinutes = operationalEnd.hour * 60 + operationalEnd.minute;
    
    setState(() {
      _isOperationalHours = nowMinutes >= startMinutes && nowMinutes <= endMinutes;
    });
  }

  Future<void> _initializeChat() async {
    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? 'unknown';
    final userName = authService.userName ?? 'Student';

    // Check if there's a message context from event
    final messageContext = ref.read(messageContextProvider);
    
    try {
      // Get or create conversation
      _conversationId = await _chatService.getOrCreateConversation(
        userId: userId,
        userName: userName,
      );

      // Load existing messages
      final messages = await _chatService.getMessages(_conversationId!);
      
      if (mounted) {
        setState(() {
          _messages = messages;
        });
      }

      // Listen to message updates - realtime
      _chatService.getMessagesStream(_conversationId!).listen((messages) {
        if (mounted) {
          setState(() {
            _messages = messages;
          });
          _scrollToBottom();
        }
      });

      // Mark as read
      await _chatService.markAsRead(_conversationId!, userId);

      // If coming from event detail, set initial message
      if (messageContext != null && messageContext.initialMessage != null) {
        _messageController.text = messageContext.initialMessage!;
        
        // Clear context after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(messageContextProvider.notifier).state = null;
        });
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    if (_conversationId != null) {
      _chatService.disposeConversation(_conversationId!);
    }
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _conversationId == null) return;

    final authService = ref.read(authServiceProvider);
    final userId = authService.userId ?? 'unknown';
    final userName = authService.userName ?? 'Student';
    final message = _messageController.text.trim();


    _messageController.clear();

    // Send student message (saved to database, admin will see it)
    await _chatService.sendMessage(
      conversationId: _conversationId!,
      senderId: userId,
      senderName: userName,
      senderRole: 'student',
      message: message,
    );

    _scrollToBottom();
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

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colors.primary, colors.secondary],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 22),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isOperationalHours ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.card, width: 2),
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
                    'Admin OSIS',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isOperationalHours 
                        ? 'Online • 06:00-15:00'
                        : 'Offline • Balas saat jam operasional',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: _isOperationalHours 
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: colors.card,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.go(RouteNames.home),
        ),
      ),
      body: Column(
        children: [
          // Operational Hours Info Banner
          if (!_isOperationalHours)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFFBBF24),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFFB45309),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Admin akan membalas pesan Anda saat jam operasional (06:00 - 15:00)',
                      style: AppTextStyles.captionSmall.copyWith(
                        color: const Color(0xFFB45309),
                        fontSize: 12,
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final authService = ref.read(authServiceProvider);
                final isFromMe = message.senderId == authService.userId;
                
                // Show date separator if needed
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

          // Input Area
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: colors.card,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.border.withValues(alpha: 0.3),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle: TextStyle(color: colors.textTertiary),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        style: AppTextStyles.body1.copyWith(
                          fontSize: 15,
                          color: colors.textPrimary,
                        ),
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [colors.primary, colors.primary.withValues(alpha: 0.85)],
                      ),
                      shape: BoxShape.circle,
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
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) => _onNavTapped(context, index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: colors.card,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
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
        break;
      case 3:
        context.go(RouteNames.certificate);
        break;
      case 4:
        context.go(RouteNames.profile);
        break;
    }
  }

  Widget _buildDateSeparator(DateTime date) {
    String dateText;
    final now = DateTime.now();
    
    if (_isSameDay(date, now)) {
      dateText = 'Hari Ini';
    } else if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
      dateText = 'Kemarin';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }
    
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.border.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          dateText,
          style: AppTextStyles.captionSmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isFromMe) {
    final time = '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}';
    final isAdmin = message.senderRole == 'admin';
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: isFromMe
              ? LinearGradient(
                  colors: [colors.primary, colors.primary.withValues(alpha: 0.85)],
                )
              : null,
          color: isFromMe 
              ? null 
              : isAdmin 
                  ? (isDark 
                      ? const Color(0xFF1E3A5F)  // Dark blue for dark mode
                      : const Color(0xFFDBEAFE))  // Light blue for light mode
                  : colors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isFromMe ? 20 : 4),
            bottomRight: Radius.circular(isFromMe ? 4 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAdmin && !isFromMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '👤 Admin OSIS',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: isDark 
                        ? const Color(0xFF60A5FA)  // Lighter blue in dark mode
                        : const Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ),
            Text(
              message.message,
              style: AppTextStyles.body1.copyWith(
                color: isFromMe ? Colors.white : colors.textPrimary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  time,
                  style: AppTextStyles.captionSmall.copyWith(
                    color: isFromMe 
                        ? Colors.white.withValues(alpha: 0.8)
                        : colors.textSecondary,
                    fontSize: 10,
                  ),
                ),
                if (isFromMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: message.isRead 
                        ? const Color(0xFF3B82F6)
                        : Colors.white.withValues(alpha: 0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
