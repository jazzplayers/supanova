import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/widget/app_snack_bar.dart';
import 'package:home_function/workout_finish/feed/widget/comment/feed_comment_model.dart';
import 'package:home_function/workout_finish/feed/widget/comment/feed_comment_provider.dart';

class FeedCommentPage extends ConsumerStatefulWidget {
  final String workoutFinishId;

  /// 게시글 작성자 UID
  ///
  /// 게시글 작성자는 자신의 게시글에 달린 댓글을 삭제할 수 있습니다.
  final String postOwnerUid;

  /// 댓글 목록을 불러오기 전 표시할 초기 댓글 개수
  final int initialCommentsCount;

  const FeedCommentPage({
    super.key,
    required this.workoutFinishId,
    required this.postOwnerUid,
    this.initialCommentsCount = 0,
  });

  @override
  ConsumerState<FeedCommentPage> createState() => _FeedCommentPageState();
}

class _FeedCommentPageState extends ConsumerState<FeedCommentPage> {
  static const Color _background = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  final TextEditingController _commentController =
      TextEditingController();

  final FocusNode _commentFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _createComment() async {
    if (_isSubmitting) {
      return;
    }

    final text = _commentController.text.trim();

    if (text.isEmpty) {
      showAppSnackBar(
        context,
        message: '댓글 내용을 입력해주세요.',
        icon: Icons.info_outline_rounded,
        isError: true,
      );
      return;
    }

    if (text.length > 300) {
      showAppSnackBar(
        context,
        message: '댓글은 300자 이하로 입력해주세요.',
        icon: Icons.info_outline_rounded,
        isError: true,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref.read(
        createFeedCommentProvider(
          workoutFinishId: widget.workoutFinishId,
          text: text,
        ).future,
      );

      if (!mounted) {
        return;
      }

      _commentController.clear();

      setState(() {
        _isSubmitting = false;
      });

      _scrollToBottom();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      showAppSnackBar(
        context,
        message: _errorMessage(error),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    }
  }

  Future<void> _updateComment(
    FeedCommentModel comment,
  ) async {
    final editedText = await _showEditDialog(comment);

    if (editedText == null) {
      return;
    }

    final text = editedText.trim();

    if (text.isEmpty || text == comment.text.trim()) {
      return;
    }

    try {
      await ref.read(
        updateFeedCommentProvider(
          workoutFinishId: widget.workoutFinishId,
          commentId: comment.commentId,
          text: text,
        ).future,
      );

      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        message: '댓글이 수정되었습니다.',
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        message: _errorMessage(error),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    }
  }

  Future<String?> _showEditDialog(
    FeedCommentModel comment,
  ) async {
    final controller = TextEditingController(
      text: comment.text,
    );

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: _line,
              width: 0.8,
            ),
          ),
          title: const Text(
            '댓글 수정',
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLength: 300,
            maxLines: 5,
            minLines: 2,
            style: const TextStyle(
              color: _primaryText,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
            decoration: InputDecoration(
              hintText: '댓글 내용을 입력해주세요.',
              hintStyle: const TextStyle(
                color: _secondaryText,
              ),
              counterStyle: const TextStyle(
                color: _secondaryText,
              ),
              filled: true,
              fillColor: _surfaceSoft,
              contentPadding: const EdgeInsets.all(14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _line,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _line,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: _accent,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.isEmpty) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text(
                '수정',
                style: TextStyle(
                  color: _accent,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    return result;
  }

  Future<void> _deleteComment(
    FeedCommentModel comment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(
              color: _line,
              width: 0.8,
            ),
          ),
          title: const Text(
            '댓글 삭제',
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: const Text(
            '이 댓글을 삭제하시겠습니까?\n삭제한 댓글은 복구할 수 없습니다.',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text(
                '취소',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: _danger,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ref.read(
        deleteFeedCommentProvider(
          workoutFinishId: widget.workoutFinishId,
          commentId: comment.commentId,
        ).future,
      );

      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        message: '댓글이 삭제되었습니다.',
        icon: Icons.check_circle_outline_rounded,
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      showAppSnackBar(
        context,
        message: _errorMessage(error),
        icon: Icons.error_outline_rounded,
        isError: true,
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
      );
    });
  }

  String _errorMessage(Object error) {
    final message = error.toString().trim();

    if (message.isEmpty) {
      return '댓글 처리 중 오류가 발생했습니다.';
    }

    return message
        .replaceFirst('Exception: ', '')
        .replaceFirst('FeedCommentException: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final myUid = ref.watch(myUidProvider);

    final commentsAsync = ref.watch(
      feedCommentsProvider(
        workoutFinishId: widget.workoutFinishId,
      ),
    );

    final commentsCount = commentsAsync.maybeWhen(
      data: (comments) => comments.length,
      orElse: () => widget.initialCommentsCount,
    );

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 54,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).maybePop();
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _primaryText,
            size: 19,
          ),
        ),
        title: Text(
          '댓글 $commentsCount',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
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
      ),
      body: Column(
        children: [
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return const _EmptyCommentView();
                }

                return ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    14,
                    10,
                    20,
                  ),
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: comments.length,
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 4);
                  },
                  itemBuilder: (context, index) {
                    final comment = comments[index];

                    final isCommentOwner =
                        myUid != null &&
                        myUid == comment.userId;

                    final isPostOwner =
                        myUid != null &&
                        myUid == widget.postOwnerUid;

                    return _FeedCommentItem(
                      comment: comment,
                      canEdit: isCommentOwner,
                      canDelete: isCommentOwner || isPostOwner,
                      onEdit: () {
                        _updateComment(comment);
                      },
                      onDelete: () {
                        _deleteComment(comment);
                      },
                    );
                  },
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(
                    color: _accent,
                    strokeWidth: 2,
                  ),
                );
              },
              error: (error, stackTrace) {
                return _CommentErrorView(
                  message: _errorMessage(error),
                  onRetry: () {
                    ref.invalidate(
                      feedCommentsProvider(
                        workoutFinishId:
                            widget.workoutFinishId,
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _CommentInputBar(
            controller: _commentController,
            focusNode: _commentFocusNode,
            isSubmitting: _isSubmitting,
            enabled: myUid != null,
            onSubmit: _createComment,
          ),
        ],
      ),
    );
  }
}

class _FeedCommentItem extends StatelessWidget {
  final FeedCommentModel comment;
  final bool canEdit;
  final bool canDelete;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FeedCommentItem({
    required this.comment,
    required this.canEdit,
    required this.canDelete,
    required this.onEdit,
    required this.onDelete,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _danger = Color(0xFFE85D5D);

  bool get _hasProfileImage {
    final value = comment.profileImageUrl.trim();

    if (value.isEmpty) {
      return false;
    }

    final uri = Uri.tryParse(value);

    return uri != null &&
        uri.host.isNotEmpty &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              final uid = comment.userId.trim();

              if (uid.isNotEmpty) {
                context.push('/profile/$uid');
              }
            },
            child: CircleAvatar(
              radius: 19,
              backgroundColor: _surfaceSoft,
              backgroundImage: _hasProfileImage
                  ? CachedNetworkImageProvider(
                      comment.profileImageUrl,
                    )
                  : null,
              child: !_hasProfileImage
                  ? const Icon(
                      Icons.person_rounded,
                      color: _secondaryText,
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 7,
                  runSpacing: 2,
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        final uid = comment.userId.trim();

                        if (uid.isNotEmpty) {
                          context.push('/profile/$uid');
                        }
                      },
                      child: Text(
                        comment.displayName.trim().isEmpty
                            ? '사용자'
                            : comment.displayName,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Text(
                      _formatCommentTime(comment.createdAt),
                      style: const TextStyle(
                        color: _secondaryText,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (comment.isEdited)
                      const Text(
                        '수정됨',
                        style: TextStyle(
                          color: _secondaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  comment.text,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 14.5,
                    height: 1.42,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.15,
                  ),
                ),
              ],
            ),
          ),
          if (canEdit || canDelete)
            PopupMenuButton<String>(
              tooltip: '댓글 메뉴',
              color: const Color(0xFF0B0B0D),
              surfaceTintColor: Colors.transparent,
              icon: const Icon(
                Icons.more_horiz_rounded,
                color: _secondaryText,
                size: 21,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: const BorderSide(
                  color: Color(0xFF242428),
                  width: 0.8,
                ),
              ),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                }

                if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) {
                return [
                  if (canEdit)
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(
                            Icons.edit_outlined,
                            color: _primaryText,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '수정',
                            style: TextStyle(
                              color: _primaryText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (canDelete)
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: _danger,
                            size: 19,
                          ),
                          SizedBox(width: 10),
                          Text(
                            '삭제',
                            style: TextStyle(
                              color: _danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ];
              },
            ),
        ],
      ),
    );
  }
}

class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSubmitting;
  final bool enabled;
  final VoidCallback onSubmit;

  const _CommentInputBar({
    required this.controller,
    required this.focusNode,
    required this.isSubmitting,
    required this.enabled,
    required this.onSubmit,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(
          top: BorderSide(
            color: _line,
            width: 0.7,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            12,
            10,
            10,
            10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  enabled: enabled && !isSubmitting,
                  maxLength: 300,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 14.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                  buildCounter: (
                    context, {
                    required currentLength,
                    required isFocused,
                    required maxLength,
                  }) {
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: enabled
                        ? '댓글을 입력하세요.'
                        : '로그인이 필요합니다.',
                    hintStyle: const TextStyle(
                      color: _secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    filled: true,
                    fillColor: _surfaceSoft,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: _line,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: _line,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: _accent,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: const BorderSide(
                        color: _line,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 44,
                height: 44,
                child: IconButton(
                  onPressed: enabled && !isSubmitting
                      ? onSubmit
                      : null,
                  style: IconButton.styleFrom(
                    backgroundColor: _accent,
                    disabledBackgroundColor:
                        _accent.withAlpha(70),
                    shape: const CircleBorder(),
                  ),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: _primaryText,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.arrow_upward_rounded,
                          color: _primaryText,
                          size: 21,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCommentView extends StatelessWidget {
  const _EmptyCommentView();

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: _accent,
              size: 42,
            ),
            SizedBox(height: 14),
            Text(
              '아직 댓글이 없습니다.',
              style: TextStyle(
                color: _primaryText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: 7),
            Text(
              '첫 번째 댓글을 작성해보세요.',
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _CommentErrorView({
    required this.message,
    required this.onRetry,
  });

  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: _danger,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: _primaryText,
                side: const BorderSide(
                  color: Color(0xFF242428),
                ),
              ),
              child: const Text(
                '다시 시도',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatCommentTime(DateTime? dateTime) {
  if (dateTime == null) {
    return '방금 전';
  }

  final localDateTime = dateTime.toLocal();
  final now = DateTime.now();
  final difference = now.difference(localDateTime);

  if (difference.isNegative ||
      difference.inSeconds < 60) {
    return '방금 전';
  }

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}분 전';
  }

  if (difference.inHours < 24) {
    return '${difference.inHours}시간 전';
  }

  if (difference.inDays < 7) {
    return '${difference.inDays}일 전';
  }

  final year = localDateTime.year.toString();
  final month =
      localDateTime.month.toString().padLeft(2, '0');
  final day =
      localDateTime.day.toString().padLeft(2, '0');

  return '$year.$month.$day';
}