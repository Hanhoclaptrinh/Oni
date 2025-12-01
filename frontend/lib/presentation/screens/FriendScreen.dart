import 'package:flutter/material.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/presentation/components/FriendActionCard.dart';

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Friends",
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SECTION 1: LỜI MỜI KẾT BẠN ---
            _buildSectionTitle("Friend Requests", "3"),
            const SizedBox(height: 15),

            // Item 1: Lời mời
            FriendActionCard(
              name: "Wade Warren",
              avatarUrl: "https://i.pravatar.cc/150?img=11",
              subtitle: "12 mutual friends",
              isRequest: true, // Đây là Request
              onConfirm: () => print("Confirmed Wade"),
              onDelete: () => print("Deleted Wade"),
            ),

            // Item 2: Lời mời
            FriendActionCard(
              name: "Jane Cooper",
              avatarUrl: "https://i.pravatar.cc/150?img=5",
              subtitle: "5 mutual friends",
              isRequest: true,
              onConfirm: () => print("Confirmed Jane"),
              onDelete: () => print("Deleted Jane"),
            ),

            const SizedBox(height: 25),

            // --- SECTION 2: GỢI Ý KẾT BẠN ---
            _buildSectionTitle("People You May Know", null),
            const SizedBox(height: 15),

            // Item 3: Gợi ý (isRequest = false)
            FriendActionCard(
              name: "Robert Fox",
              avatarUrl: "https://i.pravatar.cc/150?img=8",
              subtitle: "Works at Google",
              isRequest: false, // Đây là Suggestion
              onConfirm: () => print("Added Robert"),
              onDelete: () => print("Removed Robert"),
            ),
            FriendActionCard(
              name: "Jenny Wilson",
              avatarUrl: "https://i.pravatar.cc/150?img=9",
              subtitle: "University of Toronto",
              isRequest: false,
              onConfirm: () => print("Added Jenny"),
              onDelete: () => print("Removed Jenny"),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tiêu đề nhỏ cho gọn code
  Widget _buildSectionTitle(String title, String? count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        if (count != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
