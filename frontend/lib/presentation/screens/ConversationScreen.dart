import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/core/utils/RemoveVie.dart';
import 'package:frontend/data/models/Conversation.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/providers/ConversationProvider.dart';
import 'package:frontend/presentation/providers/SkSsProvider.dart';
import 'package:frontend/presentation/screens/ChatScreen.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ConversationScreen extends ConsumerStatefulWidget {
  const ConversationScreen({super.key});

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  late IO.Socket socket;
  String _keyword = "";

  List<Conversation> _filterConversations(List<Conversation> conversations) {
    if (_keyword.isEmpty) return conversations;

    final k = RemoveVie().removeVietnameseAccent(_keyword.toLowerCase());

    return conversations.where((c) {
      final name = RemoveVie().removeVietnameseAccent(
        c.displayNameSafe.toLowerCase(),
      );
      final lastMsg = RemoveVie().removeVietnameseAccent(
        (c.latestMessage?.content ?? "").toLowerCase(),
      );

      return name.contains(k) || lastMsg.contains(k);
    }).toList();
  }

  @override
  void initState() {
    super.initState();

    socket = SocketService().socket!;

    socket.on("msg:revoke", (data) {
      ref
          .read(cvsProvider.notifier)
          .onMessageRevoked(data["conversationId"], data["msgId"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversationsAsync = ref.watch(cvsProvider);

    return conversationsAsync.when(
      data: (conversations) {
        final filteredConvos = _filterConversations(conversations);
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: <Widget>[
              _buildSliverAppBar(),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),

              // 👉 EMPTY STATE
              if (filteredConvos.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "Không tìm thấy cuộc trò chuyện nào",
                        style: TextStyle(color: AppColors.textGrey),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: _buildConversationItem(
                        context,
                        filteredConvos[index],
                      ),
                    );
                  }, childCount: filteredConvos.length),
                ),
            ],
          ),

          floatingActionButton: FloatingActionButton(
            onPressed: () {
              /// todo
              /// tao cuoc tro chuyen nhom
            },
            backgroundColor: AppColors.primaryBlue,
            shape: const CircleBorder(),
            child: const Icon(Icons.add_rounded, color: Colors.white),
          ),
        );
      },

      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Lỗi $e"))),
    );
  }

  // xây appbar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
        title: const Text(
          "Conversations",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  // ô tìm kiếm
  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() => _keyword = value.toLowerCase().trim());
        },
        decoration: InputDecoration(
          hintText: "Search a friend",
          hintStyle: const TextStyle(color: AppColors.textGrey),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: Colors.black, size: 25),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
        ),
      ),
    );
  }

  // list hội thoại
  Widget _buildConversationItem(BuildContext context, Conversation c) {
    // private chat -> dùng otherUser
    final isPrivate = c.type == "private";
    final displayName = isPrivate
        ? c.otherUser?.displayName ?? "Người lạ"
        : c.name ?? "Cuộc trò chuyện nhóm";

    final String? avatar = isPrivate ? c.otherUser?.avatarUrl : c.avatarUrl;

    final lastMsg = c.latestMessage?.content ?? "Bắt đầu cuộc trò chuyện";

    final isUnread = c.hasUnread;

    return GestureDetector(
      onTap: () async {
        ref.read(cvsProvider.notifier).markAsRead(c.id); // clear unread

        await ref.read(skSsServiceProvider).ensureValidSocketSession();

        if (!context.mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatScreen(conversation: c)),
        );
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: (avatar != null && avatar.isNotEmpty)
                  ? NetworkImage(avatar)
                  : null,
              child: (avatar == null || avatar.isEmpty)
                  ? const Icon(Icons.person)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMsg,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isUnread
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isUnread ? AppColors.textDark : AppColors.textGrey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
