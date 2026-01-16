import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:frontend/core/utils/Enums.dart';
import 'package:frontend/data/services/CloudinaryService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/ConversationProvider.dart';
import 'package:frontend/providers/SocketProvider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/data/models/Conversation.dart';
import 'package:frontend/data/models/Media.dart';
import 'package:frontend/data/models/Message.dart';
import 'package:frontend/data/services/SocketService.dart';
import 'package:frontend/providers/MessageProvider.dart';
import 'package:frontend/providers/UserProvider.dart';
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
  bool _showEmoji = false;
  final FocusNode _focusNode = FocusNode();

  final List<XFile> _selectedImages = [];
  final List<File> _selectedFiles = [];
  final ImagePicker _picker = ImagePicker();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();

    socket = SocketService().socket!;

    // join room
    socket.emit("join_conversation", widget.conversation.id);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmoji = false;
        });
      }
    });

    // listen keo len top (reverse == true trong listview)
    _scrollController.addListener(() {
      // keo len top > 50 pixel thi load them tin nhan
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        if (!mounted) return;
        ref.read(msgProvider(widget.conversation.id).notifier).loadMore();
      }
    });

    Future.microtask(() {
      if (!mounted) return;
      ref.read(cvsProvider.notifier).markAsRead(widget.conversation.id);
      ref.invalidate(msgProvider(widget.conversation.id));
    });

    socket.emit("seen_messages", {"conversationId": widget.conversation.id});

    // listen message
    socket.on("new_message", (data) {
      final msg = Message.fromJson(Map<String, dynamic>.from(data));

      // chỉ add nếu đúng phòng
      if (msg.conversationId == widget.conversation.id) {
        if (!mounted) return;
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
      try {
        final conversationId = data["conversationId"];
        final userId = data["userId"]?.toString();

        if (conversationId != widget.conversation.id || userId == null) return;

        if (!mounted) return;
        ref.read(msgProvider(conversationId).notifier).markSeenBy(userId);
      } catch (e, st) {
        Logger().e("CRASH: $e");
        Logger().e(st);
      }
    });

    // listen typing
    socket.on("user_typing", (data) {
      if (data["conversationId"] != widget.conversation.id) return;
      if (!mounted) return;

      final userId = data["userId"];
      final myId = ref.read(userProvider).value!.id;
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
      if (!mounted) return;
      if (data["conversationId"] != widget.conversation.id) return;
      setState(() => _typingUsers.remove(data["userId"]));
    });

    // thu hoi tin nhan socket
    socket.on("msg:revoked", (data) {
      try {
        if (data["conversationId"] != widget.conversation.id) return;

        if (!mounted) return;
        ref
            .read(msgProvider(widget.conversation.id).notifier)
            .onMessageRevoked(data["msgId"].toString());
      } catch (e, st) {
        Logger().e("CRASH: $e");
        Logger().e(st);
      }
    });

    // chinh sua tin nhan socket
    socket.on("msg:edited", (data) {
      try {
        if (data["conversationId"] != widget.conversation.id) return;

        if (!mounted) return;
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

    // temp message
    socket.on("msg:sent", (data) {
      try {
        final tempId = data["tempId"];
        final msgJson = Map<String, dynamic>.from(data["message"]);
        final msg = Message.fromJson(
          msgJson,
        ).copyWith(msgStatusSending: MessageStatus.sent);

        if (!mounted) return;
        ref
            .read(msgProvider(widget.conversation.id).notifier)
            .replaceTempMessage(tempId, msg);
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

    // remove listeners
    socket.off("new_message");
    socket.off("messages_seen");
    socket.off("user_typing");
    socket.off("user_stop_typing");
    socket.off("msg:revoked");
    socket.off("msg:edited");
    socket.off("msg:sent");

    _typingTimer?.cancel();
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // handle send
  void _handleSend() async {
    try {
      final text = _textController.text.trim();
      final hasFiles = _selectedImages.isNotEmpty || _selectedFiles.isNotEmpty;

      if (text.isEmpty && !hasFiles) return;

      final editingMsg = ref.read(editingMessageProvider);
      final replyToMsg = ref.read(replyToMessageProvider);
      final myId = ref.read(userProvider).value!.id;
      final convoId = widget.conversation.id;

      if (editingMsg != null) {
        // chinh sua tin nhan
        socket.emit("edit_message", {"msgId": editingMsg.id, "content": text});

        // reset
        ref.read(editingMessageProvider.notifier).state = null;
      } else {
        final tempId = "tmp_${DateTime.now().millisecondsSinceEpoch}";

        // upload file len cloudinary
        List<Media>? uploadedMedia;
        if (hasFiles) {
          uploadedMedia = await _uploadFilesToCloudinary();
          if (uploadedMedia.isEmpty && hasFiles) {
            return; // upload that bai thi khong seng tin nhan
          }
        }

        // Determine message type
        final messageType = hasFiles ? MessageType.media : MessageType.text;

        final tempMsg = Message(
          id: tempId,
          conversationId: convoId,
          senderId: myId,
          type: messageType,
          status: MessageStatusType.normal,
          msgStatusSending: MessageStatus.sending,
          content: text.isEmpty ? null : text,
          media: uploadedMedia?.isNotEmpty == true
              ? uploadedMedia!.first
              : null,
          seenBy: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          replyTo: replyToMsg?.id,
        );

        ref.read(msgProvider(convoId).notifier).addMessage(tempMsg);

        final payload = {
          "conversationId": convoId,
          "type": messageType.name,
          if (text.isNotEmpty) "content": text,
          "tempId": tempId,
          if (uploadedMedia?.isNotEmpty == true)
            "media": {
              "url": uploadedMedia!.first.url,
              "type": uploadedMedia.first.type.name,
              if (uploadedMedia.first.size != null)
                "size": uploadedMedia.first.size,
              if (uploadedMedia.first.width != null)
                "width": uploadedMedia.first.width,
              if (uploadedMedia.first.height != null)
                "height": uploadedMedia.first.height,
              if (uploadedMedia.first.duration != null)
                "duration": uploadedMedia.first.duration,
              if (uploadedMedia.first.format != null)
                "format": uploadedMedia.first.format,
            },
          if (replyToMsg != null)
            "replyTo": {
              "messageId": replyToMsg.id, // chi gui id tin nhan
            },
        };

        socket.emit("send_message", payload);

        ref.read(replyToMessageProvider.notifier).state = null;
      }
      _textController.clear();
      setState(() {
        _selectedImages.clear();
        _selectedFiles.clear();
      });
    } catch (e, st) {
      Logger().e("CRASH: $e");
      Logger().e(st);
    }
  }

  // pick image
  Future<void> _pickImage() async {
    final List<XFile> images = await _picker
        .pickMultiImage(); // cho phep chon nhieu hinh anh
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  // pick files (documents, audio)
  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', // documents
          'mp3', 'wav', 'm4a', 'aac', // audio
          'zip', 'rar', // archives
        ],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFiles.addAll(
            result.files.map((file) => File(file.path!)).toList(),
          );
        });
      }
    } catch (e) {
      Logger().e('Error picking files: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lỗi khi chọn file'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // handle upload file to cloudinary
  Future<List<Media>> _uploadFilesToCloudinary() async {
    final List<Media> uploadedMedia = [];

    try {
      setState(() {
        _isUploading = true;
      });

      // upload image
      for (final image in _selectedImages) {
        final file = File(image.path);
        final media = await _cloudinaryService.uploadFile(
          file,
          MediaType.image,
        );
        uploadedMedia.add(media);
      }

      // upload other files
      for (final file in _selectedFiles) {
        // determine media type based on extension
        final extension = file.path.split('.').last.toLowerCase();
        MediaType mediaType;
        if (['mp3', 'wav', 'm4a', 'aac'].contains(extension)) {
          mediaType = MediaType.audio;
        } else {
          mediaType = MediaType.file;
        }

        final media = await _cloudinaryService.uploadFile(file, mediaType);
        uploadedMedia.add(media);
      }

      return uploadedMedia;
    } catch (e) {
      Logger().e('Error uploading files: $e');
      if (!mounted) return [];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi upload file: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
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
    final replyToMsg = ref.watch(replyToMessageProvider);

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

                  // reply to
                  if (replyToMsg != null)
                    _buildReplyMessage(
                      replyMsg: replyToMsg,
                      onCancel: () {
                        ref.read(replyToMessageProvider.notifier).state = null;
                      },
                    ),

                  // input bar
                  _buildInputBar(),

                  // emoji picker
                  if (_showEmoji)
                    SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        textEditingController: _textController,
                        config: Config(
                          height: 250,
                          checkPlatformCompatibility: true,
                          emojiViewConfig: EmojiViewConfig(
                            columns: 7,
                            emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                          ),
                        ),
                      ),
                    ),
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

  Widget _buildReplyMessage({
    required Message replyMsg,
    required VoidCallback onCancel,
    bool isMe = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
        border: Border(
          left: BorderSide(
            width: 4,
            color: isMe ? Colors.white70 : Colors.blueAccent,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Đang trả lời",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white70 : Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  replyMsg.content ?? "Tin nhắn",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: isMe ? Colors.white70 : Colors.grey,
            ),
            onPressed: onCancel,
          ),
        ],
      ),
    );
  }

  // input bar
  Widget _buildInputBar() {
    final hasContent =
        _textController.text.trim().isNotEmpty ||
        _selectedImages.isNotEmpty ||
        _selectedFiles.isNotEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      child: Column(
        children: [
          // uploading indicator
          if (_isUploading)
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Đang upload file...',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),

          // file preview
          if (_selectedImages.isNotEmpty || _selectedFiles.isNotEmpty)
            _buildFilePreview(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
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
            child: Row(
              children: [
                // emoji button
                IconButton(
                  icon: _showEmoji
                      ? SvgPicture.asset("assets/images/keyboard.svg")
                      : SvgPicture.asset("assets/images/emoji.svg"),
                  onPressed: () {
                    setState(() {
                      _showEmoji = !_showEmoji;
                      if (_showEmoji) {
                        _focusNode.unfocus();
                      } else {
                        _focusNode.requestFocus();
                      }
                    });
                  },
                ),

                // text field
                Expanded(
                  child: TextField(
                    focusNode: _focusNode,
                    onChanged: (val) {
                      _handleTyping(val);
                      setState(() {});
                    },
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // image picker button
                IconButton(
                  onPressed: _isUploading ? null : _pickImage,
                  icon: SvgPicture.asset("assets/images/album.svg"),
                ),

                // folder/file picker button
                IconButton(
                  onPressed: _isUploading ? null : _pickFiles,
                  icon: SvgPicture.asset("assets/images/folder.svg"),
                ),

                // send button
                // chi hien thi nut send khi co du lieu
                if (hasContent)
                  IconButton(
                    onPressed: _handleSend,
                    icon: SvgPicture.asset("assets/images/send.svg"),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      height: 80,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // image previews
          ..._selectedImages.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: FileImage(File(file.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImages.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),

          // document file previews
          ..._selectedFiles.asMap().entries.map((entry) {
            final index = entry.key;
            final file = entry.value;
            final fileName = file.path.split('/').last.split('\\').last;
            final extension = fileName.contains('.')
                ? fileName.split('.').last.toUpperCase()
                : 'FILE';

            return Stack(
              children: [
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.blue.shade50,
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_drive_file,
                        size: 30,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        extension,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 0,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedFiles.removeAt(index);
                      });
                    },
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  // helper lay ten nguoi gui
  String _getSenderName({
    required Message replyMsg,
    required Conversation conversation,
    required String myId,
  }) {
    if (replyMsg.senderId == myId) return "Bạn";

    if (conversation.type == "private") {
      return conversation.otherUser?.displayName ?? "Người dùng";
    }

    return conversation.members
            .firstWhereOrNull((member) => member.id == replyMsg.senderId)
            ?.displayName ??
        "Người dùng";
  }

  // UI reply preview
  Widget _buildReplyPreview(Message replyMsg, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.15) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            width: 3,
            color: isMe ? Colors.white70 : Colors.blueAccent,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getSenderName(
              replyMsg: replyMsg,
              conversation: widget.conversation,
              myId: ref.read(userProvider).value?.id ?? "",
            ),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isMe ? Colors.white70 : Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            replyMsg.content ?? "Tin nhắn",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: isMe ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // message bubble
  Widget _buildMessageBubble(Message msg, bool isMe) {
    final messages = ref.read(msgProvider(widget.conversation.id)).value ?? [];

    final replyMsg = msg.replyTo != null
        ? messages.firstWhereOrNull((e) => e.id == msg.replyTo)
        : null;

    final scaleNotifier = ValueNotifier<double>(1.0);

    if (msg.status == MessageStatusType.revoked) {
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
      ref.read(replyToMessageProvider.notifier).state = null;

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
          ref.read(replyToMessageProvider.notifier).state = msg;
          ref.read(editingMessageProvider.notifier).state = null;
          break;
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
              onLongPressStart: (details) async {
                HapticFeedback.heavyImpact(); // phan hoi rung manh hon cho long press
                scaleNotifier.value = 0.95; // zoom-out slightly triggers effect

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
      child: _bubbleUI(msg, isMe, replyMsg: replyMsg),
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
                // thu hoi tin nhan
                socket.emit("revoke_message", {"msgId": msgId});

                if (!mounted) return;

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _bubbleUI(Message msg, bool isMe, {Message? replyMsg}) {
    // status logic
    Widget? statusIcon;
    if (isMe) {
      if (msg.msgStatusSending == MessageStatus.sending) {
        statusIcon = const Icon(
          Icons.access_time,
          size: 14,
          color: Colors.white70,
        );
      } else if (msg.msgStatusSending == MessageStatus.sent) {
        // sent check
        // check read
        final memCnt = widget
            .conversation
            .members
            .length; // kiem tra so luong members trong conversation
        final isRead =
            msg.seenBy.length >=
            memCnt -
                1; // neu la group chat thi all user seen moi hien thi icon done_all
        statusIcon = Icon(
          isRead ? Icons.done_all : Icons.check,
          size: 16,
          color: isRead ? Colors.blue.shade100 : Colors.white70,
        );
      }
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: const BoxConstraints(maxWidth: 260),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (replyMsg != null) _buildReplyPreview(replyMsg, isMe),

            // media content
            if (msg.type == MessageType.media && msg.media != null)
              _buildMediaContent(msg.media!, msg.msgStatusSending, isMe),

            if (msg.content != null)
              Padding(
                padding: msg.type == MessageType.media && msg.media != null
                    ? const EdgeInsets.only(top: 8)
                    : EdgeInsets.zero,
                child: Text(
                  msg.content!,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.textDark,
                    fontSize: 15,
                  ),
                ),
              ),

            // status icon
            if (isMe && statusIcon != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [const SizedBox(width: 4), statusIcon],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // build media content widget
  Widget _buildMediaContent(Media media, MessageStatus? status, bool isMe) {
    final isUploading = status == MessageStatus.sending;

    switch (media.type) {
      case MediaType.image:
        return _buildImageContent(media, isUploading, isMe);
      case MediaType.audio:
      case MediaType.file:
        return _buildFileContent(media, isUploading, isMe);
      default:
        return const SizedBox.shrink();
    }
  }

  // build image content
  Widget _buildImageContent(Media media, bool isUploading, bool isMe) {
    return GestureDetector(
      onTap: isUploading ? null : () => _viewImage(media.url),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              media.url,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, size: 50),
                );
              },
            ),
          ),
          if (isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // build file content
  Widget _buildFileContent(Media media, bool isUploading, bool isMe) {
    final extension = media.format?.toUpperCase() ?? 'FILE';
    final fileSize = media.size != null
        ? '${(media.size! / 1024).toStringAsFixed(1)} KB'
        : '';

    return GestureDetector(
      onTap: isUploading ? null : () => _openFile(media.url),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.white.withOpacity(0.2) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUploading)
              const SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isMe
                      ? Colors.white.withOpacity(0.3)
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  media.type == MediaType.audio
                      ? Icons.audiotrack
                      : Icons.insert_drive_file,
                  color: isMe ? Colors.white : Colors.blue.shade700,
                  size: 24,
                ),
              ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    extension,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isMe ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (fileSize.isNotEmpty)
                    Text(
                      fileSize,
                      style: TextStyle(
                        fontSize: 11,
                        color: isMe ? Colors.white70 : Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ),
            if (!isUploading) const SizedBox(width: 8),
            if (!isUploading)
              Icon(
                Icons.download,
                size: 18,
                color: isMe ? Colors.white70 : Colors.grey.shade600,
              ),
          ],
        ),
      ),
    );
  }

  // open file URL
  Future<void> _openFile(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Logger().e('Error opening file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi mở file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // view image in dialog
  void _viewImage(String url) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(color: Colors.transparent),
              ),
            ),

            Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  },
                ),
              ),
            ),

            Positioned(
              top: 40,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        );
      },
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
