import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UserSearchPage extends StatefulWidget {
  const UserSearchPage({
    super.key,
    required this.currentUserId,
  });

  final String currentUserId;

  @override
  State<UserSearchPage> createState() => _UserSearchPageState();
}

class _UserSearchPageState extends State<UserSearchPage> {
  static const Color _bg = Color(0xFF000000);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _searchDebounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final nextQuery = _searchController.text.trim();

    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      if (nextQuery == _query) return;

      setState(() {
        _query = nextQuery;
      });
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();

    _searchController.clear();

    if (_query.isNotEmpty) {
      setState(() {
        _query = '';
      });
    }

    _searchFocusNode.requestFocus();
  }

  ScrollPhysics _pageScrollPhysics(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      return const BouncingScrollPhysics();
    }

    return const ClampingScrollPhysics();
  }

  @override
  Widget build(BuildContext context) {
    final contentPadding = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 16.0;

    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        toolbarHeight: 52,
        title: const Text(
          '검색',
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
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  contentPadding,
                  14,
                  contentPadding,
                  10,
                ),
                child: _SearchTextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onClear: _clearSearch,
                ),
              ),
              Expanded(
                child: _UserSearchBody(
                  query: _query,
                  currentUserId: widget.currentUserId,
                  scrollPhysics: _pageScrollPhysics(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchTextField extends StatelessWidget {
  const _SearchTextField({
    required this.controller,
    required this.focusNode,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onClear;

  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final hasText = value.text.trim().isNotEmpty;

        return TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          cursorColor: _accent,
          autocorrect: false,
          enableSuggestions: false,
          style: const TextStyle(
            color: _primaryText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: _surface,
            hintText: '닉네임 검색',
            hintStyle: const TextStyle(
              color: _secondaryText,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
            ),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: _secondaryText,
              size: 22,
            ),
            suffixIcon: hasText
                ? IconButton(
                    tooltip: '검색어 지우기',
                    onPressed: onClear,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: _secondaryText,
                      size: 21,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
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
                width: 1.2,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _UserSearchBody extends StatelessWidget {
  const _UserSearchBody({
    required this.query,
    required this.currentUserId,
    required this.scrollPhysics,
  });

  final String query;
  final String currentUserId;
  final ScrollPhysics scrollPhysics;

  static const Color _bg = Color(0xFF000000);
  static const Color _line = Color(0xFF242428);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  @override
  Widget build(BuildContext context) {
    final queryText = query.trim();

    if (queryText.isEmpty) {
      return const _SearchEmptyState(
        icon: Icons.search_rounded,
        title: '유저를 검색해보세요',
        subtitle: '닉네임을 입력하면 사용자를 찾을 수 있어요.',
      );
    }

    return ColoredBox(
      color: _bg,
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('displayName')
            .where('displayName', isGreaterThanOrEqualTo: queryText)
            .where('displayName', isLessThanOrEqualTo: '$queryText\uf8ff')
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: _accent,
                ),
              ),
            );
          }

          if (snapshot.hasError) {
            debugPrint('UserSearchPage search error: ${snapshot.error}');

            return const _SearchEmptyState(
              icon: Icons.error_outline_rounded,
              title: '검색 중 오류가 발생했습니다',
              subtitle: '잠시 후 다시 시도해주세요.',
              iconColor: _danger,
            );
          }

          final docs = snapshot.data?.docs
                  .where((doc) => doc.id != currentUserId)
                  .toList() ??
              [];

          if (docs.isEmpty) {
            return const _SearchEmptyState(
              icon: Icons.person_search_rounded,
              title: '검색 결과가 없습니다',
              subtitle: '다른 닉네임으로 다시 검색해보세요.',
            );
          }

          return ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            physics: scrollPhysics,
            padding: EdgeInsets.fromLTRB(
              0,
              8,
              0,
              88 + MediaQuery.paddingOf(context).bottom,
            ),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(
              color: _line,
              height: 0.7,
              thickness: 0.7,
              indent: 82,
            ),
            itemBuilder: (context, index) {
              final userDoc = docs[index];
              final userId = userDoc.id;
              final data = userDoc.data();

              final rawDisplayName = data['displayName'];
              final displayName =
                  rawDisplayName is String && rawDisplayName.trim().isNotEmpty
                      ? rawDisplayName.trim()
                      : '사용자';

              final rawProfileImageUrl = data['profileImageUrl'];
              final profileImageUrl = rawProfileImageUrl is String
                  ? rawProfileImageUrl.trim()
                  : null;

              final hasProfileImage =
                  profileImageUrl != null && profileImageUrl.isNotEmpty;

              return _UserSearchTile(
                userId: userId,
                displayName: displayName,
                profileImageUrl: profileImageUrl,
                hasProfileImage: hasProfileImage,
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.push('/user/$userId');
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _UserSearchTile extends StatelessWidget {
  const _UserSearchTile({
    required this.userId,
    required this.displayName,
    required this.profileImageUrl,
    required this.hasProfileImage,
    required this.onTap,
  });

  final String userId;
  final String displayName;
  final String? profileImageUrl;
  final bool hasProfileImage;
  final VoidCallback onTap;

  static const Color _bg = Color(0xFF000000);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = MediaQuery.sizeOf(context).width < 360 ? 14.0 : 16.0;

    return Material(
      color: _bg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: 11,
          ),
          child: Row(
            children: [
              _UserSearchAvatar(
                profileImageUrl: profileImageUrl,
                hasProfileImage: hasProfileImage,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _primaryText,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '프로필 보기',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _secondaryText,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: _secondaryText,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserSearchAvatar extends StatelessWidget {
  const _UserSearchAvatar({
    required this.profileImageUrl,
    required this.hasProfileImage,
  });

  final String? profileImageUrl;
  final bool hasProfileImage;

  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _accent.withAlpha(230),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: ColoredBox(
          color: _surfaceSoft,
          child: hasProfileImage && profileImageUrl != null
              ? Image.network(
                  profileImageUrl!,
                  fit: BoxFit.cover,
                  width: 48,
                  height: 48,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person_rounded,
                      color: _secondaryText,
                      size: 27,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;

                    return const Center(
                      child: SizedBox(
                        width: 17,
                        height: 17,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _secondaryText,
                        ),
                      ),
                    );
                  },
                )
              : const Icon(
                  Icons.person_rounded,
                  color: _secondaryText,
                  size: 27,
                ),
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  const _SearchEmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color? iconColor;

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    final pointColor = iconColor ?? _accent;

    return ColoredBox(
      color: _bg,
      child: Center(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            88 + MediaQuery.paddingOf(context).bottom,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _line,
                width: 0.8,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: pointColor.withAlpha(33),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: pointColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _secondaryText,
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}