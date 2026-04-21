library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/border_radius.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../injection/service_locator.dart';
import '../bloc/ai_chat_bloc.dart';
import '../bloc/ai_chat_event.dart';
import '../bloc/ai_chat_state.dart';

class AiChatHistoryPage extends StatelessWidget {
  const AiChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AiChatBloc>()..add(const AiSessionsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          title: const Text('Chat History'),
        ),
        body: BlocConsumer<AiChatBloc, AiChatState>(
          listenWhen: (prev, curr) => prev.error != curr.error,
          listener: (context, state) {
            final err = state.error?.trim();
            if (err == null || err.isEmpty) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
          },
          builder: (context, state) {
            if (state.sessionsLoading && state.sessions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<AiChatBloc>().add(const AiSessionsRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(Spacing.md),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.of(context).pop('__new__'),
                      icon: const Icon(Icons.add),
                      label: const Text('Start New Chat'),
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  if (state.sessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(Spacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                      ),
                      child: Text(
                        'No chats yet. Start your first conversation.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  for (final session in state.sessions) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                      onTap: () => Navigator.of(context).pop(session.id),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: Spacing.sm),
                        padding: const EdgeInsets.all(Spacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(BorderRadiusValues.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    session.vehicleLabel?.trim().isNotEmpty == true
                                        ? session.vehicleLabel!.trim()
                                        : session.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.titleSmall.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (state.deletingSessionId == session.id)
                                  const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                else
                                  IconButton(
                                    tooltip: 'Delete session',
                                    visualDensity: VisualDensity.compact,
                                    onPressed: () async {
                                      final ok = await _confirmDelete(context);
                                      if (ok != true || !context.mounted) return;
                                      context.read<AiChatBloc>().add(
                                            AiSessionDeleteRequested(session.id),
                                          );
                                    },
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.danger,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              session.lastMessagePreview?.trim().isNotEmpty == true
                                  ? session.lastMessagePreview!.trim()
                                  : 'Chat Session',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            Text(
                              _timeAgo(session.updatedAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

Future<bool?> _confirmDelete(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Delete chat session?'),
      content: const Text(
        'This will remove the conversation from history. This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(
            'Delete',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.danger),
          ),
        ),
      ],
    ),
  );
}

String _timeAgo(DateTime ts) {
  final diff = DateTime.now().difference(ts);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return '${diff.inHours} hr ago';
  if (diff.inDays < 7) return '${diff.inDays} days ago';
  return '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')}';
}
