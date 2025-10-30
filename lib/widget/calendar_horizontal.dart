import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../provider/appointment_provider.dart';

class HorizontalWeekCalendar extends ConsumerStatefulWidget {
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HorizontalWeekCalendarState();
  }
}

class _HorizontalWeekCalendarState
    extends ConsumerState<HorizontalWeekCalendar> {
  DateTime _currentWeekStart = DateTime.now();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = getStartOfWeek(DateTime.now());
  }

  // Calcola il primo giorno della settimana corrente (lunedì)
  DateTime getStartOfWeek(DateTime date) {
    int weekday = date.weekday; // Lunedì = 1, Domenica = 7
    return date.subtract(Duration(days: weekday - 1));
  }

  void _nextWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    });
  }

  void _previousWeek() {
    setState(() {
      _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!.localeName;
    final appointments = ref.watch(appointmentGetProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    // Filtra gli appuntamenti per la settimana corrente
    final currentWeekAppointments = appointments.where((appointment) {
      return appointment.date
              .isAfter(_currentWeekStart.subtract(const Duration(days: 1))) &&
          appointment.date
              .isBefore(_currentWeekStart.add(const Duration(days: 7)));
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios, size: 16),
              onPressed: _previousWeek,
            ),
            Expanded(
              child: SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    DateTime day = _currentWeekStart.add(Duration(days: index));
                    bool isToday = DateUtils.isSameDay(day, DateTime.now());
                    bool isSelected = selectedDate != null &&
                        DateUtils.isSameDay(day, selectedDate);
                    bool hasAppointment = currentWeekAppointments.any(
                      (appointment) =>
                          DateUtils.isSameDay(day, appointment.date),
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(selectedDateProvider.notifier).state = day;
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              width: 40,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFC4B7E1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isToday
                                      ? const Color(0xFF9A91AD)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    DateFormat.E(locale)
                                        .format(day)[0]
                                        .toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? Colors.black
                                          : Colors.pink,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('d').format(day),
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: day.isAfter(DateTime.now()
                                                  .subtract(const Duration(
                                                      days: 1))) ||
                                              day.isAtSameMomentAs(
                                                  DateTime.now().subtract(
                                                      const Duration(days: 1)))
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasAppointment
                                    ? (day.isAfter(DateTime.now().subtract(
                                                const Duration(days: 1))) ||
                                            day.isAtSameMomentAs(DateTime.now()
                                                .subtract(
                                                    const Duration(days: 1))))
                                        ? const Color(0xFFBAFFA5)
                                        : const Color(0xFFE0F6DA)
                                    : Colors.transparent,
                                border: hasAppointment
                                    ? null
                                    : Border.all(color: Colors.grey, width: 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: _nextWeek,
            ),
          ],
        ),
      ],
    );
  }
}
