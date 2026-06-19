import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish_provider.dart';

class WorkoutCalendarPage extends ConsumerStatefulWidget {
  final String userId;

  const WorkoutCalendarPage({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<WorkoutCalendarPage> createState() =>
      _WorkoutCalendarPageState();
}

class _WorkoutCalendarPageState extends ConsumerState<WorkoutCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  bool _isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  IconData _backIcon(BuildContext context) {
    return _isIOS(context)
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_back_rounded;
  }

  double _appBarHeight(BuildContext context) {
    return _isIOS(context) ? 52 : 56;
  }

  ScrollPhysics _scrollPhysics(BuildContext context) {
    return _isIOS(context)
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  DateTime _normalizeDay(DateTime day) {
    return DateTime(day.year, day.month, day.day);
  }

  List<WorkoutFinish> _getEventsForDay(
    DateTime day,
    List<WorkoutFinish> records,
  ) {
    final targetDay = _normalizeDay(day);

    final selectedRecords = records.where((record) {
      final timestamp = record.timestamp;
      if (timestamp == null) return false;

      return _normalizeDay(timestamp) == targetDay;
    }).toList();

    selectedRecords.sort((a, b) {
      final aTime = a.timestamp;
      final bTime = b.timestamp;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;

      return bTime.compareTo(aTime);
    });

    return selectedRecords;
  }

  String _formatSelectedDate(DateTime day) {
    return '${day.year}년 ${day.month}월 ${day.day}일';
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  String _formatPace(double pace) {
    if (pace.isNaN || pace.isInfinite || pace <= 0) {
      return '--:-- /km';
    }

    final minutes = pace.floor();
    final seconds = ((pace - minutes) * 60).round();

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')} /km';
  }

  double _totalDistanceKm(List<WorkoutFinish> records) {
    final totalMeters = records.fold<double>(
      0,
      (previous, record) => previous + record.distanceMeters,
    );

    return totalMeters / 1000;
  }

  int _totalSeconds(List<WorkoutFinish> records) {
    return records.fold<int>(
      0,
      (previous, record) => previous + record.seconds,
    );
  }

  void _showDayRecordsBottomSheet({
    required BuildContext parentContext,
    required DateTime selectedDay,
    required List<WorkoutFinish> selectedRecords,
  }) {
    final totalDistance = _totalDistanceKm(selectedRecords);
    final totalTime = _formatDuration(_totalSeconds(selectedRecords));

    showModalBottomSheet<void>(
      context: parentContext,
      useRootNavigator: true,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.68),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final height = media.size.height;
        final isSmallHeight = height < 720;
        final isIOS = _isIOS(sheetContext);
        final maxWidth = math.min(media.size.width, 560.0);

        final double initialSize;
        if (selectedRecords.isEmpty) {
          initialSize = isSmallHeight ? 0.48 : 0.40;
        } else {
          initialSize = isSmallHeight ? 0.80 : 0.68;
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: DraggableScrollableSheet(
              expand: false,
              initialChildSize: initialSize,
              minChildSize: 0.34,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return Container(
                  margin: EdgeInsets.fromLTRB(
                    8,
                    0,
                    8,
                    isIOS ? 8 : 10,
                  ),
                  decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(isIOS ? 24 : 22),
                    border: Border.all(
                      color: _line,
                      width: 0.8,
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: CustomScrollView(
                      controller: scrollController,
                      physics: _scrollPhysics(sheetContext),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              Container(
                                width: 38,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3A3A40),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: _accent.withValues(alpha: 0.13),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              _accent.withValues(alpha: 0.25),
                                          width: 0.8,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.calendar_month_rounded,
                                        color: _accent,
                                        size: 21,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatSelectedDate(selectedDay),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: _primaryText,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.4,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            selectedRecords.isEmpty
                                                ? '운동 기록이 없습니다'
                                                : '${selectedRecords.length}개의 운동 기록',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: _secondaryText,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: '닫기',
                                      visualDensity: VisualDensity.compact,
                                      onPressed: () {
                                        Navigator.of(sheetContext).pop();
                                      },
                                      icon: const Icon(
                                        Icons.close_rounded,
                                        color: _primaryText,
                                        size: 22,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (selectedRecords.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: _SheetSummaryBox(
                                          label: '총 거리',
                                          value:
                                              '${totalDistance.toStringAsFixed(2)} km',
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _SheetSummaryBox(
                                          label: '총 시간',
                                          value: totalTime,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Divider(
                                color: _line,
                                height: 1,
                                thickness: 0.7,
                              ),
                            ],
                          ),
                        ),
                        if (selectedRecords.isEmpty)
                          const SliverFillRemaining(
                            hasScrollBody: false,
                            child: _BottomSheetEmptyView(),
                          )
                        else
                          SliverList.separated(
                            itemCount: selectedRecords.length,
                            separatorBuilder: (_, _) => const Divider(
                              color: _line,
                              height: 1,
                              thickness: 0.6,
                              indent: 82,
                            ),
                            itemBuilder: (context, index) {
                              final record = selectedRecords[index];

                              return InkWell(
                                onTap: () {
                                  Navigator.of(sheetContext).pop();

                                  parentContext.push(
                                    '/workoutFeed',
                                    extra: record,
                                  );
                                },
                                child: _WorkoutRecordTile(
                                  index: index,
                                  distance:
                                      '${(record.distanceMeters / 1000).toStringAsFixed(2)} km',
                                  time: _formatDuration(record.seconds),
                                  speed:
                                      '${record.speedKmh.toStringAsFixed(1)} km/h',
                                  pace: _formatPace(record.paceMinPerKm),
                                ),
                              );
                            },
                          ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 18 + media.padding.bottom,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isIOS = _isIOS(context);

    return AppBar(
      backgroundColor: _bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      toolbarHeight: _appBarHeight(context),
      leadingWidth: isIOS ? 52 : 56,
      leading: IconButton(
        tooltip: '뒤로가기',
        visualDensity: VisualDensity.compact,
        onPressed: () => _goBack(context),
        icon: Icon(
          _backIcon(context),
          color: _primaryText,
          size: isIOS ? 20 : 23,
        ),
      ),
      title: const Text(
        '캘린더',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: _primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.35,
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(0.7),
        child: Divider(
          color: _line,
          height: 0.7,
          thickness: 0.7,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(workoutFinishListProvider(widget.userId));

    final media = MediaQuery.of(context);
    final size = media.size;
    final shortestSide = size.shortestSide;
    final isSmallHeight = size.height < 720;

    final horizontalPadding = shortestSide < 370 ? 12.0 : 16.0;
    final maxWidth = math.min(size.width, 720.0);

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        bottom: false,
        child: recordsAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              color: _accent,
              strokeWidth: 2.5,
            ),
          ),
          error: (e, st) => const _StateMessage(
            icon: Icons.error_outline_rounded,
            title: '운동 기록을 불러오지 못했습니다',
            message: '인터넷 연결을 확인한 뒤 다시 시도해주세요.',
          ),
          data: (records) {
            final monthRecords = records.where((record) {
              final timestamp = record.timestamp;
              if (timestamp == null) return false;

              return timestamp.year == _focusedDay.year &&
                  timestamp.month == _focusedDay.month;
            }).toList();

            final monthDistance = _totalDistanceKm(monthRecords);

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: maxWidth,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final contentWidth = constraints.maxWidth;
                    final dayCellWidth =
                        ((contentWidth - (horizontalPadding * 2) - 24) / 7)
                            .clamp(38.0, 58.0);

                    final rowHeight = math.max(
                      isSmallHeight ? 48.0 : 52.0,
                      math.min(56.0, dayCellWidth + 8),
                    );

                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        12,
                        horizontalPadding,
                        24 + media.padding.bottom,
                      ),
                      physics: _scrollPhysics(context),
                      child: Column(
                        children: [
                          _MonthOverviewCard(
                            count: monthRecords.length,
                            distance: monthDistance,
                          ),
                          SizedBox(height: isSmallHeight ? 12 : 16),
                          _CalendarCard(
                            child: TableCalendar<WorkoutFinish>(
                              firstDay: DateTime.utc(2020, 1, 1),
                              lastDay: DateTime.utc(2035, 12, 31),
                              focusedDay: _focusedDay,
                              selectedDayPredicate: (day) =>
                                  isSameDay(_selectedDay, day),
                              calendarFormat: _calendarFormat,
                              rowHeight: rowHeight,
                              daysOfWeekHeight: 28,
                              eventLoader: (day) =>
                                  _getEventsForDay(day, records),
                              availableGestures:
                                  AvailableGestures.horizontalSwipe,
                              onDaySelected: (selectedDay, focusedDay) {
                                final selectedRecords =
                                    _getEventsForDay(selectedDay, records);

                                setState(() {
                                  _selectedDay = selectedDay;
                                  _focusedDay = focusedDay;
                                });

                                _showDayRecordsBottomSheet(
                                  parentContext: context,
                                  selectedDay: selectedDay,
                                  selectedRecords: selectedRecords,
                                );
                              },
                              onFormatChanged: (format) {
                                setState(() {
                                  _calendarFormat = format;
                                });
                              },
                              onPageChanged: (focusedDay) {
                                setState(() {
                                  _focusedDay = focusedDay;
                                });
                              },
                              headerStyle: const HeaderStyle(
                                formatButtonVisible: false,
                                titleCentered: true,
                                headerPadding:
                                    EdgeInsets.fromLTRB(0, 2, 0, 10),
                                titleTextStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: _primaryText,
                                  letterSpacing: -0.4,
                                ),
                                leftChevronIcon: Icon(
                                  Icons.chevron_left_rounded,
                                  color: _primaryText,
                                  size: 28,
                                ),
                                rightChevronIcon: Icon(
                                  Icons.chevron_right_rounded,
                                  color: _primaryText,
                                  size: 28,
                                ),
                              ),
                              daysOfWeekStyle: const DaysOfWeekStyle(
                                weekdayStyle: TextStyle(
                                  color: _secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                                weekendStyle: TextStyle(
                                  color: _secondaryText,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              calendarStyle: const CalendarStyle(
                                outsideDaysVisible: false,
                                markersMaxCount: 0,
                                cellMargin: EdgeInsets.zero,
                                cellPadding: EdgeInsets.zero,
                                defaultDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                weekendDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                todayDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                defaultTextStyle: TextStyle(
                                  color: Colors.transparent,
                                ),
                                weekendTextStyle: TextStyle(
                                  color: Colors.transparent,
                                ),
                                todayTextStyle: TextStyle(
                                  color: Colors.transparent,
                                ),
                                selectedTextStyle: TextStyle(
                                  color: Colors.transparent,
                                ),
                              ),
                              calendarBuilders:
                                  CalendarBuilders<WorkoutFinish>(
                                defaultBuilder: (context, day, focusedDay) {
                                  final events =
                                      _getEventsForDay(day, records);

                                  return _CalendarDayCell(
                                    day: day,
                                    eventsCount: events.length,
                                    isToday: isSameDay(day, DateTime.now()),
                                    isSelected: isSameDay(_selectedDay, day),
                                    cellWidth: dayCellWidth,
                                  );
                                },
                                todayBuilder: (context, day, focusedDay) {
                                  final events =
                                      _getEventsForDay(day, records);

                                  return _CalendarDayCell(
                                    day: day,
                                    eventsCount: events.length,
                                    isToday: true,
                                    isSelected: isSameDay(_selectedDay, day),
                                    cellWidth: dayCellWidth,
                                  );
                                },
                                selectedBuilder: (context, day, focusedDay) {
                                  final events =
                                      _getEventsForDay(day, records);

                                  return _CalendarDayCell(
                                    day: day,
                                    eventsCount: events.length,
                                    isToday: isSameDay(day, DateTime.now()),
                                    isSelected: true,
                                    cellWidth: dayCellWidth,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallHeight ? 12 : 16),
                          const _CalendarInfoSection(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MonthOverviewCard extends StatelessWidget {
  const _MonthOverviewCard({
    required this.count,
    required this.distance,
  });

  final int count;
  final double distance;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 78,
      ),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
        gradient: LinearGradient(
          colors: [
            _accent.withValues(alpha: 0.12),
            _surface,
            _surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withValues(alpha: 0.13),
              border: Border.all(
                color: _accent.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: _accent,
              size: 23,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이번 달 운동',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$count회 · ${distance.toStringAsFixed(2)} km',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.auto_graph_rounded,
            color: _accent,
            size: 23,
          ),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final Widget child;

  const _CalendarCard({
    required this.child,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: child,
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.day,
    required this.eventsCount,
    required this.isToday,
    required this.isSelected,
    required this.cellWidth,
  });

  final DateTime day;
  final int eventsCount;
  final bool isToday;
  final bool isSelected;
  final double cellWidth;

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final circleSize = cellWidth < 44 ? 30.0 : 32.0;
    final dotSize = cellWidth < 44 ? 4.0 : 4.5;

    final Color numberColor;

    if (isSelected) {
      numberColor = _bg;
    } else if (isToday) {
      numberColor = _primaryText;
    } else {
      numberColor = eventsCount > 0 ? _primaryText : _secondaryText;
    }

    return Center(
      child: SizedBox(
        width: cellWidth,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
              width: isSelected ? circleSize + 2 : circleSize,
              height: isSelected ? circleSize + 2 : circleSize,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? _primaryText : Colors.transparent,
                shape: BoxShape.circle,
                border: isToday && !isSelected
                    ? Border.all(
                        color: _accent,
                        width: 1.2,
                      )
                    : null,
              ),
              child: Text(
                '${day.day}',
                style: TextStyle(
                  color: numberColor,
                  fontSize: 14,
                  height: 1,
                  fontWeight: isSelected || isToday || eventsCount > 0
                      ? FontWeight.w900
                      : FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: 6,
              child: eventsCount > 0
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        eventsCount > 3 ? 3 : eventsCount,
                        (index) => Container(
                          width: dotSize,
                          height: dotSize,
                          margin: const EdgeInsets.symmetric(horizontal: 1.2),
                          decoration: BoxDecoration(
                            color: isSelected ? _primaryText : _accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarInfoSection extends StatelessWidget {
  const _CalendarInfoSection();

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(15, 14, 15, 14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 19,
            color: _accent,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              '파란 점이 있는 날짜를 누르면 그날의 운동 기록을 볼 수 있어요.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13,
                height: 1.38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetSummaryBox extends StatelessWidget {
  const _SheetSummaryBox({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 68,
      ),
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetEmptyView extends StatelessWidget {
  const _BottomSheetEmptyView();

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 26, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_run_outlined,
              color: _accent,
              size: 42,
            ),
            SizedBox(height: 14),
            Text(
              '운동 기록이 없어요',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _primaryText,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 7),
            Text(
              '이 날짜에는 저장된 운동 기록이 없습니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutRecordTile extends StatelessWidget {
  const _WorkoutRecordTile({
    required this.index,
    required this.distance,
    required this.time,
    required this.speed,
    required this.pace,
  });

  final int index;
  final String distance;
  final String time;
  final String speed;
  final String pace;

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 14, 14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withValues(alpha: 0.13),
              border: Border.all(
                color: _accent.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: const Icon(
              Icons.directions_run_rounded,
              color: _accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '운동 ${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: _primaryText,
                    letterSpacing: -0.25,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$distance · $time',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _secondaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$speed · $pace',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: _softText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.chevron_right_rounded,
            color: _secondaryText,
            size: 23,
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final maxWidth = math.min(media.size.width - 32, 420.0);

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: _line,
              width: 0.8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: _accent,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _primaryText,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _secondaryText,
                  fontSize: 13.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.05,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}