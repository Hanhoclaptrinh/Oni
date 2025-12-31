import 'package:flutter/material.dart';
import 'package:frontend/presentation/widgets/SocialPostCard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. Header (Explore + Button +)
          _buildSliverAppBar(),

          // 2. Search Bar (Dùng SliverToBoxAdapter để nó nằm dưới Header và cuộn theo list)
          _buildSearchBar(),

          // 3. Danh sách bài viết
          _buildPostList(),
        ],
      ),
    );
  }

  // === PHẦN 1: APP BAR (Đã chỉnh sửa để thêm viền/nền cho icon +) ===
  Widget _buildSliverAppBar() {
    // Giả lập AppColors.textDark thành Colors.black và AppColors.background (nếu cần)
    const Color appTextDark = Colors.black;

    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      pinned: true,
      // Thay đổi floating: false thành true nếu muốn thanh cuộn xuống một chút là hiện lại
      floating:
          true, // Thường dùng floating: true cho các feed (mình để lại true cho demo)
      snap: true, // Nếu floating là true, nên thêm snap: true để cuộn mượt hơn
      expandedHeight: 80,

      // PHẦN ĐÃ CHỈNH SỬA: Thêm nền/viền cho icon +
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
          child: Container(
            // Chiều rộng và chiều cao bằng nhau để tạo hình tròn
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(
                0xFFF7F7F9,
              ), // Màu nền xám nhạt (Light Gray Background)
              shape: BoxShape.circle,
              // Thêm border nếu bạn muốn viền ngoài rõ ràng hơn
              border: Border.all(color: Colors.grey.shade200, width: 1),
            ),
            child: IconButton(
              padding:
                  EdgeInsets.zero, // Loại bỏ padding mặc định của IconButton
              icon: const Icon(Icons.add_rounded, color: appTextDark),
              iconSize: 24, // Kích thước icon
              onPressed: () {
                print("Tạo bài viết mới");
              },
            ),
          ),
        ),
      ],

      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false, // Để tiêu đề luôn dính bên trái
        titlePadding: const EdgeInsets.only(left: 20.0, bottom: 16.0),
        title: const Text(
          "Explore",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: appTextDark,
          ),
        ),
      ),
    );
  }

  // === PHẦN 2: THANH TÌM KIẾM (SEARCH BAR) ===
  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF7F7F9), // Màu xám nhạt nền search
            borderRadius: BorderRadius.circular(28),
          ),
          child: const TextField(
            textAlignVertical:
                TextAlignVertical.center, // Căn giữa nội dung nhập
            decoration: InputDecoration(
              // Cài đặt này loại bỏ viền mặc định của TextField
              border: InputBorder.none,

              // Icon bên trái
              prefixIcon: Icon(Icons.search_rounded, color: Colors.black),

              // Text gợi ý (Placeholder)
              hintText: "Search",
              hintStyle: TextStyle(
                color: Color(0xFFC0C0C0), // Màu chữ nhạt hơn
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),

              // Padding bên trong
              contentPadding: EdgeInsets.symmetric(vertical: 15),
            ),
            style: TextStyle(color: Colors.black87, fontSize: 16),
            // Bạn có thể thêm controller, onChanged, onSubmit tại đây
          ),
        ),
      ),
    );
  }

  // === PHẦN 3: DANH SÁCH BÀI VIẾT ===
  Widget _buildPostList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Trả về Component SocialPostCard đã tách
          // Demo 3 bài viết khác nhau
          if (index == 0) {
            return SocialPostCard(
              userName: "Nettie Fernandez",
              userAvatarUrl: "https://i.pravatar.cc/150?img=5",
              timeAgo: "Just now",
              textContent:
                  "Thinking about overseas adventure travel? Have you put any thought into the best places",
              imageUrls: const ["https://picsum.photos/600/600"],
              likeCount: 439,
              commentCount: 34,
            );
          } else if (index == 1) {
            return SocialPostCard(
              userName: "Design World",
              userAvatarUrl: "https://i.pravatar.cc/150?img=12",
              timeAgo: "2 hours ago",
              textContent:
                  "Minimalist UI design is trending right now. Check out this clean interface.",
              imageUrls: null, // Không có ảnh
              likeCount: 120,
              commentCount: 15,
            );
          } else {
            return SocialPostCard(
              userName: "Photography Hub",
              userAvatarUrl: "https://i.pravatar.cc/150?img=3",
              timeAgo: "1 day ago",
              textContent: null, // Không có text
              imageUrls: const [
                "https://picsum.photos/600/400",
                "https://picsum.photos/600/401",
              ],
              likeCount: 890,
              commentCount: 56,
            );
          }
        },
        childCount: 10, // Giả lập 10 bài viết
      ),
    );
  }
}
