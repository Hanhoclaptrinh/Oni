import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/presentation/providers/ConversationProvider.dart';
import 'package:frontend/presentation/providers/SocketProvider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/data/models/Conversation.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/presentation/providers/MessageProvider.dart';
import 'package:frontend/presentation/providers/UserProvider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';

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
  final ScrollController _scrollController = ScrollController();

  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();

    socket = SocketService().socket!;

    // join room
    socket.emit("join_conversation", widget.conversation.id);

    // listen keo len top (reverse == true trong listview)
    _scrollController.addListener(() {
      // keo len top > 50 pixel thi load them tin nhan
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        ref.read(msgProvider(widget.conversation.id).notifier).loadMore();
      }
    });

    Future.microtask(() {
      ref.read(cvsProvider.notifier).markAsRead(widget.conversation.id);
      ref.invalidate(msgProvider(widget.conversation.id));
    });

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

    // thu hoi tin nhan socket
    socket.on("msg:revoke", (data) {
      try {
        if (data["conversationId"] != widget.conversation.id) return;

        ref
            .read(msgProvider(widget.conversation.id).notifier)
            .onMessageRevoked(data["msgId"].toString());
      } catch (e, st) {
        Logger().e("CRASH: $e");
        Logger().e(st);
      }
    });

    // chinh sua tin nhan socket
    socket.on("msg:edit", (data) {
      try {
        if (data["conversationId"] != widget.conversation.id) return;

        ref
            .read(msgProvider(widget.conversation.id).notifier)
            .onMessageEdited(
              msgId: data["msgId"].toString(),
              content: data["content"],
              editedAt: data["editedAt"] != null
                  ? DateTime.parse(data["editedAt"])
                  : DateTime.now(),
            );
      } catch (e, st) {
        Logger().e("CRASH: $e");
        Logger().e(st);
      }
    });
  }

  @override
  void dispose() {
    // leave room
    socket.emit("leave_conversation", widget.conversation.id);

    socket.off("new_message");
    socket.off("messages_seen");
    socket.off("user_typing");
    socket.off("user_stop_typing");

    _typingTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  // handle send
  void _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final editingMsg = ref.read(editingMessageProvider);
    if (editingMsg != null) {
      // update
      ref
          .read(msgProvider(widget.conversation.id).notifier)
          .onMessageEdited(
            msgId: editingMsg.id,
            content: text,
            editedAt: DateTime.now(),
          );

      // edit req
      await ref.read(msgServiceProvider).editMessage(editingMsg.id, text);

      // reset
      ref.read(editingMessageProvider.notifier).state = null;
    } else {
      socket.emit("send_message", {
        "conversationId": widget.conversation.id,
        "type": "text",
        "content": text,
      });
    }
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
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(20),
                      physics: const BouncingScrollPhysics(),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderId == myId;

                        return _buildMessageBubble(msg, isMe);
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
            child: SvgPicture.asset(
              "assets/images/arrowleft.svg",
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
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
                decoration: InputDecoration(
                  hintText: "Nhập tin nhắn...",
                  border: InputBorder.none,

                  // gui icon
                  // prefixIcon: IconButton(
                  //   onPressed: () => print(""),
                  //   icon: Icon(
                  //     Icons.emoji_emotions_rounded,
                  //     color: Colors.grey,
                  //   ),
                  // ),
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
              icon: SvgPicture.asset(
                "assets/images/send.svg",
                width: 24,
                height: 24,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              iconSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  // // message bubble - context menu ios
  // Widget _buildMessageBubble(String text, bool isMe) {
  //   return CupertinoContextMenu(
  //     enableHapticFeedback: true,
  //     actions: <Widget>[
  //       CupertinoContextMenuAction(
  //         onPressed: () => Navigator.pop(context),
  //         trailingIcon: CupertinoIcons.doc_on_doc,
  //         child: const Text('Sao chép'),
  //       ),
  //       CupertinoContextMenuAction(
  //         onPressed: () => Navigator.pop(context),
  //         trailingIcon: CupertinoIcons.pencil,
  //         child: const Text('Chỉnh sửa'),
  //       ),
  //       CupertinoContextMenuAction(
  //         isDestructiveAction: true,
  //         onPressed: () => Navigator.pop(context),
  //         trailingIcon: CupertinoIcons.trash,
  //         child: const Text('Xóa'),
  //       ),
  //     ],
  //     child: _bubbleUI(text, isMe),
  //   );
  // }

  // message bubble
  Widget _buildMessageBubble(Message msg, bool isMe) {
    final scaleNotifier = ValueNotifier<double>(1.0);

    if (msg.status == "revoked") {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            "Tin nhắn đã được thu hồi",
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    void _handleEdit(Message msg) {
      // set trang thai dang edit
      ref.read(editingMessageProvider.notifier).state = msg;

      // dua noi dung tin nhan cu vao input
      _textController.text = msg.content ?? "";
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );
    }

    void _handleAction(String value, String text) {
      switch (value) {
        case 'copy':
          // sao chep vao clipboard
          Clipboard.setData(ClipboardData(text: text));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Đã sao chép văn bản vào bộ nhớ tạm",
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
            ),
          );
          break;
        case 'edit':
          _handleEdit(msg);
          break;
        case "reply":
          print("Trả lời tin nhắn");
        case 'recall':
          // show dialog box truoc khi thu hoi
          _showDeleteConfirmDialog(msg.id, context, text);
          break;
        case 'delete':
          // xoa tin nhan 1 phia thi khong can hoi
          ref
              .read(msgProvider(widget.conversation.id).notifier)
              .deleteMessage(msg.id);
          break;
      }
    }

    return ValueListenableBuilder<double>(
      valueListenable: scaleNotifier,
      builder: (context, scale, child) {
        return AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            child: GestureDetector(
              onTapDown: (details) async {
                HapticFeedback.lightImpact(); // phan hoi rung
                scaleNotifier.value = 1.05; // zoom-in bubble 50%

                final pos = details.globalPosition; // vi tri click vao bubble

                // hien thi menu context
                await showMenu(
                  context: context,
                  position: RelativeRect.fromLTRB(
                    pos.dx,
                    pos.dy,
                    pos.dx + 1,
                    0,
                  ),
                  useRootNavigator: true,
                  elevation: 20,
                  constraints: const BoxConstraints(minWidth: 160),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white.withOpacity(0.95),
                  items: <PopupMenuEntry>[
                    _buildModernItem(
                      Icons.content_copy_rounded,
                      "Sao chép",
                      "copy",
                    ),
                    _buildModernItem(
                      Icons.edit_note_rounded,
                      "Chỉnh sửa",
                      "edit",
                    ),
                    _buildModernItem(Icons.reply_rounded, "Trả lời", "reply"),
                    const PopupMenuDivider(height: 1),
                    _buildModernItem(
                      Icons.undo_rounded,
                      "Thu hồi",
                      "recall",
                      isWarning: true,
                    ),
                    _buildModernItem(
                      Icons.delete_outline_rounded,
                      "Xóa",
                      "delete",
                      isWarning: true,
                    ),
                  ],
                ).then((value) {
                  scaleNotifier.value =
                      1.0; // tra lai kich thuoc cu khi close menu
                  if (value != null) _handleAction(value, msg.content ?? "");
                });
              },
              child: child!,
            ),
          ),
        );
      },
      child: _bubbleUI(msg, isMe),
    );
  }

  // build menu item
  PopupMenuItem _buildModernItem(
    IconData icon,
    String title,
    String value, {
    bool isWarning = false,
  }) {
    return PopupMenuItem(
      value: value,
      height: 45,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isWarning
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: isWarning ? Colors.redAccent : Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isWarning ? Colors.redAccent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // dialog box
  Future<void> _showDeleteConfirmDialog(
    String msgId,
    BuildContext context,
    String text,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // cho phep cham ra ngoai de close box
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Thu hồi tin nhắn?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa tin nhắn này không?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                'Xóa',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                // update UI
                ref
                    .read(msgProvider(widget.conversation.id).notifier)
                    .onMessageRevoked(msgId);

                // logic thu hoi tin nhan
                await ref.read(msgServiceProvider).revokeMessage(msgId);

                if (!mounted) return;

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _bubbleUI(Message msg, bool isMe) {
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
          msg.content ?? "",
          style: TextStyle(
            color: isMe ? Colors.white : AppColors.textDark,
            fontSize: 15,
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
