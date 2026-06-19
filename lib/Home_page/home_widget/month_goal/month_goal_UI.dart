import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/Home_page/home_widget/month_goal/month_goal_provider.dart';
import 'package:home_function/core/firebase.dart';
import 'package:home_function/widget/app_snack_bar.dart';
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
  final ValueNotifier<bool> _savingGoalNotifier = ValueNotifier<bool>(false);

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  bool get _isSavingGoal => _savingGoalNotifier.value;

  int get currentMonth => DateTime.now().month;

  bool _isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  ScrollPhysics _scrollPhysics(BuildContext context) {
    return _isIOS(context)
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics();
  }

  @override
  void dispose() {
    monthlyGoalCtrl.dispose();
    _savingGoalNotifier.dispose();
    super.dispose();
  }

  Future<void> _showGoalBottomSheet({
    required String userId,
    required double currentGoal,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();

    monthlyGoalCtrl.text =
        currentGoal == 0 ? '' : currentGoal.toStringAsFixed(1);

    _savingGoalNotifier.value = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      isDismissible: false,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.68),
      builder: (sheetContext) {
        final media = MediaQuery.of(sheetContext);
        final isIOS = _isIOS(sheetContext);
        final maxWidth = math.min(media.size.width, 520.0);

        return ValueListenableBuilder<bool>(
          valueListenable: _savingGoalNotifier,
          builder: (context, isSaving, _) {
            return SizedBox(
              height: media.size.height,
              width: double.infinity,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: isSaving
                    ? null
                    : () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.of(sheetContext).pop();
                      },
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 8,
                    right: 8,
                    bottom: media.viewInsets.bottom + (isIOS ? 8 : 10),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        // 바텀시트 내부 터치는 닫히지 않게 막음
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: maxWidth,
                        ),
                        child: _GoalBottomSheet(
                          currentMonth: currentMonth,
                          controller: monthlyGoalCtrl,
                          isSaving: isSaving,
                          scrollPhysics: _scrollPhysics(sheetContext),
                          onClose: isSaving
                              ? null
                              : () {
                                  Navigator.of(sheetContext).pop();
                                },
                          onSave: () async {
                            await _saveGoal(sheetContext, userId);
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    FocusManager.instance.primaryFocus?.unfocus();

    if (mounted) {
      _savingGoalNotifier.value = false;
    }
  }

  Future<void> _saveGoal(BuildContext sheetContext, String userId) async {
    if (_isSavingGoal) return;

    final text = monthlyGoalCtrl.text.trim();
    final goal = double.tryParse(text);

    if (goal == null || goal <= 0) {
      showAppSnackBar(
        context,
        message: '목표 거리를 0보다 크게 입력해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    if (goal > 9999) {
      showAppSnackBar(
        context,
        message: '목표 거리는 9999km 이하로 입력해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    _savingGoalNotifier.value = true;

    try {
      await ref.read(monthGoalRepoProvider).setMonthlyGoal(userId, goal);

      if (sheetContext.mounted) {
        Navigator.of(sheetContext).pop();
      }

      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '${goal.toStringAsFixed(0)}km 목표로 설정했어요.',
        icon: Icons.check_circle_rounded,
      );
    } catch (_) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        message: '목표를 저장하지 못했습니다. 다시 시도해주세요.',
        icon: Icons.error_rounded,
        isError: true,
      );
    } finally {
      if (mounted) {
        _savingGoalNotifier.value = false;
      }
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
          final totalDistanceMeters = totalDistanceThisMonthAsync.maybeWhen(
            data: (total) => total,
            orElse: () => 0.0,
          );

          final totalDistanceKm = totalDistanceMeters / 1000.0;

          final hasUserGoal = isMe && goalDistance > 0;
          final safeGoal = hasUserGoal
              ? goalDistance
              : math.max(totalDistanceKm, 100.0);

          final gaugeValue =
              totalDistanceKm > safeGoal ? safeGoal : totalDistanceKm;

          final percent = hasUserGoal
              ? ((totalDistanceKm / safeGoal) * 100).clamp(0, 100).toDouble()
              : null;

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
                isMe: isMe,
                hasUserGoal: hasUserGoal,
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
              color: _accent,
              strokeWidth: 2.4,
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
        splashColor: _accent.withValues(alpha: 0.08),
        highlightColor: _accent.withValues(alpha: 0.04),
        onTap: () {
          monthlyGoalAsync.when(
            data: (goalDistance) {
              _showGoalBottomSheet(
                userId: widget.userId,
                currentGoal: goalDistance,
              );
            },
            loading: () {
              showAppSnackBar(
                context,
                message: '목표 정보를 불러오는 중입니다.',
                icon: Icons.info_outline_rounded,
              );
            },
            error: (error, stack) {
              showAppSnackBar(
                context,
                message: '목표 정보를 불러오지 못했습니다. 다시 시도해주세요.',
                icon: Icons.error_rounded,
                isError: true,
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
  final bool isSaving;
  final ScrollPhysics scrollPhysics;
  final VoidCallback? onClose;
  final Future<void> Function() onSave;

  const _GoalBottomSheet({
    required this.currentMonth,
    required this.controller,
    required this.isSaving,
    required this.scrollPhysics,
    required this.onClose,
    required this.onSave,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: media.size.height * 0.86,
      ),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _line,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        physics: scrollPhysics,
        padding: EdgeInsets.fromLTRB(
          18,
          10,
          18,
          18 + media.padding.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF3A3A40),
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
                    color: _accent.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _accent.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: const Icon(
                    Icons.flag_rounded,
                    color: _accent,
                    size: 25,
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
                  tooltip: '닫기',
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    color: isSaving ? _softText : _secondaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            TextField(
              controller: controller,
              enabled: !isSaving,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) async {
                if (!isSaving) {
                  await onSave();
                }
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
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: _line,
                    width: 0.8,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: _accent,
                    width: 1.2,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(
                    color: _line,
                    width: 0.8,
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
                      '목표는 언제든 다시 눌러 수정할 수 있어요.',
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
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 310;

                final cancelButton = SizedBox(
                  height: 50,
                  child: OutlinedButton(
                    onPressed: isSaving ? null : onClose,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryText,
                      disabledForegroundColor: _softText,
                      side: const BorderSide(
                        color: _line,
                        width: 0.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      '취소',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );

                final saveButton = SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            await onSave();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: _surfaceSoft,
                      disabledForegroundColor: _softText,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: isSaving
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.3,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '저장',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
                );

                if (narrow) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: saveButton,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: cancelButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: cancelButton),
                    const SizedBox(width: 10),
                    Expanded(child: saveButton),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _GaugeHeader extends StatelessWidget {
  final int currentMonth;
  final double? percent;
  final bool isMe;

  const _GaugeHeader({
    required this.currentMonth,
    required this.percent,
    required this.isMe,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final pillText =
        percent == null ? '이번 달' : '${percent!.toStringAsFixed(0)}%';

    return Row(
      children: [
        Container(
          width: 41,
          height: 41,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.13),
            shape: BoxShape.circle,
            border: Border.all(
              color: _accent.withValues(alpha: 0.25),
              width: 0.8,
            ),
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
                isMe ? '$currentMonth월 러닝 목표' : '$currentMonth월 운동 거리',
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
                isMe ? '탭해서 목표를 수정할 수 있어요' : '이번 달 누적 운동 거리',
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
            color: _accent.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            pillText,
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
  final bool isMe;
  final bool hasUserGoal;

  const _GaugeDistanceRow({
    required this.totalDistanceKm,
    required this.safeGoal,
    required this.isMe,
    required this.hasUserGoal,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    final rightText = isMe
        ? hasUserGoal
            ? '목표 ${safeGoal.toStringAsFixed(0)}km'
            : '기본 목표 ${safeGoal.toStringAsFixed(0)}km'
        : '이번 달 누적';

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
              rightText,
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