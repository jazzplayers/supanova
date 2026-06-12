import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/Home_page/home_widget/month_goal/month_goal_provider.dart';
import 'package:home_function/core/firebase.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class MonthGauge extends ConsumerStatefulWidget {
  final String userId;

  const MonthGauge({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<MonthGauge> createState() => _MonthGaugeState();
}

class _MonthGaugeState extends ConsumerState<MonthGauge> {
  final TextEditingController monthlyGoalCtrl = TextEditingController();

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0F1115);
  static const Color _surfaceSoft = Color(0xFF171A20);
  static const Color _line = Color(0xFF272A31);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFA1A1AA);
  static const Color _softText = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF5DADEC);

  int get currentMonth => DateTime.now().month;

  @override
  void dispose() {
    monthlyGoalCtrl.dispose();
    super.dispose();
  }

  Future<void> _showGoalBottomSheet({
    required String userId,
    required double currentGoal,
  }) async {
    monthlyGoalCtrl.text =
        currentGoal == 0 ? '' : currentGoal.toStringAsFixed(1);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.62),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);

        return Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: media.viewInsets.bottom + 12,
          ),
          child: _GoalBottomSheet(
            currentMonth: currentMonth,
            controller: monthlyGoalCtrl,
            onClose: () {
              Navigator.of(sheetContext).pop();
            },
            onSave: () async {
              await _saveGoal(sheetContext, userId);
            },
          ),
        );
      },
    );
  }

  Future<void> _saveGoal(BuildContext sheetContext, String userId) async {
    final text = monthlyGoalCtrl.text.trim();
    final goal = double.tryParse(text);

    if (goal == null || goal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _surfaceSoft,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _line),
          ),
          content: const Text(
            '목표 거리를 0보다 크게 입력해주세요.',
            style: TextStyle(
              color: _primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      return;
    }

    await ref.read(monthGoalRepoProvider).setMonthlyGoal(userId, goal);

    if (sheetContext.mounted) {
      Navigator.of(sheetContext).pop();
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: _surfaceSoft,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: _line),
          ),
          content: Text(
            '${goal.toStringAsFixed(0)}km 목표로 설정했어요.',
            style: const TextStyle(
              color: _primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(firebaseAuthProvider).currentUser?.uid;
    final isMe = myUid == widget.userId;

    final totalDistanceThisMonthAsync =
        ref.watch(totalDistanceThisMonthProvider(widget.userId));

    final monthlyGoalAsync = isMe
        ? ref.watch(monthlyGoalStreamProvider(widget.userId))
        : const AsyncValue.data(0.0);

    final gaugeBody = Padding(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      child: monthlyGoalAsync.when(
        data: (goalDistance) {
          final safeGoal = goalDistance > 0 ? goalDistance : 100.0;

          final totalDistanceMeters = totalDistanceThisMonthAsync.maybeWhen(
            data: (total) => total,
            orElse: () => 0.0,
          );

          final totalDistanceKm = totalDistanceMeters / 1000.0;

          final gaugeValue =
              totalDistanceKm > safeGoal ? safeGoal : totalDistanceKm;

          final percent =
              ((totalDistanceKm / safeGoal) * 100).clamp(0, 100).toDouble();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GaugeHeader(
                currentMonth: currentMonth,
                percent: percent,
                isMe: isMe,
              ),
              const SizedBox(height: 18),
              _GaugeDistanceRow(
                totalDistanceKm: totalDistanceKm,
                safeGoal: safeGoal,
              ),
              const SizedBox(height: 13),
              SizedBox(
                height: 32,
                child: SfLinearGauge(
                  key: ValueKey('${safeGoal}_$gaugeValue'),
                  minimum: 0,
                  maximum: safeGoal,
                  animateAxis: true,
                  interval: safeGoal / 2,
                  showTicks: false,
                  showLabels: false,
                  showAxisTrack: true,
                  axisTrackStyle: const LinearAxisTrackStyle(
                    thickness: 12,
                    edgeStyle: LinearEdgeStyle.bothCurve,
                    color: _surfaceSoft,
                  ),
                  barPointers: const [],
                  ranges: [
                    LinearGaugeRange(
                      startValue: 0,
                      endValue: gaugeValue,
                      color: _accent,
                      startWidth: 12,
                      endWidth: 12,
                      edgeStyle: LinearEdgeStyle.bothCurve,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 118,
          child: Center(
            child: CircularProgressIndicator(
              color: _primaryText,
              strokeWidth: 2,
            ),
          ),
        ),
        error: (error, stack) => const SizedBox(
          height: 118,
          child: Center(
            child: Text(
              '목표 정보를 불러오지 못했습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );

    if (!isMe) {
      return gaugeBody;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        splashColor: _accent.withOpacity(0.08),
        highlightColor: _accent.withOpacity(0.04),
        onTap: () {
          monthlyGoalAsync.when(
            data: (goalDistance) {
              FocusManager.instance.primaryFocus?.unfocus();

              _showGoalBottomSheet(
                userId: widget.userId,
                currentGoal: goalDistance,
              );
            },
            loading: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _surfaceSoft,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _line),
                  ),
                  content: const Text(
                    '목표량을 불러오는 중입니다.',
                    style: TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
            error: (error, stack) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: _surfaceSoft,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: _line),
                  ),
                  content: Text(
                    '오류: $error',
                    style: const TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: gaugeBody,
      ),
    );
  }
}

class _GoalBottomSheet extends StatelessWidget {
  final int currentMonth;
  final TextEditingController controller;
  final VoidCallback onClose;
  final Future<void> Function() onSave;

  const _GoalBottomSheet({
    required this.currentMonth,
    required this.controller,
    required this.onClose,
    required this.onSave,
  });

  static const Color _surface = Color(0xFF0F1115);
  static const Color _surfaceSoft = Color(0xFF171A20);
  static const Color _line = Color(0xFF272A31);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFA1A1AA);
  static const Color _softText = Color(0xFF6B7280);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3D46),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 18),

            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _accent.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: _accent,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currentMonth월 목표 설정',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: _primaryText,
                          letterSpacing: -0.45,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '이번 달 달릴 목표 거리를 입력해주세요.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: _secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  splashRadius: 20,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _secondaryText,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) async {
                await onSave();
              },
              style: const TextStyle(
                color: _primaryText,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              cursorColor: _accent,
              decoration: InputDecoration(
                hintText: '예: 100',
                suffixText: 'km',
                filled: true,
                fillColor: _surfaceSoft,
                hintStyle: const TextStyle(
                  color: _softText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                suffixStyle: const TextStyle(
                  color: _secondaryText,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: _line,
                    width: 0.9,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(17),
                  borderSide: const BorderSide(
                    color: _accent,
                    width: 1.4,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: _surfaceSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _line,
                  width: 0.8,
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: _secondaryText,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '목표는 언제든 다시 탭해서 수정할 수 있어요.',
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: onClose,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primaryText,
                        side: const BorderSide(
                          color: _line,
                          width: 0.9,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        await onSave();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        '저장',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeHeader extends StatelessWidget {
  final int currentMonth;
  final double percent;
  final bool isMe;

  const _GaugeHeader({
    required this.currentMonth,
    required this.percent,
    required this.isMe,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFA1A1AA);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 41,
          height: 41,
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.13),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.flag_rounded,
            color: _accent,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$currentMonth월 러닝 목표',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w900,
                  color: _primaryText,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                isMe ? '탭해서 목표를 수정할 수 있어요' : '이번 달 운동 거리',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.8,
                  color: _secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: _accent.withOpacity(0.13),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '${percent.toStringAsFixed(0)}%',
            maxLines: 1,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: _accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _GaugeDistanceRow extends StatelessWidget {
  final double totalDistanceKm;
  final double safeGoal;

  const _GaugeDistanceRow({
    required this.totalDistanceKm,
    required this.safeGoal,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFFA1A1AA);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  totalDistanceKm.toStringAsFixed(2),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    color: _primaryText,
                    height: 1,
                    letterSpacing: -0.7,
                  ),
                ),
                const SizedBox(width: 5),
                const Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Text(
                    'km',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _secondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '목표 ${safeGoal.toStringAsFixed(0)}km',
              maxLines: 1,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _secondaryText,
              ),
            ),
          ),
        ),
      ],
    );
  }
}