part of '../feed_page.dart';

class FeedCard extends ConsumerWidget {
  final double availableHeight;
  final double topOverlayInset;
  final double bottomOverlayInset;
  final bool isInFeedList;
  final String postOwnerUid;
  final String displayName;
  final String email;
  final String? userProfileUrl;
  final WorkoutFinish workoutFinish;
  final ValueChanged<WorkoutFinish> onUpdated;

  const FeedCard({
    super.key,
    required this.availableHeight,
    this.topOverlayInset = 0,
    this.bottomOverlayInset = 0,
    this.isInFeedList = false,
    required this.postOwnerUid,
    required this.displayName,
    required this.email,
    this.userProfileUrl,
    required this.workoutFinish,
    required this.onUpdated,
  });

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  Future<void> _goToEditPage({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final updated = await Navigator.of(context).push<WorkoutFinish>(
      MaterialPageRoute(
        builder: (_) => FeedEditPage(
          workoutFinish: workoutFinish,
        ),
      ),
    );

    if (updated == null) return;
    if (!context.mounted) return;

    onUpdated(updated);

    final workoutId = updated.workoutId;

    ref.invalidate(todayWorkoutFinishProvider);
    ref.invalidate(workoutFinishListProvider(updated.userId));
    ref.invalidate(feedWorkoutFinishProvider(updated.userId));

    if (workoutId != null && workoutId.isNotEmpty) {
      ref.invalidate(
        workoutFinishProvider(
          workoutFinishId: workoutId,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        final media = MediaQuery.of(dialogContext);
        final maxWidth = math.min(media.size.width - 32, 380.0);

        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: media.size.height * 0.86,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
                        color: _danger.withOpacity(0.14),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 32,
                        color: _danger,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '게시글 삭제',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _primaryText,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '삭제한 게시글은 되돌릴 수 없습니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 14,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 22),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 300;

                        final cancelButton = SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _primaryText,
                              side: const BorderSide(
                                color: _line,
                                width: 0.8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '취소',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );

                        final deleteButton = SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _danger,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              '삭제',
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
                                child: deleteButton,
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
                            Expanded(child: deleteButton),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    if (result != true) return;

    await _deletePost(
      context: context,
      ref: ref,
    );
  }

  Future<void> _deletePost({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    try {
      final workoutId = workoutFinish.workoutId;

      if (workoutId == null || workoutId.isEmpty) {
        throw Exception('운동 기록 ID가 없습니다.');
      }

      await ref.read(
        deleteWorkoutFinishProvider(
          workoutFinish: workoutFinish,
        ).future,
      );

      if (!context.mounted) return;

      ref.invalidate(todayWorkoutFinishProvider);
      ref.invalidate(workoutFinishListProvider(workoutFinish.userId));
      ref.invalidate(feedWorkoutFinishProvider(workoutFinish.userId));
      ref.invalidate(
        workoutFinishProvider(
          workoutFinishId: workoutId,
        ),
      );

      showAppSnackBar(
        context,
        message: '게시글이 삭제되었습니다.',
        icon: Icons.check_circle_rounded,
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!context.mounted) return;

      showAppSnackBar(
        context,
        message: '삭제 중 오류가 발생했습니다.',
        icon: Icons.error_rounded,
        isError: true,
      );
    }
  }

  Future<void> _showReportBottomSheet({
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    final workoutId = workoutFinish.workoutId;

    if (workoutId == null || workoutId.isEmpty) {
      showAppSnackBar(
        context,
        message: '신고할 운동 기록 ID가 없습니다.',
        icon: Icons.error_rounded,
        isError: true,
      );
      return;
    }

    const reasons = <String, String>{
      'spam': '스팸 또는 광고',
      'harassment': '괴롭힘 또는 비방',
      'hate': '혐오 표현',
      'sexual': '선정적인 콘텐츠',
      'violence': '폭력적인 콘텐츠',
      'privacy': '개인정보 노출',
      'illegal': '불법 또는 위험한 행위',
      'other': '기타',
    };

    String selectedReason = 'spam';
    bool isSubmitting = false;
    final reasonController = TextEditingController();

    final submittedMessage = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withAlpha(173),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            Future<void> submitReport() async {
              if (isSubmitting) return;

              setModalState(() {
                isSubmitting = true;
              });

              try {
                final result = await ref.read(
                  createReportProvider(
                    targetType: 'workoutFinish',
                    targetId: workoutId,
                    reasonCode: selectedReason,
                    reasonText: reasonController.text.trim(),
                  ).future,
                );

                if (!sheetContext.mounted) return;

                Navigator.of(sheetContext).pop(
                  result.alreadyReported
                      ? '이미 신고한 게시글입니다.'
                      : '신고가 접수되었습니다.',
                );
              } catch (e, st) {
                debugPrint('createReport error: $e');
                debugPrint('createReport stackTrace: $st');

                if (!modalContext.mounted) return;

                final message = e
                    .toString()
                    .replaceFirst('Exception: ', '')
                    .trim();

                showAppSnackBar(
                  modalContext,
                  message: message.isEmpty
                      ? '신고에 실패했습니다. 잠시 후 다시 시도해주세요.'
                      : message,
                  icon: Icons.error_rounded,
                  isError: true,
                );

                setModalState(() {
                  isSubmitting = false;
                });
              }
            }

            return PopScope(
              canPop: !isSubmitting,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(modalContext).viewInsets.bottom + 14,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _line,
                        width: 0.8,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Container(
                              width: 38,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF3A3A40),
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            '게시글 신고하기',
                            style: TextStyle(
                              color: _primaryText,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '이 운동 기록을 신고하는 이유를 선택해주세요. 접수된 신고는 검토 후 처리됩니다.',
                            style: TextStyle(
                              color: _secondaryText,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Container(
                            decoration: BoxDecoration(
                              color: _surfaceSoft,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: _line,
                                width: 0.8,
                              ),
                            ),
                            child: Column(
                              children: reasons.entries.map((entry) {
                                final isSelected =
                                    selectedReason == entry.key;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(18),
                                  onTap: isSubmitting
                                      ? null
                                      : () {
                                          setModalState(() {
                                            selectedReason = entry.key;
                                          });
                                        },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 13,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          isSelected
                                              ? Icons.radio_button_checked
                                              : Icons.radio_button_off,
                                          color: isSelected
                                              ? _accent
                                              : _secondaryText,
                                          size: 21,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: TextStyle(
                                              color: isSelected
                                                  ? _primaryText
                                                  : _secondaryText,
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w800
                                                  : FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          if (selectedReason == 'other') ...[
                            const SizedBox(height: 14),
                            TextField(
                              controller: reasonController,
                              enabled: !isSubmitting,
                              maxLength: 300,
                              maxLines: 3,
                              style: const TextStyle(
                                color: _primaryText,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: '신고 내용을 입력해주세요.',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF77777D),
                                  fontWeight: FontWeight.w500,
                                ),
                                counterStyle: const TextStyle(
                                  color: Color(0xFF77777D),
                                ),
                                filled: true,
                                fillColor: _surfaceSoft,
                                contentPadding: const EdgeInsets.all(14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _line,
                                    width: 0.8,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _line,
                                    width: 0.8,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: const BorderSide(
                                    color: _accent,
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: TextButton(
                                    onPressed: isSubmitting
                                        ? null
                                        : () {
                                            Navigator.of(sheetContext).pop();
                                          },
                                    style: TextButton.styleFrom(
                                      foregroundColor: _secondaryText,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                        side: const BorderSide(
                                          color: _line,
                                          width: 0.8,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      '취소',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed:
                                        isSubmitting ? null : submitReport,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _danger,
                                      foregroundColor: _primaryText,
                                      disabledBackgroundColor:
                                          _danger.withAlpha(90),
                                      disabledForegroundColor:
                                          _primaryText.withAlpha(150),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    child: isSubmitting
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: _primaryText,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            '신고 접수',
                                            style: TextStyle(
                                              fontSize: 15,
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reasonController.dispose();

    if (!context.mounted) return;

    if (submittedMessage != null && submittedMessage.isNotEmpty) {
      showAppSnackBar(
        context,
        message: submittedMessage,
        icon: Icons.check_circle_rounded,
      );
    }
  }

  String _formatTime() {
    final createdAt = workoutFinish.createdAt;

    if (createdAt == null) return '';

    final y = createdAt.year.toString();
    final m = createdAt.month.toString().padLeft(2, '0');
    final d = createdAt.day.toString().padLeft(2, '0');
    final h = createdAt.hour.toString().padLeft(2, '0');
    final min = createdAt.minute.toString().padLeft(2, '0');

    return '$y.$m.$d $h:$min';
  }

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours시간 $minutes분 $seconds초';
    }

    return '$minutes분 $seconds초';
  }

  String _formatPace(double pace) {
    if (pace.isNaN || pace.isInfinite || pace <= 0) {
      return '--:-- min/km';
    }

    final totalSeconds = (pace * 60).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')} min/km';
  }

  String _formatDurationMetricValue(int totalSeconds) {
    if (totalSeconds <= 0) return '--';

    if (totalSeconds >= 3600) {
      final hours = totalSeconds / 3600;
      return hours.toStringAsFixed(hours >= 10 ? 0 : 1);
    }

    final minutes = totalSeconds / 60;
    if (minutes < 10) {
      return minutes.toStringAsFixed(1);
    }

    return minutes.round().toString();
  }

  String _formatDurationMetricUnit(int totalSeconds) {
    if (totalSeconds <= 0) return '';
    return totalSeconds >= 3600 ? '시간' : '분';
  }

  String _formatPaceMetricValue(double pace) {
    if (pace.isNaN || pace.isInfinite || pace <= 0) {
      return '--';
    }

    final totalSeconds = (pace * 60).round();
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final secondsText = seconds.toString().padLeft(2, '0');

    return "$minutes'$secondsText\"";
  }

  String _formatSpeedMetricValue(double speedKmh) {
    if (speedKmh.isNaN || speedKmh.isInfinite || speedKmh <= 0) {
      return '--';
    }

    return speedKmh.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasImages = workoutFinish.workoutImagesUrl.isNotEmpty;
    final hasRoute = workoutFinish.routePoints.isNotEmpty;

    final myUid = ref.watch(myUidProvider);
    final isMyPost = myUid == postOwnerUid;
    final canReportPost = !isMyPost &&
        myUid != null &&
        workoutFinish.workoutId != null &&
        workoutFinish.workoutId!.isNotEmpty;

    final distanceKm = workoutFinish.distanceMeters / 1000;
    final durationValue = _formatDurationMetricValue(workoutFinish.seconds);
    final durationUnit = _formatDurationMetricUnit(workoutFinish.seconds);
    final paceValue = _formatPaceMetricValue(workoutFinish.paceMinPerKm);
    final speedValue = _formatSpeedMetricValue(workoutFinish.speedKmh);

    final profileImageUrl = userProfileUrl?.trim();
    final hasProfileImage = _isValidNetworkImageUrl(profileImageUrl);

    final safeTopSpacing = isInFeedList
        ? topOverlayInset.clamp(0.0, 120.0).toDouble()
        : 0.0;
    final safeBottomSpacing = bottomOverlayInset.clamp(0.0, 40.0).toDouble();

    // 프로필/이름은 이미지 위가 아니라 이미지 밖으로 빼서 FeedList 상단 UI와 겹치지 않게 둡니다.
    // 남는 세로 공간은 이미지/지도 히어로 영역에 몰아 한 화면이 꽉 차 보이게 합니다.
    final heroHeight = (availableHeight - safeTopSpacing - 168 - safeBottomSpacing)
        .clamp(390.0, 640.0)
        .toDouble();

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: availableHeight,
      ),
      color: _bg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: safeTopSpacing + 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 10, 0),
            child: _FeedHeader(
              displayName: displayName,
              timeText: _formatTime(),
              postOwnerUid: postOwnerUid,
              profileImageUrl: profileImageUrl,
              hasProfileImage: hasProfileImage,
              trailing: _FeedMoreButton(
                isMyPost: isMyPost,
                canReportPost: canReportPost,
                onEdit: () {
                  _goToEditPage(
                    context: context,
                    ref: ref,
                  );
                },
                onDelete: () {
                  _showDeleteDialog(
                    context: context,
                    ref: ref,
                  );
                },
                onReport: () {
                  _showReportBottomSheet(
                    context: context,
                    ref: ref,
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: _FullScreenFeedHero(
              height: heroHeight,
              imageUrls: workoutFinish.workoutImagesUrl,
              thumbnailUrl: workoutFinish.workoutThumbnailUrl,
              routePoints: workoutFinish.routePoints,
              hasImages: hasImages,
              hasRoute: hasRoute,
              distanceText: distanceKm.toStringAsFixed(2),
              durationValue: durationValue,
              durationUnit: durationUnit,
              paceValue: paceValue,
              speedValue: speedValue,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                if (myUid != null &&
                    workoutFinish.workoutId != null &&
                    workoutFinish.workoutId!.isNotEmpty)
                  LikeButton(
                    myUid: myUid,
                    workoutFinishId: workoutFinish.workoutId!,
                  ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _line,
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.done_all_rounded,
                        color: _accent,
                        size: 15,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        hasRoute ? '경로 포함' : '운동 완료',
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 5, 16, 14 + safeBottomSpacing),
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: displayName,
                    style: const TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const TextSpan(
                    text: ' 님이 운동을 완료했습니다.',
                    style: TextStyle(
                      color: _primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
