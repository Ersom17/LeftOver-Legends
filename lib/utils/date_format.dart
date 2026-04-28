// lib/utils/date_format.dart
//
// Region-aware date formatting. Use `formatDate(date, region)` everywhere the
// app displays a user-facing date (pantry cards, inputs, receipts, history)
// so it stays consistent with the user's region.

import '../providers/region_provider.dart';

String _pad(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime date, AppRegion region) {
  final d = _pad(date.day);
  final m = _pad(date.month);
  final y = date.year.toString();
  switch (region) {
    case AppRegion.us:
      return '$m/$d/$y';
    case AppRegion.europe:
      return '$d/$m/$y';
  }
}

String formatDateShort(DateTime date, AppRegion region) {
  final d = _pad(date.day);
  final m = _pad(date.month);
  switch (region) {
    case AppRegion.us:
      return '$m/$d';
    case AppRegion.europe:
      return '$d/$m';
  }
}
