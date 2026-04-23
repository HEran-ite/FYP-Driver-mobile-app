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
import '../../domain/entities/post.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key, this.initialPost});

  final Post? initialPost;

  bool get isEditing => initialPost != null;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  static const int _maxEncodedImagePayloadBytes = 85 * 1024;
  final _contentCtrl = TextEditingController();

  final List<String> _imageDataUrls = <String>[];
  bool _posting = false;
  bool _didSubmit = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPost;
    if (initial != null) {
      _contentCtrl.text = initial.content;
      _imageDataUrls.addAll(initial.imageUrls);
    }
  }

  @override
  void dispose() {
    _contentCtrl.dispose();
    super.dispose();
  }

  bool get _canPost => _contentCtrl.text.trim().isNotEmpty && !_posting;

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      // Aggressive size reduction so base64 fits common JSON body limits.
      maxWidth: 720,
      maxHeight: 720,
      imageQuality: 55,
    );
    if (picked.isEmpty) return;

    final converted = <String>[];
    for (final x in picked) {
      final bytes = await x.readAsBytes();
      // Keep each image small to avoid request body limits.
      if (bytes.lengthInBytes > 70 * 1024) continue;
      final ext = x.name.toLowerCase();
      final mime = ext.endsWith('.png')
          ? 'image/png'
          : ext.endsWith('.webp')
          ? 'image/webp'
          : 'image/jpeg';
      converted.add('data:$mime;base64,${base64Encode(bytes)}');
    }
    if (converted.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected images were too large.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    final existingCount = _imageDataUrls.length;
    final accepted = <String>[..._imageDataUrls];
    for (final image in converted) {
      final candidate = <String>[...accepted, image];
      if (_encodedImagesSize(candidate) > _maxEncodedImagePayloadBytes) {
        break;
      }
      accepted.add(image);
    }

    if (!mounted) return;
    if (accepted.length == _imageDataUrls.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selected images exceed server size limit.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    setState(() => _imageDataUrls
      ..clear()
      ..addAll(accepted));

    if (accepted.length < existingCount + converted.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Some images were skipped to fit server upload size.'),
        ),
      );
    }
  }

  Future<void> _post() async {
    if (!_canPost) return;
    setState(() => _posting = true);
    try {
      final content = _contentCtrl.text.trim();
      if (_encodedImagesSize(_imageDataUrls) > _maxEncodedImagePayloadBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images are too large. Remove some images and try again.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }
      final serializedImages = _serializeImages(forEdit: widget.isEditing);
      if (widget.isEditing && widget.initialPost != null) {
        context.read<CommunityBloc>().add(
          CommunityEditPostRequested(
            id: widget.initialPost!.id,
            title: _deriveTitle(content),
            content: content,
            imageUrl: serializedImages,
          ),
        );
      } else {
        context.read<CommunityBloc>().add(
          CommunityCreatePostRequested(
            title: _deriveTitle(content),
            content: content,
            imageUrl: serializedImages,
            imageFilePath: null,
          ),
        );
      }
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

  String? _serializeImages({required bool forEdit}) {
    if (_imageDataUrls.isEmpty) {
      // In edit mode, send an explicit empty array so backend clears old images.
      return forEdit ? '[]' : null;
    }
    if (_imageDataUrls.length == 1) return _imageDataUrls.first;
    return jsonEncode(_imageDataUrls);
  }

  int _encodedImagesSize(List<String> images) {
    if (images.isEmpty) return 0;
    if (images.length == 1) return images.first.length;
    return jsonEncode(images).length;
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
            widget.isEditing ? 'Edit Post' : 'Create Post',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.isEditing
                    ? 'Update your post and photos'
                    : 'Share with the community',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
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
                    onPressed: _pickImages,
                    icon: const Icon(Icons.image_outlined),
                    label: const Text('Add photos'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.sm,
                        horizontal: Spacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          BorderRadiusValues.lg,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      _imageDataUrls.isEmpty
                          ? 'Optional'
                          : '${_imageDataUrls.length} selected',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (_imageDataUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: Spacing.sm),
                  child: SizedBox(
                    height: 110,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageDataUrls.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(width: Spacing.sm),
                      itemBuilder: (_, i) {
                        final image = _imageDataUrls[i];
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                BorderRadiusValues.lg,
                              ),
                              child: SizedBox(
                                width: 140,
                                child: _DataOrUrlImage(url: image),
                              ),
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: InkWell(
                                onTap: () =>
                                    setState(() => _imageDataUrls.removeAt(i)),
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(2),
                                  child: const Icon(
                                    Icons.close_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canPost ? _post : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _canPost
                        ? AppColors.textPrimary
                        : Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: Spacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        BorderRadiusValues.lg,
                      ),
                    ),
                  ),
                  child: _posting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.isEditing ? 'Save Changes' : 'Post'),
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

class _DataOrUrlImage extends StatelessWidget {
  const _DataOrUrlImage({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:image/')) {
      final idx = url.indexOf('base64,');
      if (idx != -1) {
        try {
          final bytes = base64Decode(url.substring(idx + 'base64,'.length));
          return Image.memory(bytes, fit: BoxFit.cover);
        } catch (_) {}
      }
    }
    if (url.startsWith('/')) {
      return Image.file(
        File(url),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const ColoredBox(color: AppColors.surfaceMuted),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const ColoredBox(color: AppColors.surfaceMuted),
    );
  }
}
