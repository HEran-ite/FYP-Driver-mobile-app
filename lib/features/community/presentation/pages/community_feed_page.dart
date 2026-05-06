library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/post.dart';
import '../bloc/community_bloc.dart';
import '../bloc/community_event.dart';
import '../bloc/community_state.dart';
import 'create_post_page.dart';

class CommunityFeedPage extends StatefulWidget {
  const CommunityFeedPage({super.key});

  @override
  State<CommunityFeedPage> createState() => _CommunityFeedPageState();
}

class _CommunityFeedPageState extends State<CommunityFeedPage> {
  final _searchCtrl = TextEditingController();
  Timer? _searchDebounce;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(const CommunityLoadRequested());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 320), () {
      if (!mounted) return;
      context.read<CommunityBloc>().add(CommunitySearchRequested(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final myId = auth is AuthAuthenticated ? auth.user.id : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/community'),
      appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
      body: BlocListener<CommunityBloc, CommunityState>(
        listenWhen: (previous, current) =>
            current is CommunityFailure && previous is CommunityLoaded,
        listener: (context, state) {
          if (state is! CommunityFailure) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.danger,
            ),
          );
        },
        child: BlocBuilder<CommunityBloc, CommunityState>(
          builder: (context, state) {
            final loaded = state is CommunityLoaded ? state : null;
            final posts = loaded?.posts ?? const <Post>[];
            final bookmarked = loaded?.bookmarkedPosts ?? const <Post>[];
            final filtered = _applyFilters(
              posts,
              bookmarkedPosts: bookmarked,
              myId: myId,
              tab: _tab,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.lg,
                    Spacing.sm,
                    Spacing.lg,
                    0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Community',
                        style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Connect with car owners',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      _SearchField(
                        controller: _searchCtrl,
                        onChanged: _onSearchChanged,
                      ),
                      const SizedBox(height: Spacing.sm),
                      _CommunityTabs(
                        value: _tab,
                        onChanged: (i) => setState(() => _tab = i),
                      ),
                      const SizedBox(height: Spacing.sm),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            final bloc = context.read<CommunityBloc>();
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => BlocProvider.value(
                                  value: bloc,
                                  child: const CreatePostPage(),
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_rounded, size: 18),
                          label: const Text('Create Post'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.textPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: Spacing.sm,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                BorderRadiusValues.lg,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<CommunityBloc>().add(
                        const CommunityRefreshRequested(),
                      );
                    },
                    child: Builder(
                      builder: (_) {
                        if (state is CommunityLoading ||
                            state is CommunityInitial) {
                          return ListView(
                            children: const [
                              SizedBox(height: 160),
                              Center(child: CircularProgressIndicator()),
                            ],
                          );
                        }
                        if (state is CommunityFailure && loaded == null) {
                          return ListView(
                            padding: const EdgeInsets.all(Spacing.lg),
                            children: [
                              const SizedBox(height: 120),
                              Text(
                                state.message,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.danger,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }
                        if (filtered.isEmpty) {
                          return ListView(
                            padding: const EdgeInsets.all(Spacing.lg),
                            children: [
                              const SizedBox(height: 120),
                              Text(
                                'No posts found.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          );
                        }

                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            Spacing.lg,
                            0,
                            Spacing.lg,
                            Spacing.lg,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: Spacing.md),
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            final isMine =
                                myId.isNotEmpty && p.author.id == myId;
                            return _PostCard(
                              post: p,
                              isMine: isMine,
                              onDelete: () {
                                context.read<CommunityBloc>().add(
                                  CommunityDeletePostRequested(p.id),
                                );
                              },
                              onEdit: () => _openEditPage(p),
                              onLike: () {
                                context.read<CommunityBloc>().add(
                                  CommunityToggleLikeRequested(p.id),
                                );
                              },
                              onBookmark: () {
                                context.read<CommunityBloc>().add(
                                  CommunityToggleBookmarkRequested(p.id),
                                );
                              },
                              onComment: () => _showCommentsSheet(p),
                              onReport: () => _showReportDialog(p),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: const _CommunityBottomNavBar(),
    );
  }

  List<Post> _applyFilters(
    List<Post> posts, {
    required List<Post> bookmarkedPosts,
    required String myId,
    required int tab,
  }) {
    final source = switch (tab) {
      2 => bookmarkedPosts,
      _ => posts,
    };
    final base = _applySearch(source);
    if (tab == 1) {
      if (myId.isEmpty) return const <Post>[];
      return base.where((p) => p.author.id == myId).toList();
    }
    return base;
  }

  List<Post> _applySearch(List<Post> posts) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return posts;
    return posts
        .where(
          (p) {
            final ownerFullName = '${p.author.firstName} ${p.author.lastName}'
                .trim()
                .toLowerCase();
            return p.title.toLowerCase().contains(q) ||
                p.content.toLowerCase().contains(q) ||
                p.author.displayName.toLowerCase().contains(q) ||
                p.author.firstName.toLowerCase().contains(q) ||
                p.author.lastName.toLowerCase().contains(q) ||
                ownerFullName.contains(q);
          },
        )
        .toList();
  }

  void _openEditPage(Post post) {
    final bloc = context.read<CommunityBloc>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: CreatePostPage(initialPost: post),
        ),
      ),
    );
  }

  Future<void> _showReportDialog(Post post) async {
    final detailsCtrl = TextEditingController();
    String reason = 'SPAM';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return AlertDialog(
              title: const Text('Report Post'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: reason,
                    items: const [
                      DropdownMenuItem(value: 'SPAM', child: Text('Spam')),
                      DropdownMenuItem(
                        value: 'HARASSMENT',
                        child: Text('Harassment'),
                      ),
                      DropdownMenuItem(
                        value: 'HATE_SPEECH',
                        child: Text('Hate speech'),
                      ),
                      DropdownMenuItem(
                        value: 'FALSE_INFORMATION',
                        child: Text('False information'),
                      ),
                      DropdownMenuItem(
                        value: 'VIOLENCE',
                        child: Text('Violence'),
                      ),
                      DropdownMenuItem(
                        value: 'NUDITY_OR_SEXUAL_CONTENT',
                        child: Text('Nudity or sexual content'),
                      ),
                      DropdownMenuItem(
                        value: 'SCAM_OR_FRAUD',
                        child: Text('Scam or fraud'),
                      ),
                      DropdownMenuItem(value: 'OTHER', child: Text('Other')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => reason = v);
                    },
                  ),
                  if (reason == 'OTHER') ...[
                    const SizedBox(height: Spacing.sm),
                    TextField(
                      controller: detailsCtrl,
                      minLines: 3,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Tell us what is wrong',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Report'),
                ),
              ],
            );
          },
        );
      },
    );
    if (ok != true) return;
    if (!mounted) return;
    context.read<CommunityBloc>().add(
      CommunityReportPostRequested(
        postId: post.id,
        reason: reason,
        details: detailsCtrl.text.trim().isEmpty
            ? null
            : detailsCtrl.text.trim(),
      ),
    );
  }

  Future<void> _showCommentsSheet(Post post) async {
    final bloc = context.read<CommunityBloc>();
    bloc.add(CommunityCommentsLoadRequested(post.id));
    final inputCtrl = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              left: Spacing.lg,
              right: Spacing.lg,
              top: Spacing.sm,
            ),
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.72,
              child: Column(
                children: [
                  Text(
                    'Comments',
                    style: AppTextStyles.titleMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Expanded(
                    child: BlocBuilder<CommunityBloc, CommunityState>(
                      builder: (context, state) {
                        if (state is! CommunityLoaded) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final loading = state.commentsLoadingPostIds.contains(
                          post.id,
                        );
                        final comments =
                            state.commentsByPostId[post.id] ??
                            const <PostComment>[];
                        if (loading && comments.isEmpty) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (comments.isEmpty) {
                          return Center(
                            child: Text(
                              'No comments yet.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          itemCount: comments.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final c = comments[i];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.textPrimary,
                                child: Text(
                                  c.author.initials,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              title: Text(
                                c.author.displayName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(c.content),
                              ),
                              trailing: c.isMine
                                  ? PopupMenuButton<String>(
                                      tooltip: 'Actions',
                                      icon: const Icon(
                                        Icons.more_vert_rounded,
                                        color: AppColors.textSecondary,
                                      ),
                                      onSelected: (value) {
                                        if (value == 'delete') {
                                          context.read<CommunityBloc>().add(
                                            CommunityDeleteCommentRequested(
                                              postId: post.id,
                                              commentId: c.id,
                                            ),
                                          );
                                        }
                                      },
                                      itemBuilder: (_) => const [
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    )
                                  : null,
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputCtrl,
                          decoration: const InputDecoration(
                            hintText: 'Write a comment',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      IconButton.filled(
                        onPressed: () {
                          final text = inputCtrl.text.trim();
                          if (text.isEmpty) return;
                          bloc.add(
                            CommunityCreateCommentRequested(
                              postId: post.id,
                              content: text,
                            ),
                          );
                          inputCtrl.clear();
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  const _PostCard({
    required this.post,
    required this.isMine,
    required this.onEdit,
    required this.onDelete,
    required this.onLike,
    required this.onBookmark,
    required this.onComment,
    required this.onReport,
  });

  final Post post;
  final bool isMine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onComment;
  final VoidCallback onReport;

  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  bool _expanded = false;
  int _imagePageIndex = 0;

  @override
  void didUpdateWidget(covariant _PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id) {
      _imagePageIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final time = post.createdAt;
    final timeStr = time != null ? _timeAgo(time) : null;
    final imageUrls = post.imageUrls;
    final initials = post.author.initials;
    final displayName = post.author.displayName;
    return Container(
      padding: const EdgeInsets.all(Spacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.textPrimary,
                child: Text(
                  initials,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (timeStr != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          timeStr,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert,
                  color: AppColors.textSecondary,
                ),
                itemBuilder: (ctx) {
                  if (widget.isMine) {
                    return const [
                      PopupMenuItem<String>(value: 'edit', child: Text('Edit')),
                      PopupMenuItem<String>(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
                  }
                  return const [
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Text('Report'),
                    ),
                  ];
                },
                onSelected: (v) {
                  if (v == 'edit') widget.onEdit();
                  if (v == 'delete') widget.onDelete();
                  if (v == 'report') widget.onReport();
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          _ExpandablePostText(
            text: post.content,
            expanded: _expanded,
            onToggle: () => setState(() => _expanded = !_expanded),
          ),
          const SizedBox(height: Spacing.md),
          if (imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: imageUrls.length == 1
                  ? AspectRatio(
                      aspectRatio: 16 / 9,
                      child: _PostImage(url: imageUrls.first),
                    )
                  : SizedBox(
                      height: 190,
                      child: PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (idx) => setState(() => _imagePageIndex = idx),
                        itemBuilder: (_, i) => _PostImage(url: imageUrls[i]),
                      ),
                    ),
            ),
          if (imageUrls.length > 1) ...[
            const SizedBox(height: Spacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (i) {
                final active = i == _imagePageIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.textPrimary : AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ],
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: _Action(
                    icon: post.isLikedByMe
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: post.isLikedByMe
                        ? Colors.redAccent
                        : AppColors.textSecondary,
                    count: post.stats.likeCount,
                    onTap: widget.onLike,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _Action(
                    icon: Icons.mode_comment_outlined,
                    count: post.stats.commentCount,
                    onTap: widget.onComment,
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: _Action(
                    icon: post.isBookmarkedByMe
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    count: post.stats.bookmarkCount,
                    color: post.isBookmarkedByMe
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                    onTap: widget.onBookmark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime createdAt) {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = (diff.inDays / 7).floor();
    return '$weeks weeks ago';
  }
}

class _ExpandablePostText extends StatelessWidget {
  const _ExpandablePostText({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final canExpand = text.trim().length > 180;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: expanded ? null : (canExpand ? 4 : null),
          overflow: expanded ? TextOverflow.visible : TextOverflow.fade,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textPrimary,
            height: 1.45,
          ),
        ),
        if (canExpand)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: InkWell(
              onTap: onToggle,
              child: Text(
                expanded ? 'Show less' : 'Show more',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.icon,
    required this.onTap,
    this.count,
    this.color,
  });
  final IconData icon;
  final VoidCallback onTap;
  final int? count;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              '$count',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PostImage extends StatelessWidget {
  const _PostImage({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:image/')) {
      final idx = url.indexOf('base64,');
      if (idx == -1) {
        return Container(
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: Text(
            'Invalid image',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }
      try {
        final b64 = url.substring(idx + 'base64,'.length);
        final bytes = base64Decode(b64);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: AppColors.surfaceMuted,
            alignment: Alignment.center,
            child: Text(
              'Cannot load image',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      } catch (_) {
        return Container(
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: Text(
            'Cannot load image',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        );
      }
    }
    final resolved = _resolveImageUrl(url);
    final uri = Uri.tryParse(resolved);
    if (uri == null) {
      return Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: Text(
          'Invalid image URL',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }
    return Image.network(
      resolved,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: Text(
          'Cannot load image',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  String _resolveImageUrl(String raw) {
    final value = raw.trim();
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) return value;
    final base = ApiEndpoints.baseUrl;
    if (value.startsWith('/')) return '$base$value';
    return '$base/$value';
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search posts...',
          hintStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

class _CommunityTabs extends StatelessWidget {
  const _CommunityTabs({required this.value, required this.onChanged});
  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = ['All', 'My posts', 'Bookmarks'];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: Spacing.xs,
      runSpacing: Spacing.xs,
      children: List.generate(_labels.length, (i) {
        final selected = i == value;
        return ChoiceChip(
          label: Text(_labels[i]),
          selected: selected,
          onSelected: (_) => onChanged(i),
          selectedColor: AppColors.textPrimary,
          backgroundColor: Colors.white,
          shape: StadiumBorder(
            side: BorderSide(
              color: selected ? AppColors.textPrimary : AppColors.border,
            ),
          ),
          labelStyle: AppTextStyles.labelSmall.copyWith(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        );
      }),
    );
  }
}

class _CommunityBottomNavBar extends StatelessWidget {
  const _CommunityBottomNavBar();

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: AppColors.surface,
      elevation: 0,
      child: SizedBox(
        height: Dimensions.bottomNavHeight,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.xs,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: 'Home',
                onTap: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/driver-dashboard',
                  (route) => route.isFirst,
                ),
              ),
              _NavItem(
                icon: Icons.directions_car_filled,
                label: 'Vehicle',
                onTap: () => Navigator.of(context).pushNamed('/vehicles'),
              ),
              _NavItem(
                icon: Icons.handyman_outlined,
                label: 'Service',
                onTap: () => Navigator.of(context).pushNamed('/services'),
              ),
              const _NavItem(
                icon: Icons.people_alt_outlined,
                label: 'Community',
                isActive: true,
              ),
              _NavItem(
                icon: Icons.menu_book_outlined,
                label: 'Education',
                onTap: () => Navigator.of(context).pushNamed('/education'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.textPrimary : AppColors.textSecondary;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: Spacing.xs),
          Text(label, style: AppTextStyles.labelSmall.copyWith(color: color)),
        ],
      ),
    );
  }
}
