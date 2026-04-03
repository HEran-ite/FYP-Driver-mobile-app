library;

import '../../domain/entities/maintenance_history.dart';
import '../../domain/entities/maintenance_upcoming.dart';
import '../bloc/maintenance_state.dart';

/// Title prefix for history rows created when the user deletes an upcoming reminder.
const String kDeletedReminderHistoryTitlePrefix = 'Deleted: ';

/// One row in the combined "History" timeline: either a scheduled reminder or a logged record.
class MaintenanceTimelineEntry {
  const MaintenanceTimelineEntry.reminder(this.reminder) : history = null;
  const MaintenanceTimelineEntry.record(this.history) : reminder = null;

  final MaintenanceUpcoming? reminder;
  final MaintenanceHistory? history;

  bool get isReminder => reminder != null;

  /// Newest first (completed reminders sort by [MaintenanceUpcoming.completedAt]).
  DateTime get sortKey {
    if (reminder != null) {
      final m = reminder!;
      if (m.completedAt != null) return m.completedAt!;
      return m.scheduledAt;
    }
    return history!.date;
  }
}

bool _sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Hides the extra history row we create on mark-done when the API still returns the completed reminder.
bool _isRedundantMarkDoneMirror(MaintenanceHistory h, List<MaintenanceUpcoming> upcoming) {
  final hasGarage = h.garageName != null && h.garageName!.trim().isNotEmpty;
  final hasCost = h.amount != null;
  if (hasGarage || hasCost) return false;
  final ht = h.title.trim();
  final hv = h.vehicleId ?? '';
  for (final u in upcoming) {
    if (u.completedAt == null) continue;
    if (u.title.trim() != ht) continue;
    final uv = u.vehicleId ?? '';
    if (uv.isNotEmpty && hv.isNotEmpty && uv != hv) continue;
    if (_sameCalendarDay(u.completedAt!, h.date)) return true;
  }
  return false;
}

List<MaintenanceTimelineEntry> buildMaintenanceTimeline(MaintenanceState state) {
  final upcoming = state.upcoming;
  final history = state.history.where((h) => !_isRedundantMarkDoneMirror(h, upcoming)).toList();
  final out = <MaintenanceTimelineEntry>[
    ...upcoming.map((u) => MaintenanceTimelineEntry.reminder(u)),
    ...history.map((h) => MaintenanceTimelineEntry.record(h)),
  ];
  out.sort((a, b) => b.sortKey.compareTo(a.sortKey));
  return out;
}
