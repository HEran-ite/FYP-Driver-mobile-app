library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentCtrl = TextEditingController();

  String? _selectedImageName;
  String? _selectedImagePath;
  String? _selectedImageDataUrl;
  bool _posting = false;
  bool _didSubmit = false;

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _canPost =>
      _contentCtrl.text.trim().isNotEmpty && !_posting;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      // Aggressive size reduction so base64 fits common JSON body limits.
      maxWidth: 720,
      maxHeight: 720,
      imageQuality: 55,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    // Many backends default JSON body limit to ~100kb. Keep this well under that.
    // Base64 grows size by ~33%, plus JSON overhead.
    if (bytes.lengthInBytes > 70 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Image too large. Please choose a smaller image.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    final ext = picked.name.toLowerCase();
    final mime = ext.endsWith('.png')
        ? 'image/png'
        : ext.endsWith('.webp')
            ? 'image/webp'
            : 'image/jpeg';
    setState(() {
      _selectedImageName = picked.name;
      _selectedImagePath = picked.path;
      _selectedImageDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
    });
  }

  Future<void> _post() async {
    if (!_canPost) return;
    setState(() => _posting = true);
    try {
      // Backend stores `imageUrl` as string; we send a data URL (base64) so images
      // can be posted without a separate upload endpoint.
      context.read<CommunityBloc>().add(
            CommunityCreatePostRequested(
              title: _deriveTitle(_contentCtrl.text.trim()),
              content: _contentCtrl.text.trim(),
              imageUrl: _selectedImageDataUrl,
              imageFilePath: _selectedImagePath,
            ),
          );
      _didSubmit = true;
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  String _deriveTitle(String content) {
    final t = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (t.isEmpty) return 'Post';
    return t.length <= 50 ? t : '${t.substring(0, 50)}…';
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CommunityBloc, CommunityState>(
      listener: (context, state) {
        if (!_didSubmit) return;
        if (state is CommunityFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        }
        if (state is CommunityLoaded) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Create Post',
            style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Share with the community',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _contentCtrl,
                minLines: 8,
                maxLines: 12,
                decoration: const InputDecoration(
                  hintText: "What's on your mind?",
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Image'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm, horizontal: Spacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      _selectedImageName ?? 'Optional',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
              if (_selectedImagePath != null)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.file(
                        File(_selectedImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceMuted,
                          alignment: Alignment.center,
                          child: Text(
                            'Cannot preview image',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canPost ? _post : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canPost ? AppColors.textPrimary : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                    ),
                  ),
                  child: _posting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Post'),
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

