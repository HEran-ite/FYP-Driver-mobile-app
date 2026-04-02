library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../../domain/entities/education_article.dart';
import '../bloc/education_bloc.dart';
import '../bloc/education_event.dart';
import '../bloc/education_state.dart';
import '../widgets/education_bottom_nav_bar.dart';
import 'education_article_detail_page.dart';

class EducationArticlesListPage extends StatelessWidget {
  const EducationArticlesListPage({super.key, this.initialCategory});

  /// From route arguments: [EducationCategory.name] e.g. `repairs`.
  final EducationCategory? initialCategory;

  static EducationCategory? categoryFromArgs(Object? args) {
    if (args is! String) return null;
    for (final c in EducationCategory.values) {
      if (c.name == args) return c;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final filter = initialCategory ?? categoryFromArgs(ModalRoute.of(context)?.settings.arguments);
    return BlocProvider(
      create: (_) => getIt<EducationBloc>()..add(const EducationLoadRequested()),
      child: _EducationArticlesListView(initialCategory: filter),
    );
  }
}

class _EducationArticlesListView extends StatefulWidget {
  const _EducationArticlesListView({this.initialCategory});

  final EducationCategory? initialCategory;

  @override
  State<_EducationArticlesListView> createState() => _EducationArticlesListViewState();
}

class _EducationArticlesListViewState extends State<_EducationArticlesListView> {
  EducationCategory? _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialCategory;
  }

  List<EducationArticle> _applyFilter(List<EducationArticle> all) {
    if (_filter == null) return all;
    return all.where((a) => a.category == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        title: Text(
          _filter != null ? '${_filter!.displayLabel} articles' : 'All articles',
          style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: BlocBuilder<EducationBloc, EducationState>(
        builder: (context, state) {
          if (state is EducationFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message, textAlign: TextAlign.center),
                    const SizedBox(height: Spacing.md),
                    FilledButton(
                      onPressed: () =>
                          context.read<EducationBloc>().add(const EducationLoadRequested()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is EducationInitial || state is EducationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is! EducationLoaded) return const SizedBox.shrink();

          final filtered = _applyFilter(state.articles);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.sm),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        selected: _filter == null,
                        onTap: () => setState(() => _filter = null),
                      ),
                      const SizedBox(width: Spacing.xs),
                      ...[
                        EducationCategory.repairs,
                        EducationCategory.safety,
                        EducationCategory.maintenance,
                        EducationCategory.tips,
                      ].map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(right: Spacing.xs),
                          child: _FilterChip(
                            label: c.displayLabel,
                            selected: _filter == c,
                            onTap: () => setState(() => _filter = c),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No articles in this category.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, Spacing.xl),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: Spacing.sm),
                        itemBuilder: (context, index) {
                          final a = filtered[index];
                          return _ArticleRow(
                            article: a,
                            onTap: () {
                              Navigator.of(context).push<void>(
                                MaterialPageRoute<void>(
                                  builder: (_) => EducationArticleDetailPage(articleId: a.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: const EducationBottomNavBar(current: EducationShellTab.education),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.secondary : AppColors.surface,
      borderRadius: BorderRadius.circular(BorderRadiusValues.circular),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.circular),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          child: Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: selected ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article, required this.onTap});

  final EducationArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
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
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
