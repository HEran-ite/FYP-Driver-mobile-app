library;

import 'package:flutter/material.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../../application/usecases/get_education_article_usecase.dart';
import '../../domain/entities/education_article.dart';
import '../widgets/education_bottom_nav_bar.dart';

class EducationArticleDetailPage extends StatefulWidget {
  const EducationArticleDetailPage({super.key, required this.articleId});

  final String articleId;

  @override
  State<EducationArticleDetailPage> createState() => _EducationArticleDetailPageState();
}

class _EducationArticleDetailPageState extends State<EducationArticleDetailPage> {
  final _getArticle = getIt<GetEducationArticleUseCase>();
  Future<EducationArticle>? _future;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    _future = _getArticle(widget.articleId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_outline),
            onPressed: () => setState(() => _bookmarked = !_bookmarked),
          ),
        ],
      ),
      body: FutureBuilder<EducationArticle>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load this article.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: Spacing.md),
                    FilledButton(
                      onPressed: () => setState(() {
                        _future = _getArticle(widget.articleId);
                      }),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          final article = snapshot.data!;
          return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(Spacing.lg, 0, Spacing.lg, Spacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Article',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      '${article.categoryLabel} guide',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Text(
                      article.title,
                      style: AppTextStyles.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 18, color: AppColors.textSecondary),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          '${article.estimatedReadMinutes} min read',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(Spacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(BorderRadiusValues.xl),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SelectableText(
                        article.description,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
          );
        },
      ),
      bottomNavigationBar: const EducationBottomNavBar(current: EducationShellTab.education),
    );
  }
}
