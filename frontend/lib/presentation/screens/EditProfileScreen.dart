import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/constants/AppColors.dart';
import 'package:frontend/core/utils/Enums.dart';
import 'package:frontend/data/models/User.dart';
import 'package:frontend/providers/CloudinaryProvider.dart';
import 'package:frontend/providers/UserProvider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:frontend/presentation/widgets/LoadingDialog.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  final ImagePicker _picker = ImagePicker();

  XFile? _newAvatar;
  XFile? _newCover;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.displayName);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isAvatar) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (isAvatar) {
          _newAvatar = image;
        } else {
          _newCover = image;
        }
      });
    }
  }

  Future<void> _saveProfile() async {
    // unfocus
    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tên hiển thị không được để trống')),
      );
      return;
    }

    setState(() => _isUpdating = true);
    LoadingDialog.show(context);

    try {
      String? avatarUrl = widget.user.avatarUrl;
      String? coverUrl = widget.user.coverImgUrl;
      final cloudinary = ref.read(cloudinaryServiceProvider);

      // upload avatar mới nếu có
      if (_newAvatar != null) {
        final res = await cloudinary.uploadFile(
          File(_newAvatar!.path),
          MediaType.image,
        );
        avatarUrl = res.url;
      }

      // upload cover mới nếu có
      if (_newCover != null) {
        final res = await cloudinary.uploadFile(
          File(_newCover!.path),
          MediaType.image,
        );
        coverUrl = res.url;
      }

      // chuẩn bị dữ liệu update
      final Map<String, dynamic> updateData = {
        'displayName': name,
        'bio': _bioController.text.trim(),
        'avatarUrl': avatarUrl,
        'coverImgUrl': coverUrl,
      };

      // update api
      await ref.read(userServiceProvider).updateProfile(updateData);

      // refresh user provider để cập nhật ui bên ngoài
      ref.invalidate(userProvider);

      if (mounted) {
        LoadingDialog.hide(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật hồ sơ thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        LoadingDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi cập nhật: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chỉnh sửa hồ sơ",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isUpdating ? null : _saveProfile,
            child: const Text(
              "Lưu",
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildImagesSection(),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: "Tên hiển thị",
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    controller: _bioController,
                    label: "Tiểu sử",
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesSection() {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // cover image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: GestureDetector(
              onTap: () => _pickImage(false),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _newCover != null
                      ? Image.file(File(_newCover!.path), fit: BoxFit.cover)
                      : Image.network(
                          widget.user.coverImgUrl ??
                              "https://images.unsplash.com/photo-1579546929518-9e396f3cc809?auto=format",
                          fit: BoxFit.cover,
                        ),
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white70,
                        size: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // avatar image
          Positioned(
            bottom: 0,
            child: GestureDetector(
              onTap: () => _pickImage(true),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _newAvatar != null
                          ? FileImage(File(_newAvatar!.path))
                          : NetworkImage(
                                  widget.user.avatarUrl ??
                                      "https://i.pravatar.cc/300?img=12",
                                )
                                as ImageProvider,
                    ),
                  ),
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF7F7F9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
