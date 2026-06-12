import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/follow/firestore/repo_provider.dart';

enum FollowListType {
  followers,
  followings,
}

class FollowUserListPage extends ConsumerStatefulWidget {
  final String title;
  final String userId;
  final FollowListType type;

  const FollowUserListPage({
    super.key,
    required this.title,
    required this.userId,
    required this.type,
  });

  @override
  ConsumerState<FollowUserListPage> createState() => _FollowUserListPageState();
}

class _FollowUserListPageState extends ConsumerState<FollowUserListPage> {
  String _keyword = '';

  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _cardSoft = Color(0xFF1D2630);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final idsAsync = widget.type == FollowListType.followers
        ? ref.watch(followersListProvider(widget.userId))
        : ref.watch(followingsListProvider(widget.userId));

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: idsAsync.when(
          data: (ids) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                  child: Column(
                    children: [
                      _CountHeader(
                        title: widget.title,
                        count: ids.length,
                        type: widget.type,
                      ),
                      const SizedBox(height: 10),
                      _SearchBox(
                        hintText: '${widget.title} 검색',
                        onChanged: (value) {
                          setState(() {
                            _keyword = value.trim().toLowerCase();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ids.isEmpty
                      ? _EmptyFollowUserView(title: widget.title)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: ids.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            return FollowUserTile(
                              uid: ids[index],
                              keyword: _keyword,
                            );
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: _blue),
          ),
          error: (e, st) => Center(
            child: Text(
              '${widget.title} 목록을 불러오지 못했습니다.',
              style: const TextStyle(
                color: _secondaryText,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FollowUserTile extends ConsumerWidget {
  final String uid;
  final String keyword;

  const FollowUserTile({
    super.key,
    required this.uid,
    required this.keyword,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _cardSoft = Color(0xFF1D2630);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userAuthDataProvider(uid));

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const SizedBox.shrink();
        }

        final displayName = user.displayName;
        final email = user.email;

        if (keyword.isNotEmpty &&
            !displayName.toLowerCase().contains(keyword) &&
            !email.toLowerCase().contains(keyword)) {
          return const SizedBox.shrink();
        }

        final hasProfileImage =
            user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.push('/user/$uid');
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _blue.withValues(alpha: 0.22),
                      width: 1.2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: _blue.withValues(alpha: 0.14),
                    backgroundImage: hasProfileImage
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: !hasProfileImage
                        ? const Icon(
                            Icons.person_rounded,
                            color: _blue,
                            size: 24,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _primaryText,
                          fontSize: 15,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _secondaryText,
                          fontSize: 12.5,
                          height: 1.1,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: _cardSoft,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.chevron_right_rounded,
                    color: _secondaryText,
                    size: 21,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const _FollowUserSkeleton(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _CountHeader extends StatelessWidget {
  final String title;
  final int count;
  final FollowListType type;

  const _CountHeader({
    required this.title,
    required this.count,
    required this.type,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _cardSoft = Color(0xFF1D2630);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final icon = type == FollowListType.followers
        ? Icons.people_alt_rounded
        : Icons.person_add_alt_1_rounded;

    final subText =
        type == FollowListType.followers ? '나를 팔로우하는 사람' : '내가 팔로우하는 사람';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _blue.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: _blue,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    height: 1.1,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subText,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 12.5,
                    height: 1.1,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _cardSoft,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: _blue.withValues(alpha: 0.18),
              ),
            ),
            child: Text(
              '$count명',
              style: const TextStyle(
                color: _blue,
                fontSize: 14,
                height: 1,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final String hintText;
  final ValueChanged<String> onChanged;

  const _SearchBox({
    required this.hintText,
    required this.onChanged,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          color: _primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        cursorColor: _blue,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: _secondaryText,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _secondaryText,
            size: 21,
          ),
          filled: true,
          fillColor: _card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: const BorderSide(
              color: _blue,
              width: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyFollowUserView extends StatelessWidget {
  final String title;

  const _EmptyFollowUserView({
    required this.title,
  });

  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 28,
        ),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _blue.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.people_outline_rounded,
                size: 28,
                color: _blue,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              '$title 목록이 없습니다.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _primaryText,
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              '아직 표시할 사용자가 없어요.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _secondaryText,
                fontSize: 13,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FollowUserSkeleton extends StatelessWidget {
  const _FollowUserSkeleton();

  static const Color _card = Color(0xFF151B22);
  static const Color _cardSoft = Color(0xFF1D2630);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: _cardSoft,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 13,
                  decoration: BoxDecoration(
                    color: _cardSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 11,
                  decoration: BoxDecoration(
                    color: _cardSoft,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}