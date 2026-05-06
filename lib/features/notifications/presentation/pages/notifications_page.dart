library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/nav_app_bar.dart';
import '../../../services/presentation/pages/service_locator_page.dart';
import '../../domain/entities/driver_notification.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationsBloc>().add(const NotificationsLoadRequested());
  }

  void _onTapNotification(BuildContext context, DriverNotification n) {
    if (!n.read) {
      context.read<NotificationsBloc>().add(
        NotificationMarkReadRequested(n.id),
      );
    }
    final uid = n.upcomingId?.trim();
    if (uid != null && uid.isNotEmpty) {
      Navigator.of(context).pushNamed(
        '/vehicles',
        arguments: <String, dynamic>{'tab': 1, 'focusUpcomingId': uid},
      );
      return;
    }
    if (_isMaintenanceRelated(n)) {
      Navigator.of(
        context,
      ).pushNamed('/vehicles', arguments: <String, dynamic>{'tab': 1});
      return;
    }
    if (_isAppointmentRelated(n)) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const AllUpcomingAppointmentsPage(centers: []),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageBg = Color(0xFFF6F7FB);
    return Scaffold(
      backgroundColor: pageBg,
      appBar: const NavAppBar(title: 'CarCare', notificationCount: null),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.lg,
                Spacing.md,
                Spacing.lg,
                Spacing.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Maintenance reminders and app updates',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BlocBuilder<NotificationsBloc, NotificationsState>(
                    builder: (context, state) {
                      final canMarkAll = state.unreadCount > 0;
                      return TextButton(
                        onPressed: canMarkAll
                            ? () {
                                context.read<NotificationsBloc>().add(
                                  const NotificationsMarkAllReadRequested(),
                                );
                              }
                            : null,
                        child: const Text('Mark all as read'),
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, state) {
                  if (state.loading && state.items.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final items = state.items;
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(Spacing.lg),
                        child: Text(
                          state.error?.trim().isNotEmpty == true
                              ? state.error!
                              : 'No notifications yet.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<NotificationsBloc>().add(
                        const NotificationsLoadRequested(),
                      );
                    },
                    child: ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        0,
                        Spacing.lg,
                        Spacing.lg,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: Spacing.sm),
                      itemBuilder: (context, i) {
                        final n = items[i];
                        final isUnread = !n.read;
                        final accent = _accentFor(n);
                        final title = _displayTitle(n);
                        final detail = _detailText(n);

                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _onTapNotification(context, n),
                            borderRadius: BorderRadius.circular(18),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.md,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE5E7EF),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: accent.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _iconFor(n),
                                      color: accent,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: Spacing.md),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                                height: 1.25,
                                              ),
                                        ),
                                        if (detail.isNotEmpty) ...[
                                          const SizedBox(height: 6),
                                          Text(
                                            detail,
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.bodySmall
                                                .copyWith(
                                                  color:
                                                      AppColors.textSecondary,
                                                  height: 1.35,
                                                ),
                                          ),
                                        ],
                                        const SizedBox(height: 6),
                                        Wrap(
                                          spacing: Spacing.sm,
                                          runSpacing: 4,
                                          crossAxisAlignment:
                                              WrapCrossAlignment.center,
                                          children: [
                                            Text(
                                              _timeAgo(n.createdAt),
                                              style: AppTextStyles.labelSmall
                                                  .copyWith(
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                            ),
                                            if (n.upcomingId != null &&
                                                n.upcomingId!.trim().isNotEmpty)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.secondary
                                                      .withValues(alpha: 0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  'Reminder',
                                                  style: AppTextStyles
                                                      .labelSmall
                                                      .copyWith(
                                                        color:
                                                            AppColors.secondary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        // Intentionally no extra helper/action text inside tile.
                                      ],
                                    ),
                                  ),
                                  if (isUnread)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: Spacing.sm,
                                        top: 4,
                                      ),
                                      child: Icon(
                                        Icons.circle,
                                        size: 8,
                                        color: accent,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime ts) {
    final now = DateTime.now();
    final diff = now.difference(ts);
    if (diff.inMinutes < 2) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    final weeks = (diff.inDays / 7).floor();
    if (weeks < 5) return '$weeks weeks ago';
    final months = (diff.inDays / 30).floor();
    return '$months months ago';
  }
}

String _displayTitle(DriverNotification n) {
  final t = n.title.trim();
  if (t.isEmpty || t == 'Notification') {
    final b = n.body.trim();
    if (b.isNotEmpty) {
      final line = b.split(RegExp(r'[\r\n]+')).first.trim();
      if (line.length > 80) return '${line.substring(0, 77)}…';
      return line;
    }
    return 'Maintenance update';
  }
  return t;
}

String _detailText(DriverNotification n) {
  final body = n.body.trim();
  final title = n.title.trim();
  if (body.isEmpty) {
    if (_isMaintenanceRelated(n)) {
      return 'This relates to your vehicle maintenance schedule. You can review due dates and mark work complete from Upcoming.';
    }
    return '';
  }
  if (title.isNotEmpty && body == title) return '';
  if (body.startsWith(title) && body.length > title.length) {
    return body.substring(title.length).trim();
  }
  return body;
}

bool _isMaintenanceRelated(DriverNotification n) {
  final s = '${n.title} ${n.body}'.toLowerCase();
  return s.contains('maintenance') ||
      s.contains('reminder') ||
      s.contains('service due') ||
      s.contains('oil') ||
      s.contains('tire') ||
      s.contains('inspection');
}

bool _isAppointmentRelated(DriverNotification n) {
  final s = '${n.title} ${n.body}'.toLowerCase();
  return s.contains('appointment') ||
      s.contains('booking') ||
      s.contains('scheduled') ||
      s.contains('reschedule') ||
      s.contains('cancelled') ||
      s.contains('garage');
}

IconData _iconFor(DriverNotification n) {
  if (n.upcomingId != null && n.upcomingId!.trim().isNotEmpty) {
    return Icons.event_available_outlined;
  }
  final t = '${n.title} ${n.body}'.toLowerCase();
  if (t.contains('pressure') || t.contains('tire')) {
    return Icons.warning_amber_rounded;
  }
  if (t.contains('confirmed') || t.contains('appointment')) {
    return Icons.calendar_today_outlined;
  }
  if (t.contains('completed') || t.contains('done')) {
    return Icons.check_circle_outline_rounded;
  }
  if (_isMaintenanceRelated(n)) return Icons.build_circle_outlined;
  return Icons.notifications_none_rounded;
}

Color _accentFor(DriverNotification n) {
  if (n.upcomingId != null && n.upcomingId!.trim().isNotEmpty) {
    return const Color(0xFF4B8BFF);
  }
  final t = '${n.title} ${n.body}'.toLowerCase();
  if (t.contains('pressure') || t.contains('tire')) {
    return const Color(0xFFE45454);
  }
  if (t.contains('confirmed') || t.contains('appointment')) {
    return const Color(0xFF4B8BFF);
  }
  if (t.contains('completed') || t.contains('done')) {
    return const Color(0xFF32B768);
  }
  if (_isMaintenanceRelated(n)) return AppColors.pending;
  return AppColors.secondary;
}
