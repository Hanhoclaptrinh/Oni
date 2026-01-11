import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/utils/Enums.dart';
import 'package:frontend/data/models/Post.dart';
import 'package:frontend/presentation/widgets/LoadingDialog.dart';
import 'package:frontend/providers/CloudinaryProvider.dart';
import 'package:frontend/providers/PostProvider.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:image_picker/image_picker.dart';

class PostScreen extends ConsumerStatefulWidget {
  const PostScreen({super.key});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  PostVisibility _visibility = PostVisibility.public;
  bool _isPosting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _submitPost() async {
    // validate entry data
    if (_contentController.text.trim().isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập nội dung hoặc chọn ảnh")),
      );
      return;
    }

    // unfocus keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isPosting = true);
    LoadingDialog.show(context);

    try {
      List<String> imageUrls = [];

      // parallel upload
      if (_selectedImages.isNotEmpty) {
        final cloudinary = ref.read(cloudinaryServiceProvider);

        // list items to upload
        final uploadTasks = _selectedImages.map((image) {
          return cloudinary.uploadFile(File(image.path), MediaType.image);
        });

        // chay tat ca cung luc va doi hoan thanh
        // thay vi doi tung cai
        final results = await Future.wait(uploadTasks);

        // lay url tu ket qua
        imageUrls = results.map((e) => e.url).toList();
      }

      final post = Post(
        content: _contentController.text.trim(),
        images: imageUrls,
        visibility: _visibility.name,
      );

      await ref.read(postServiceProvider).createPost(post);

      if (mounted) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã đăng bài viết thành công!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi khi đăng bài: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    // kiem tra xem co text hoac anh khong de enable nut dang
    final bool canPost =
        _contentController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Tạo bài viết",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: AnimatedOpacity(
                opacity: canPost ? 1.0 : 0.5,
                duration: const Duration(milliseconds: 200),
                child: ElevatedButton(
                  onPressed: (_isPosting || !canPost) ? null : _submitPost,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          "Đăng",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) => _buildBody(user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text("Lỗi tải thông tin: $e")),
      ),
    );
  }

  Widget _buildBody(dynamic user) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserInfo(user),
                const SizedBox(height: 16),
                TextField(
                  controller: _contentController,
                  maxLines: null,
                  onChanged: (val) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: "Bạn đang nghĩ gì?",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: const TextStyle(fontSize: 20, height: 1.5),
                ),
                const SizedBox(height: 20),
                if (_selectedImages.isNotEmpty) _buildImagePreview(),
              ],
            ),
          ),
        ),
        _buildBottomToolbar(),
      ],
    );
  }

  Widget _buildUserInfo(dynamic user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.grey[200],
          backgroundImage:
              (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
              ? NetworkImage(user.avatarUrl!)
              : NetworkImage(
                      "https://ui-avatars.com/api/?name=${user.displayName}",
                    )
                    as ImageProvider,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              user.displayName ?? "Người dùng",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            _buildVisibilitySelector(),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilitySelector() {
    return GestureDetector(
      onTap: _showVisibilityPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getIconForVisibility(_visibility),
              size: 14,
              color: Colors.grey[700],
            ),
            const SizedBox(width: 4),
            Text(
              _getTextForVisibility(_visibility),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down, size: 16, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }

  // helper
  IconData _getIconForVisibility(PostVisibility v) {
    switch (v) {
      case PostVisibility.public:
        return Icons.public;
      case PostVisibility.friends:
        return Icons.people;
      case PostVisibility.private:
        return Icons.lock;
      default:
        return Icons.public;
    }
  }

  String _getTextForVisibility(PostVisibility v) {
    switch (v) {
      case PostVisibility.public:
        return "Công khai";
      case PostVisibility.friends:
        return "Bạn bè";
      case PostVisibility.private:
        return "Riêng tư";
      default:
        return "Công khai";
    }
  }

  void _showVisibilityPicker() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Ai có thể xem bài viết này?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 10),
                _buildVisibilityItem(
                  PostVisibility.public,
                  Icons.public,
                  "Công khai",
                  "Bất kỳ ai cũng có thể xem",
                ),
                _buildVisibilityItem(
                  PostVisibility.friends,
                  Icons.people,
                  "Bạn bè",
                  "Chỉ bạn bè mới có thể xem",
                ),
                _buildVisibilityItem(
                  PostVisibility.private,
                  Icons.lock,
                  "Riêng tư",
                  "Chỉ mình tôi",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVisibilityItem(
    PostVisibility value,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: _visibility == value
          ? const Icon(Icons.check_circle, color: Colors.blueAccent)
          : null,
      onTap: () {
        setState(() => _visibility = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildImagePreview() {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _selectedImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.file(
                    File(_selectedImages[index].path),
                    width: 200,
                    height: 250,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildToolbarAction(
              Icons.image_outlined,
              "Ảnh/Video",
              Colors.green,
              _pickImages,
            ),
            const SizedBox(width: 20),
            _buildToolbarAction(
              Icons.emoji_emotions_outlined,
              "Cảm xúc",
              Colors.amber,
              () {
                // emoji logic
              },
            ),
            const SizedBox(width: 20),
            _buildToolbarAction(
              Icons.location_on_outlined,
              "Vị trí",
              Colors.redAccent,
              () {
                // location logic
              },
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              icon: const Icon(
                Icons.keyboard_hide_outlined,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarAction(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 28),
    );
  }
}
