import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/controllers/SocketProvider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/data/models/Conversation.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/controllers/MessageProvider.dart';
import 'package:frontend/presentation/controllers/UserProvider.dart';
import 'package:collection/collection.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final Conversation conversation;
  ChatScreen({super.key, required this.conversation});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late IO.Socket socket;
  final TextEditingController _textController = TextEditingController();
  final Map<String, String> _typingUsers = {};

  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    socket = SocketService().socket!;

    // join room
    socket.emit("join_conversation", widget.conversation.id);

    socket.emit("seen_messages", {"conversationId": widget.conversation.id});

    // listen message
    socket.on("new_message", (data) {
      final msg = Message.fromJson(data);

      // chỉ add nếu đúng phòng
      if (msg.conversationId == widget.conversation.id) {
        ref.read(msgProvider(widget.conversation.id).notifier).addMessage(msg);

        // nếu là tin nhắn của người khác -> seen ngay
        if (msg.senderId != ref.read(userProvider).value?.id) {
          socket.emit("seen_messages", {
            "conversationId": widget.conversation.id,
          });
        }
      }
    });

    socket.on("messages_seen", (data) {
      final conversationId = data["conversationId"];
      final userId = data["userId"];

      if (conversationId != widget.conversation.id) return;

      ref.read(msgProvider(conversationId).notifier).markSeenBy(userId);
    });

    // listen typing
    socket.on("user_typing", (data) {
      if (data["conversationId"] != widget.conversation.id) return;

      final userId = data["userId"];
      final myId = ref.read(userProvider).value?.id;
      if (userId == myId) return;

      final name = widget.conversation.type == "private"
          ? widget.conversation.otherUser?.displayName ?? "Ai đó"
          : widget.conversation.members
                    .firstWhereOrNull((m) => m.id == userId)
                    ?.displayName ??
                "Ai đó";

      setState(() {
        _typingUsers[userId] = name;
      });
    });

    socket.on("user_stop_typing", (data) {
      if (data["conversationId"] != widget.conversation.id) return;
      setState(() => _typingUsers.remove(data["userId"]));
    });
  }

  @override
  void dispose() {
    // leave room
    socket.emit("leave_conversation", widget.conversation.id);

    socket.off("new_message");
    _textController.dispose();
    super.dispose();
  }

  // handle send
  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    socket.emit("send_message", {
      "conversationId": widget.conversation.id,
      "type": "text",
      "content": text,
    });

    _textController.clear();
  }

  // handle typing
  void _handleTyping(String msg) {
    if (!_isTyping) {
      _isTyping = true;
      socket.emit("typing_start", {"conversationId": widget.conversation.id});
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 1), () {
      _isTyping = false;
      socket.emit("typing_end", {"conversationId": widget.conversation.id});
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(msgProvider(widget.conversation.id));
    final meAsync = ref.watch(userProvider);
    final presenceMap = ref.watch(presenceProvider);
    final isOnline = presenceMap[widget.conversation.otherUser?.id];

    return meAsync.when(
      data: (me) {
        final myId = me.id;

        return messagesAsync.when(
          data: (messages) {
            return Scaffold(
              backgroundColor: AppColors.lightBlueBg,
              body: Column(
                children: [
                  _buildHeader(context, widget.conversation, isOnline),

                  // message list
                  Expanded(
                    child: ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == myId;

                        return _buildMessageBubble(msg.content ?? "", isMe);
                      },
                    ),
                  ),

                  // typing indicator
                  _buildTypingIndicator(),

                  // input bar
                  _buildInputBar(),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text("Lỗi messages: $e")),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Lỗi profile: $e")),
    );
  }

  // header
  Widget _buildHeader(BuildContext context, Conversation c, bool? isOnline) {
    final isPrivate = c.type == "private";
    final displayName = c.displayNameSafe;
    final avatar = c.finalAvatar;

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.black,
            ),
          ),
          const SizedBox(width: 15),

          CircleAvatar(
            radius: 22,
            backgroundImage: avatar != null ? NetworkImage(avatar) : null,
            child: avatar == null ? Icon(Icons.person) : null,
          ),

          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                isPrivate
                    ? Text(
                        isOnline == true ? "Online" : "Offline",
                        style: TextStyle(
                          fontSize: 13,
                          color: isOnline == true
                              ? AppColors.onlineGreen
                              : AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Text(
                        "${widget.conversation.members.length} thành viên",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // input bar
  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                onChanged: _handleTyping,
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: "Nhập tin nhắn...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // send button
          Container(
            height: 50,
            width: 50,
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _handleSend,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // message bubble
  Widget _buildMessageBubble(String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: isMe ? AppColors.bubbleBlue : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: isMe
                ? const Radius.circular(18)
                : const Radius.circular(2),
            topRight: const Radius.circular(18),
            bottomLeft: const Radius.circular(18),
            bottomRight: isMe
                ? const Radius.circular(2)
                : const Radius.circular(18),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textDark,
            fontSize: 15,
            height: 1.3,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    if (_typingUsers.isEmpty) return const SizedBox.shrink();

    if (widget.conversation.type == "private") {
      return const Padding(
        padding: EdgeInsets.only(left: 16, bottom: 6),
        child: Text(
          "Đang soạn tin nhắn...",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      );
    }

    // group chat
    final names = _typingUsers.values.join(", ");
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 6),
      child: Text(
        "$names đang soạn tin nhắn..",
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
