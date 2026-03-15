import 'package:intl/intl.dart';

String formatDeckDate(DateTime value) {
  return DateFormat('MMM d, yyyy').format(value);
}
