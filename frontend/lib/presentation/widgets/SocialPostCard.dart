import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SocialPostCard extends StatelessWidget {
  // Các tham số đầu vào
  final String userName;
  final String userAvatarUrl;
  final String timeAgo;
  final String? textContent;
  final List<String>? imageUrls;
  final String? videoUrl; // Thêm videoUrl
  final int likeCount;
  final int commentCount;
  final VoidCallback? onLikeTap; // Thêm callback để xử lý sự kiện
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const SocialPostCard({
    Key? key,
    required this.userName,
    required this.userAvatarUrl,
    required this.timeAgo,
    this.textContent,
    this.imageUrls,
    this.videoUrl,
    required this.likeCount,
    required this.commentCount,
    this.onLikeTap,
    this.onCommentTap,
    this.onShareTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Logic kiểm tra dữ liệu
    bool hasImages = imageUrls != null && imageUrls!.isNotEmpty;
    bool hasVideo = videoUrl != null && videoUrl!.isNotEmpty;
    bool hasText = textContent != null && textContent!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        // Thêm shadow nhẹ hoặc border dưới nếu muốn tách biệt các post
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(userAvatarUrl),
                  backgroundColor: Colors.grey[200],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                  onPressed: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 2. Image Section (Chỉ render nếu có ảnh)
          if (hasImages)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _PostImageSlider(imageUrls: imageUrls!),
            ),

          // 3. Video Section (Chỉ render nếu có video)
          if (hasVideo)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildVideoPlaceholder(context),
            ),

          // 3. Content Section (Chỉ render nếu có text)
          if (hasText)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  textContent!,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF4A4A4A),
                    height: 1.4,
                  ),
                ),
              ),
            ),

          // 4. Footer Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                InkWell(
                  onTap: onLikeTap,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/heart.svg",
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.redAccent,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$likeCount",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                InkWell(
                  onTap: onCommentTap,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/comment.svg",
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "$commentCount",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: onShareTap,
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        "assets/images/share.svg",
                        width: 24,
                        height: 24,
                        colorFilter: const ColorFilter.mode(
                          Colors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PostImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const _PostImageSlider({required this.imageUrls});

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final images = widget.imageUrls;

    // 1 ảnh → không cần PageView
    if (images.length == 1) {
      return _buildImage(images.first);
    }

    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: images.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildImage(images[index]);
            },
          ),
        ),

        // indicator 1/5
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${_currentIndex + 1}/${images.length}",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImage(String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Image.network(
        url,
        width: double.infinity,
        height: 300,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 300,
          color: Colors.grey[200],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}
