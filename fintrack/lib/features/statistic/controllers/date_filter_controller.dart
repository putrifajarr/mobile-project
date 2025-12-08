import 'package:flutter/material.dart';

enum StatPeriod { weekly, monthly, yearly }

class DateFilterController extends ChangeNotifier {
  StatPeriod _period = StatPeriod.weekly;
  DateTime _selectedDate = DateTime.now();

  StatPeriod get period => _period;
  DateTime get selectedDate => _selectedDate;

  void setPeriod(StatPeriod period) {
    _period = period;
    _selectedDate = DateTime.now();
    notifyListeners();
  }

  void next() {
    _shift(1);
  }

  void previous() {
    _shift(-1);
  }

  void _shift(int multiplier) {
    switch (_period) {
      case StatPeriod.weekly:
        _selectedDate = _selectedDate.add(Duration(days: 7 * multiplier));
        break;
      case StatPeriod.monthly:
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month + multiplier,
          _selectedDate.day,
        );
        break;
      case StatPeriod.yearly:
        _selectedDate = DateTime(
          _selectedDate.year + multiplier,
          _selectedDate.month,
          _selectedDate.day,
        );
        break;
    }
    notifyListeners();
  }

  DateTimeRange get currentRange {
    final date = _selectedDate;
    DateTime start;
    DateTime end;

    switch (_period) {
      case StatPeriod.weekly:
        start = date.subtract(Duration(days: date.weekday - 1));
        end = start.add(const Duration(days: 6));
        break;
      case StatPeriod.monthly:
        start = DateTime(date.year, date.month, 1);
        end = DateTime(date.year, date.month + 1, 0);
        break;
      case StatPeriod.yearly:
        start = DateTime(date.year, 1, 1);
        end = DateTime(date.year, 12, 31);
        break;
    }

    end = DateTime(end.year, end.month, end.day, 23, 59, 59);
    return DateTimeRange(start: start, end: end);
  }
}
