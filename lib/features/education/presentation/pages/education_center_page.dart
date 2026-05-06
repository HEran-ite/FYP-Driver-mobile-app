library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../domain/entities/education_article.dart';
import '../bloc/education_bloc.dart';
import '../bloc/education_event.dart';
import '../bloc/education_state.dart';
import '../widgets/education_bottom_nav_bar.dart';
import 'education_article_detail_page.dart';

class EducationCenterPage extends StatefulWidget {
  const EducationCenterPage({super.key});

  @override
  State<EducationCenterPage> createState() => _EducationCenterPageState();
}

class _EducationCenterPageState extends State<EducationCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<EducationBloc>().add(EducationSearchSubmitted(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const AppDrawer(currentRoute: '/education'),
      appBar: const NavAppBar(title: 'CarCare', notificationCount: 3),
      body: SafeArea(
        child: BlocBuilder<EducationBloc, EducationState>(
          builder: (context, state) {
            if (state is EducationFailure) {
              return _ErrorView(
                message: state.message,
                onRetry: () =>
                    context.read<EducationBloc>().add(const EducationLoadRequested()),
              );
            }
            if (state is EducationInitial || state is EducationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is! EducationLoaded) {
              return const SizedBox.shrink();
            }
            final articles = state.articles;
            final searchQuery = state.searchQuery;

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<EducationBloc>();
                final q = searchQuery;
                if (q != null && q.isNotEmpty) {
                  bloc.add(EducationSearchSubmitted(q));
                } else {
                  bloc.add(const EducationLoadRequested());
                }
                await bloc.stream.firstWhere(
                  (s) => s is EducationLoaded || s is EducationFailure,
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Education Center',
                            style: AppTextStyles.headlineSmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs),
                          Text(
                            'Learn to maintain your vehicle',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: Spacing.md),
                          TextField(
                            controller: _searchController,
                            onChanged: _scheduleSearch,
                            decoration: InputDecoration(
                              hintText: 'Search guides and articles...',
                              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                              filled: true,
                              fillColor: AppColors.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                                borderSide: const BorderSide(color: AppColors.secondary, width: 1.5),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.md,
                              ),
                            ),
                          ),
                          if (searchQuery != null && searchQuery.isNotEmpty) ...[
                            const SizedBox(height: Spacing.sm),
                            Row(
                              children: [
                                Text(
                                  'Results for "$searchQuery"',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<EducationBloc>().add(const EducationSearchCleared());
                                  },
                                  child: const Text('Clear'),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: Spacing.lg),
                          _CategoryGrid(
                            articles: articles,
                            onCategoryTap: (cat) {
                              Navigator.of(context).pushNamed(
                                '/education/all',
                                arguments: cat.name,
                              );
                            },
                          ),
                          const SizedBox(height: Spacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Featured Articles',
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed('/education/all');
                                },
                                child: const Text('View All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: Spacing.sm),
                        ],
                      ),
                    ),
                  ),
                  if (articles.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.xl),
                        child: Center(
                          child: Text(
                            searchQuery != null && searchQuery.isNotEmpty
                                ? 'No articles match your search.'
                                : 'No articles yet. Check back soon.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xl),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final featured = _featured(articles);
                            if (index >= featured.length) return null;
                            final a = featured[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: Spacing.sm),
                              child: _FeaturedArticleCard(
                                article: a,
                                onRead: () {
                                  Navigator.of(context).push<void>(
                                    MaterialPageRoute<void>(
                                      builder: (_) => EducationArticleDetailPage(articleId: a.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          childCount: _featured(articles).length,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: const EducationBottomNavBar(current: EducationShellTab.education),
    );
  }

  List<EducationArticle> _featured(List<EducationArticle> all) {
    final copy = [...all]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return copy.take(5).toList();
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({
    required this.articles,
    required this.onCategoryTap,
  });

  final List<EducationArticle> articles;
  final void Function(EducationCategory category) onCategoryTap;

  int _count(EducationCategory c) =>
      articles.where((a) => a.category == c).length;

  @override
  Widget build(BuildContext context) {
    final tiles = [
      _CatData(EducationCategory.repairs, 'Repair', _count(EducationCategory.repairs), Icons.build_rounded, const Color(0xFF2E7D32)),
      _CatData(EducationCategory.safety, 'Safety', _count(EducationCategory.safety), Icons.shield_outlined, const Color(0xFFC62828)),
      _CatData(EducationCategory.maintenance, 'Maintenance', _count(EducationCategory.maintenance), Icons.schedule_rounded, const Color(0xFFF9A825)),
      _CatData(EducationCategory.tips, 'Tips', _count(EducationCategory.tips), Icons.lightbulb_outline_rounded, const Color(0xFF0277BD)),
      _CatData(EducationCategory.manuals, 'Manuals', _count(EducationCategory.manuals), Icons.menu_book_rounded, const Color(0xFF6A1B9A)),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: Spacing.sm,
      crossAxisSpacing: Spacing.sm,
      childAspectRatio: 1.35,
      children: tiles
          .map(
            (t) => _CategoryCard(
              data: t,
              onTap: () => onCategoryTap(t.category),
            ),
          )
          .toList(),
    );
  }
}

class _CatData {
  _CatData(this.category, this.label, this.count, this.icon, this.accent);
  final EducationCategory category;
  final String label;
  final int count;
  final IconData icon;
  final Color accent;
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.data, required this.onTap});

  final _CatData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(data.icon, color: data.accent, size: 28),
              const SizedBox(height: Spacing.sm),
              Text(
                data.label,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '${data.count} articles',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {
  const _FeaturedArticleCard({
    required this.article,
    required this.onRead,
  });

  final EducationArticle article;
  final VoidCallback onRead;

  @override
  Widget build(BuildContext context) {
    final beginner = article.difficultyLabel == 'Beginner';
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
      child: InkWell(
        onTap: onRead,
        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
        child: Container(
          padding: const EdgeInsets.all(Spacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: AppTextStyles.titleSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '${article.topicTag} • ${article.estimatedReadMinutes} min',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                    decoration: BoxDecoration(
                      color: beginner
                          ? AppColors.success.withValues(alpha: 0.15)
                          : const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(BorderRadiusValues.sm),
                    ),
                    child: Text(
                      article.difficultyLabel,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: beginner ? AppColors.success : const Color(0xFFF57F17),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Read ›',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: Spacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
