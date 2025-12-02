import 'package:flutter/material.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/presentation/components/FriendActionCard.dart';

// --- WIDGET CHÍNH ---

class FriendScreen extends StatelessWidget {
  const FriendScreen({super.key});

  // Widget tiêu đề nhỏ cho gọn code
  Widget _buildSectionTitle(String title, String? count) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 8.0),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark, // Dùng AppColors từ import
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.deleteRed, // Dùng AppColors từ import
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
      ),
    );
  }

  // Widget SliverAppBar để tạo hiệu ứng cuộn (collapsing/stretching header)
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true, // Giữ thanh AppBar ở trên cùng khi cuộn
      floating: false, // Thanh sẽ xuất hiện lại ngay khi cuộn xuống
      expandedHeight: 80, // Chiều cao mở rộng lớn hơn
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.black),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true, // <-- QUAN TRỌNG: Giữ tiêu đề dính bên trái
        // titlePadding được điều chỉnh để tiêu đề nằm ở vị trí góc trái-dưới khi mở rộng.
        titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
        title: const Text(
          "Friends",
          style: TextStyle(
            // Tiêu đề thu gọn (pinned) sẽ có cỡ chữ này
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mock (tương tự như trong code của bạn)
    final friendRequests = [
      {
        "name": "Wade Warren",
        "avatarUrl": "https://i.pravatar.cc/150?img=11",
        "subtitle": "12 mutual friends",
      },
      {
        "name": "Jane Cooper",
        "avatarUrl": "https://i.pravatar.cc/150?img=5",
        "subtitle": "5 mutual friends",
      },
    ];

    final suggestions = [
      {
        "name": "Robert Fox",
        "avatarUrl": "https://i.pravatar.cc/150?img=8",
        "subtitle": "Works at Google",
      },
      {
        "name": "Jenny Wilson",
        "avatarUrl": "https://i.pravatar.cc/150?img=9",
        "subtitle": "University of Toronto",
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // Thay thế AppBar bằng body chứa CustomScrollView
      body: CustomScrollView(
        // <-- Dùng CustomScrollView để chứa các slivers
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. SliverAppBar (Thanh điều hướng cuộn)
          _buildSliverAppBar(),

          // 2. Nội dung chính: bọc trong SliverToBoxAdapter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- SECTION 1: LỜI MỜI KẾT BẠN ---
                  _buildSectionTitle(
                    "Friend Requests",
                    friendRequests.length.toString(),
                  ),
                  const SizedBox(height: 5),

                  ...friendRequests
                      .map(
                        (user) => FriendActionCard(
                          name: user["name"]!,
                          avatarUrl: user["avatarUrl"]!,
                          subtitle: user["subtitle"]!,
                          isRequest: true,
                          onConfirm: () => print("Confirmed ${user["name"]}"),
                          onDelete: () => print("Deleted ${user["name"]}"),
                        ),
                      )
                      .toList(),

                  const Divider(
                    height: 35,
                    thickness: 0.5,
                    color: AppColors.lightGreyBackground,
                  ), // Dùng AppColors từ import
                  // --- SECTION 2: GỢI Ý KẾT BẠN ---
                  _buildSectionTitle("People You May Know", null),
                  const SizedBox(height: 5),

                  ...suggestions
                      .map(
                        (user) => FriendActionCard(
                          name: user["name"]!,
                          avatarUrl: user["avatarUrl"]!,
                          subtitle: user["subtitle"]!,
                          isRequest: false, // Suggestion
                          onConfirm: () => print("Added ${user["name"]}"),
                          onDelete: () => print("Removed ${user["name"]}"),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
