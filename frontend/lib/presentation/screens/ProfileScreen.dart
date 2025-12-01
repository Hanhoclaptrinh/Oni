import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm package intl để format ngày tháng
import 'package:frontend/core/constants/AppColors.dart';

// --- MOCK MODEL (Mô phỏng dữ liệu từ DB) ---
class UserProfile {
  final String username;
  final String email;
  final String displayName;
  final String role;
  final String? avatarUrl;
  final String bio;
  final bool emailVerified;
  final DateTime createdAt;

  UserProfile({
    required this.username,
    required this.email,
    required this.displayName,
    required this.role,
    this.avatarUrl,
    required this.bio,
    required this.emailVerified,
    required this.createdAt,
  });
}

class ProfileScreen extends StatelessWidget {
  final UserProfile user;
  ProfileScreen({super.key, required this.user});

  // Dữ liệu giả lập từ ảnh đại ca gửi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      extendBodyBehindAppBar: true, // Để ảnh bìa tràn lên status bar
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            const SizedBox(height: 60), // Khoảng trống cho Avatar lấn xuống
            _buildUserInfo(),
            const SizedBox(height: 20),
            _buildActionButtons(),
            const SizedBox(height: 25),
            _buildDetailsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 1. Header chứa Ảnh bìa + Avatar
  Widget _buildHeader(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Cho phép Avatar nằm đè lên biên giới hạn
      alignment: Alignment.center,
      children: [
        // Ảnh bìa (Cover Image)
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80",
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.3), Colors.transparent],
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
          ),
        ),
        // Avatar
        Positioned(
          bottom: -50,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: user.avatarUrl != null
                  ? NetworkImage(user.avatarUrl!)
                  : const NetworkImage(
                      "https://i.pravatar.cc/300?img=12",
                    ), // Avatar mặc định
            ),
          ),
        ),
      ],
    );
  }

  // 2. Tên, Username, Role
  Widget _buildUserInfo() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(width: 8),
            // Tích xanh (Chỉ hiện nếu emailVerified = true)
            if (user.emailVerified)
              const Icon(Icons.verified, color: AppColors.primaryBlue, size: 22)
            else
              Tooltip(
                message: "Email not verified",
                child: Icon(
                  Icons.gpp_bad_rounded,
                  color: Colors.orange.shade400,
                  size: 22,
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          "@${user.username}",
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.textGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: user.role == "admin"
                ? Colors.red.withOpacity(0.1)
                : AppColors.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.role.toUpperCase(),
            style: TextStyle(
              color: user.role == "admin" ? Colors.red : AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // 3. Nút Edit Profile
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
                shadowColor: AppColors.primaryBlue.withOpacity(0.4),
              ),
              child: const Text(
                "Edit Profile",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_rounded, color: AppColors.textDark),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // 4. Phần thông tin chi tiết (About, Email, Joined)
  Widget _buildDetailsSection() {
    // Format ngày tham gia
    final joinedDate = DateFormat('MMMM yyyy').format(user.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About Me",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              user.bio.isNotEmpty
                  ? user.bio
                  : "Hello! I'm new here and excited to connect.",
              style: const TextStyle(color: AppColors.textGrey, height: 1.5),
            ),
            const Divider(height: 30, color: Color(0xFFEEEEEE)),

            // Email Row
            _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: user.email,
              isVerified: user.emailVerified,
            ),
            const SizedBox(height: 20),

            // Joined Date Row
            _buildInfoRow(
              icon: Icons.calendar_today_rounded,
              label: "Joined",
              value: joinedDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool? isVerified,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.scaffoldBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryBlue, size: 20),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                if (isVerified != null && !isVerified) ...[
                  const SizedBox(width: 5),
                  const Text(
                    "(Unverified)",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }
}
