library;

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/network/api_client.dart';
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
          final pdfUrl = _extractPdfUrl(article);
          final isManual = article.category == EducationCategory.manuals;
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
                          '${article.estimatedReadMinutes} min',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.lg),
                    if (isManual && pdfUrl != null) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _openPdf(context, pdfUrl),
                          icon: const Icon(Icons.picture_as_pdf_outlined),
                          label: const Text('Get Manual'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                    ],
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

  String? _extractPdfUrl(EducationArticle article) {
    if (article.category != EducationCategory.manuals) return null;

    final fromManual = article.manualUrl?.trim();
    if (fromManual != null && _looksLikeUrl(fromManual)) return fromManual;

    final fromImage = article.imageUrl?.trim();
    if (fromImage != null && _isPdfUrl(fromImage)) return fromImage;

    final text = article.description;
    final regex = RegExp(
      r'https?:\/\/[^\s<>"()]+\.pdf(?:\?[^\s<>"()]*)?',
      caseSensitive: false,
    );
    final match = regex.firstMatch(text);
    return match?.group(0);
  }

  bool _isPdfUrl(String value) {
    final lower = value.toLowerCase();
    final hasHttp = lower.startsWith('http://') || lower.startsWith('https://');
    return hasHttp && lower.contains('.pdf');
  }

  bool _looksLikeUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null && uri.hasScheme;
  }

  Future<void> _openPdf(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final cleaned = url.trim();
    final encoded = Uri.encodeFull(cleaned);
    final uri = Uri.tryParse(encoded);
    if (uri == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Invalid PDF link.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    final openedExternal = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (openedExternal) return;

    final openedBrowser = await launchUrl(uri, mode: LaunchMode.platformDefault);
    if (openedBrowser) return;

    try {
      final filename = uri.pathSegments.isNotEmpty
          ? uri.pathSegments.last
          : 'manual';
      final safeBase = filename.isEmpty ? 'manual' : filename;
      final safeName = safeBase.toLowerCase().endsWith('.pdf')
          ? safeBase
          : '$safeBase.pdf';
      final tempDir = await getTemporaryDirectory();
      final localPath = '${tempDir.path}/$safeName';
      await getIt<ApiClient>().dio.download(uri.toString(), localPath);
      final result = await OpenFilex.open(localPath);
      if (result.type == ResultType.done) return;
    } catch (_) {
      // Final fallback dialog below.
    }

    if (context.mounted) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Open Manual'),
          content: SelectableText(
            uri.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    }
  }
}
