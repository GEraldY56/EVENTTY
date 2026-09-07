import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/colors.dart';
import '../../../../../core/constants/text_styles.dart';
import '../../../../../core/constants/spacing.dart';
import '../../../../../core/routes/route_names.dart';
import '../../../../../core/services/chat_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  String _searchQuery = '';
  final ChatService _chatService = ChatService();
  List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations();
    
    // Listen to conversations stream
    _chatService.getConversationsStream().listen((conversations) {
      if (mounted) {
        setState(() {
          _conversations = conversations;
        });
      }
    });
  }

  Future<void> _loadConversations() async {
    final conversations = await _chatService.getAllConversations();
    if (mounted) {
      setState(() {
        _conversations = conversations;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredConversations = _conversations.where((conv) {
      if (_searchQuery.isEmpty) return true;
      final name = conv.info.userName.toLowerCase();
      final nis = conv.info.userId;
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || nis.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Messages', style: AppTextStyles.heading3),
            FutureBuilder<int>(
              future: _chatService.getTotalUnreadCount(),
              builder: (context, snapshot) {
                final unreadCount = snapshot.data ?? 0;
                if (unreadCount > 0) {
                  return Text(
                    '$unreadCount pesan belum dibaca',
                    style: AppTextStyles.captionSmall.copyWith(
                      color: AppColors.error,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        backgroundColor: AppColors.background,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.horizontalPadding),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama atau NIS...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // Conversations List
          Expanded(
            child: filteredConversations.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.horizontalPadding,
                    ),
                    itemCount: filteredConversations.length,
                    itemBuilder: (context, index) {
                      final conversation = filteredConversations[index];
                      return _buildConversationCard(conversation);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(Conversation conversation) {
    final unreadCount = conversation.info.unreadCount;
    final hasUnread = unreadCount > 0;
    
    // Format time
    final now = DateTime.now();
    final diff = now.difference(conversation.info.lastMessageTime);
    String timeStr;
    if (diff.inMinutes < 60) {
      timeStr = '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      timeStr = '${diff.inHours}h';
    } else {
      timeStr = '${diff.inDays}d';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hasUnread ? AppColors.primary10 : AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLG),
        border: Border.all(
          color: hasUnread ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          child: Text(
            conversation.info.userName.substring(0, 1).toUpperCase(),
            style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                conversation.info.userName,
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
                ),
              ),
            ),
            Text(
              timeStr,
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.person, size: 12, color: AppColors.info),
                const SizedBox(width: 4),
                Text(
                  'NIS: ${conversation.info.userId}',
                  style: AppTextStyles.captionSmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    conversation.info.lastMessage,
                    style: AppTextStyles.body2.copyWith(
                      color: hasUnread
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasUnread)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unreadCount.toString(),
                      style: AppTextStyles.captionSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          context.push(
            RouteNames.adminMessageDetail.replaceAll(':id', conversation.info.conversationId),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada pesan',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah pencarian Anda',
            style: AppTextStyles.body2,
          ),
        ],
      ),
    );
  }
}
