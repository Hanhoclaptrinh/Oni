import 'package:flutter/material.dart';
import 'package:frontend/core/constants/AppColors.dart';

class ConversationScreen extends StatelessWidget {
  const ConversationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Conversations",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: "Search a friend",
                  hintStyle: const TextStyle(color: AppColors.textGrey),
                  border: InputBorder.none,
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: chatData.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return _buildConversationItem(context, chatData[index]);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildConversationItem(
    BuildContext context,
    Map<String, dynamic> chat,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatDetailScreen(user: chat)),
        );
      },
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: NetworkImage(chat['image']),
              backgroundColor: Colors.grey.shade200,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chat['message'],
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textGrey,
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

class ChatDetailScreen extends StatelessWidget {
  final Map<String, dynamic> user;
  const ChatDetailScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueBg,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 25,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(40)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 15),
                CircleAvatar(
                  radius: 22,
                  backgroundImage: NetworkImage(user['image']),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final isMe = messages[index]['isMe'];
                return _buildMessageBubble(messages[index]['text'], isMe);
              },
            ),
          ),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            color: Colors.transparent,
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
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Write a message...",
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  height: 50,
                  width: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
          boxShadow: [
            if (!isMe)
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
          ],
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
}

// --- DỮ LIỆU GIẢ (Mock Data) ---
final List<Map<String, dynamic>> chatData = [
  {
    "name": "Alif Emu",
    "message": "How your life is going?",
    "image": "https://i.pravatar.cc/150?img=11",
  },
  {
    "name": "Kabbo Vai",
    "message": "Wow, that's awesome!",
    "image": "https://i.pravatar.cc/150?img=12",
  },
  {
    "name": "Md Riyad",
    "message": "Bye-bye.",
    "image": "https://i.pravatar.cc/150?img=33",
  },
  {
    "name": "Kowser Jaman",
    "message": "It's a rainy day.",
    "image": "https://i.pravatar.cc/150?img=53",
  },
  {
    "name": "Rayhanul",
    "message": "wow, that's awesome",
    "image": "https://i.pravatar.cc/150?img=59",
  },

  // Thêm 5 người mới
  {
    "name": "Sabbir Ahmed",
    "message": "Are you coming today?",
    "image": "https://i.pravatar.cc/150?img=21",
  },
  {
    "name": "Nayeem Hasan",
    "message": "Let’s do it tomorrow.",
    "image": "https://i.pravatar.cc/150?img=41",
  },
  {
    "name": "Tania Akter",
    "message": "I'm on the way!",
    "image": "https://i.pravatar.cc/150?img=24",
  },
  {
    "name": "Shorna Islam",
    "message": "Don't forget to call me.",
    "image": "https://i.pravatar.cc/150?img=48",
  },
  {
    "name": "Mahadi Hasan",
    "message": "See you soon!",
    "image": "https://i.pravatar.cc/150?img=67",
  },
];

final List<Map<String, dynamic>> messages = [
  {"text": "Hello!", "isMe": false},
  {"text": "How your life is going?", "isMe": false},
  {
    "text":
        "Pretty good, working on a Flutter project! "
        "I'm trying to build a chat interface and learning more about state management.",
    "isMe": true,
  },
  {
    "text":
        "That sounds cool. Flutter is really powerful. "
        "What kind of features are you planning to add to your project?",
    "isMe": false,
  },
  {
    "text":
        "I'm thinking about adding animations, message reactions, "
        "and maybe even integrating Firebase for real-time chat.",
    "isMe": true,
  },
  {
    "text":
        "Wow, that sounds like a lot! But I'm sure you can do it. "
        "Firebase works great with Flutter.",
    "isMe": false,
  },
  {
    "text": "Yeah, I'm excited. Just trying to keep the UI clean and smooth.",
    "isMe": true,
  },
  {
    "text": "Nice! Let me know if you need help testing anything.",
    "isMe": false,
  },
];
