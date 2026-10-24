part of '../feed_page.dart';

class _FeedHeader extends StatelessWidget {
  final String displayName;
  final String timeText;
  final String postOwnerUid;
  final String? profileImageUrl;
  final bool hasProfileImage;
  final Widget trailing;

  const _FeedHeader({
    required this.displayName,
    required this.timeText,
    required this.postOwnerUid,
    required this.profileImageUrl,
    required this.hasProfileImage,
    required this.trailing,
  });

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (postOwnerUid.isNotEmpty) {
              context.push('/profile/$postOwnerUid');
            }
          },
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: _surfaceSoft,
                backgroundImage: hasProfileImage
                    ? CachedNetworkImageProvider(profileImageUrl!)
                    : null,
                child: !hasProfileImage
                    ? const Icon(
                        Icons.person_rounded,
                        color: _secondaryText,
                        size: 23,
                      )
                    : null,
              ),
              const SizedBox(width: 11),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (postOwnerUid.isNotEmpty) {
                context.push('/profile/$postOwnerUid');
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.25,
                  ),
                ),
                if (timeText.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    timeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _secondaryText,
                      fontSize: 12.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        trailing,
      ],
    );
  }
}

class _FeedMoreButton extends StatelessWidget {
  final bool isMyPost;
  final bool canReportPost;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onReport;

  const _FeedMoreButton({
    required this.isMyPost,
    required this.canReportPost,
    required this.onEdit,
    required this.onDelete,
    required this.onReport,
  });

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    if (!isMyPost && !canReportPost) {
      return const SizedBox(width: 44, height: 44);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(124),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withAlpha(22),
          width: 0.8,
        ),
      ),
      child: PopupMenuButton<String>(
        tooltip: '메뉴',
        color: _surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: _line,
            width: 0.8,
          ),
        ),
        icon: const Icon(
          Icons.more_horiz_rounded,
          color: _primaryText,
        ),
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          }

          if (value == 'delete') {
            onDelete();
          }

          if (value == 'report') {
            onReport();
          }
        },
        itemBuilder: (context) {
          if (isMyPost) {
            return const [
              PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      color: _accent,
                      size: 20,
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
              PopupMenuDivider(),
              PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: _danger,
                      size: 20,
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
          }

          return const [
            PopupMenuItem<String>(
              value: 'report',
              child: Row(
                children: [
                  Icon(
                    Icons.flag_outlined,
                    color: _danger,
                    size: 20,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '신고하기',
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
    );
  }
}
