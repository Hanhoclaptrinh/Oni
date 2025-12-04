import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/data/models/User.dart';
import 'package:frontend/presentation/controllers/ProfileProvider.dart';
import 'package:intl/intl.dart';
import 'package:frontend/core/constants/AppColors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(meProvider);

    return me.when(
      data: (user) {
        return Scaffold(
          backgroundColor: AppColors.scaffoldBg,
          extendBodyBehindAppBar: true,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context, user),
                const SizedBox(height: 60),
                _buildUserInfo(user),
                const SizedBox(height: 20),
                _buildActionButtons(),
                const SizedBox(height: 25),
                _buildDetailsSection(user),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text("Lỗi: $e"))),
    );
  }
  
  Widget _buildHeader(BuildContext context, User user) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          height: 220,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format",
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          child: CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(
              user.avatarUrl ?? "https://i.pravatar.cc/300?img=12",
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfo(User user) {
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
            if (user.emailVerified)
              const Icon(Icons.verified, color: AppColors.primaryBlue)
            else
              const Icon(Icons.gpp_bad_rounded, color: Colors.orange),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          "@${user.username}",
          style: const TextStyle(fontSize: 16, color: AppColors.textGrey),
        ),
      ],
    );
  }

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
              ),
              child: const Text("Edit Profile"),
            ),
          ),
          const SizedBox(width: 15),
          IconButton(icon: const Icon(Icons.share_rounded), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(User user) {
    final joinedDate = DateFormat('MMMM yyyy').format(user.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "About Me",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              user.bio?.isNotEmpty == true ? user.bio! : "Không có tiểu sử",
              style: const TextStyle(color: AppColors.textGrey),
            ),
            const Divider(height: 30),

            _buildInfoRow(
              icon: Icons.email_outlined,
              label: "Email",
              value: user.email,
              isVerified: user.emailVerified,
            ),
            const SizedBox(height: 20),
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
        Icon(icon, color: AppColors.primaryBlue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textGrey)),
            Row(
              children: [
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (isVerified != null && !isVerified)
                  const Text(
                    "  (Unverified)",
                    style: TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
