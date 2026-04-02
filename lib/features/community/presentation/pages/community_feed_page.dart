library;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/dimensions.dart';
import '../../../../core/constants/spacing.dart';
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
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    context.read<CommunityBloc>().add(const CommunityLoadRequested());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    final myId = auth is AuthAuthenticated ? auth.user.id : '';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/community'),
      appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
      body: BlocBuilder<CommunityBloc, CommunityState>(
        builder: (context, state) {
          final posts = state is CommunityLoaded ? state.posts : const <Post>[];
          final filtered = _applyFilters(posts, myId: myId, tab: _tab);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 0),
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
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: Spacing.md),
                    _SearchField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
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
                          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
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
                    context.read<CommunityBloc>().add(const CommunityRefreshRequested());
                  },
                  child: Builder(
                    builder: (_) {
                      if (state is CommunityLoading || state is CommunityInitial) {
                        return ListView(
                          children: [
                            SizedBox(height: 160),
                            Center(child: CircularProgressIndicator()),
                          ],
                        );
                      }
                      if (state is CommunityFailure) {
                        return ListView(
                          padding: const EdgeInsets.all(Spacing.lg),
                          children: [
                            const SizedBox(height: 120),
                            Text(
                              state.message,
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
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
                              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                        separatorBuilder: (_, __) => const SizedBox(height: Spacing.md),
                        itemBuilder: (context, i) {
                          final p = filtered[i];
                          return _PostCard(
                            post: p,
                            canDelete: myId.isNotEmpty && p.authorId == myId,
                            onDelete: () {
                              context.read<CommunityBloc>().add(CommunityDeletePostRequested(p.id));
                            },
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
      bottomNavigationBar: const _CommunityBottomNavBar(),
    );
  }

  List<Post> _applyFilters(
    List<Post> posts, {
    required String myId,
    required int tab,
  }) {
    final base = _applySearch(posts);
    if (tab == 1) {
      if (myId.isEmpty) return const <Post>[];
      return base.where((p) => p.authorId == myId).toList();
    }
    // Favorites / Mentions are UI-only until backend supports them.
    return base;
  }

  List<Post> _applySearch(List<Post> posts) {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return posts;
    return posts
        .where((p) =>
            p.title.toLowerCase().contains(q) || p.content.toLowerCase().contains(q))
        .toList();
  }
}

class _PostCard extends StatelessWidget {
  const _PostCard({
    required this.post,
    required this.canDelete,
    required this.onDelete,
  });

  final Post post;
  final bool canDelete;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final time = post.createdAt;
    final timeStr = time != null ? _timeAgo(time) : null;
    final imageUrl = post.imageUrl?.trim();
    final initials = _initialsFromAuthorId(post.authorId);
    final displayName = _displayNameFromAuthorId(post.authorId);
    final likeCount = _pseudoCount(post.id, 97) + 1;
    final commentCount = _pseudoCount('${post.id}-c', 23) + 1;
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
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
                itemBuilder: (ctx) => [
                  if (canDelete)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                ],
                onSelected: (v) {
                  if (v == 'delete') onDelete();
                },
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            post.content,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: Spacing.md),
          if (imageUrl != null && imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: _PostImage(url: imageUrl),
              ),
            ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              _Action(
                icon: Icons.favorite_border_rounded,
                count: likeCount,
                onTap: () {},
              ),
              const SizedBox(width: 22),
              _Action(
                icon: Icons.mode_comment_outlined,
                count: commentCount,
                onTap: () {},
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border_rounded),
                color: AppColors.textSecondary,
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

  static String _initialsFromAuthorId(String id) {
    final s = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toUpperCase();
    if (s.isEmpty) return 'U';
    return s.substring(0, s.length >= 2 ? 2 : 1);
  }

  static String _displayNameFromAuthorId(String id) {
    // Backend currently returns only authorId. Keep it friendly but stable.
    if (id.trim().isEmpty) return 'Driver';
    final s = id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final tail = s.length <= 4 ? s : s.substring(s.length - 4);
    return 'Driver $tail';
  }

  static int _pseudoCount(String seed, int mod) {
    // Deterministic per post so UI looks like the mock without backend fields.
    var h = 0;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h % mod;
  }
}

class _Action extends StatelessWidget {
  const _Action({required this.icon, required this.onTap, this.count});
  final IconData icon;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          if (count != null) ...[
            const SizedBox(width: 6),
            Text(
              '$count',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
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
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ),
        );
      } catch (_) {
        return Container(
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: Text(
            'Cannot load image',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
        );
      }
    }
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: Text(
          'Invalid image URL',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      );
    }
    return Image.network(
      uri.toString(),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.surfaceMuted,
        alignment: Alignment.center,
        child: Text(
          'Cannot load image',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ),
    );
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
          hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
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

  static const _labels = ['All', 'My posts', 'Favorites', 'Bookmarks'];

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
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg, vertical: Spacing.xs),
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

