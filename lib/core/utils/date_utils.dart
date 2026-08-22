import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();
  static final _md = DateFormat('MMM d');
  static final _full = DateFormat('MMM d, y');

  static String short(DateTime? d) => d == null ? '—' : _md.format(d);
  static String full(DateTime? d) => d == null ? 'No due date' : _full.format(d);

  static bool isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  static String relativeDue(DateTime? d) {
    if (d == null) return 'No due date';
    final n = DateTime.now();
    final due = DateTime(d.year, d.month, d.day);
    final today = DateTime(n.year, n.month, n.day);
    final diff = due.difference(today).inDays;
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff == -1) return 'Due yesterday';
    if (diff < 0) return 'Overdue by ${-diff}d';
    return 'Due in ${diff}d';
  }
}
