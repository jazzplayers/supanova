import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/follow/firestore/repo_provider.dart';
import 'package:home_function/follow/follow_service/follow_provider.dart';

class FollowButton extends ConsumerWidget {
  final String userId;
  final bool isMe;

  const FollowButton({
    super.key,
    required this.userId,
    required this.isMe,
  });

  static const _primaryText = Color(0xFF2B2F33);
  static const _accentColor = Color(0xFF4F7CF7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isMe) {
      return const SizedBox.shrink();
    }

    final myUid = ref.watch(myUidProvider);
    final followControllerState = ref.watch(followControllerProvider);
    final isSubmitting = followControllerState.isLoading;
    final followStatusAsync = myUid != null
        ? ref.watch(followStatusProvider(myUid, userId))
        : const AsyncValue.data(FollowState.notFollowing);

    return followStatusAsync.when(
      data: (followStatus) {
        final buttonText = isSubmitting
            ? '처리 중...'
            : switch (followStatus) {
                FollowState.notFollowing => '팔로우',
                FollowState.Following => '팔로잉',
                FollowState.FollowedBy => '맞팔로우',
                FollowState.MutualFollow => '친구',
              };

        final backgroundColor = switch (followStatus) {
          FollowState.notFollowing => _accentColor,
          FollowState.Following => Colors.grey.shade300,
          FollowState.FollowedBy => _accentColor,
          FollowState.MutualFollow => Colors.grey.shade300,
        };

        final foregroundColor = switch (followStatus) {
          FollowState.notFollowing => Colors.white,
          FollowState.Following => _primaryText,
          FollowState.FollowedBy => Colors.white,
          FollowState.MutualFollow => _primaryText,
        };

        return ElevatedButton(
          onPressed: (isSubmitting || myUid == null)
              ? null
              : () async {
                  final controller =
                      ref.read(followControllerProvider.notifier);

                  switch (followStatus) {
                    case FollowState.notFollowing:
                    case FollowState.FollowedBy:
                      await controller.follow(userId);
                      break;

                    case FollowState.Following:
                    case FollowState.MutualFollow:
                      await controller.unfollow(userId);
                      break;
                  }
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
      loading: () => _buildDisabledButton(),
      error: (_, __) => _buildErrorButton(),
    );
  }

  static Widget _buildDisabledButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        foregroundColor: _primaryText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text(
        '로딩 중...',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _primaryText,
        ),
      ),
    );
  }

  static Widget _buildErrorButton() {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade300,
        foregroundColor: _primaryText,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      child: const Text(
        '오류',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _primaryText,
        ),
      ),
    );
  }
}