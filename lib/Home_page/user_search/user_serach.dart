import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:home_function/widget/app_snack_bar.dart';

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
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);
  static const Color _danger = Color(0xFFE85D5D);

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _query = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      final nextQuery = _searchController.text.trim();

      if (nextQuery == _query) return;

      setState(() {
        _query = nextQuery;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
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
  });

  final String query;
  final String currentUserId;

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
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) return;

              showAppSnackBar(
                context,
                message: '검색 중 오류가 발생했습니다.',
                icon: Icons.error_rounded,
                isError: true,
              );
            });

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
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              0,
              8,
              0,
              90 + MediaQuery.paddingOf(context).bottom,
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

              final displayName =
                  (data['displayName'] as String?)?.trim().isNotEmpty == true
                      ? data['displayName'] as String
                      : '사용자';

              final email = (data['email'] as String?) ?? '';

              final profileImageUrl =
                  (data['profileImageUrl'] as String?)?.trim();

              final hasProfileImage =
                  profileImageUrl != null && profileImageUrl.isNotEmpty;

              return _UserSearchTile(
                userId: userId,
                displayName: displayName,
                email: email,
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
    required this.email,
    required this.profileImageUrl,
    required this.hasProfileImage,
    required this.onTap,
  });

  final String userId;
  final String displayName;
  final String email;
  final String? profileImageUrl;
  final bool hasProfileImage;
  final VoidCallback onTap;

  static const Color _bg = Color(0xFF000000);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _accent = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _bg,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 11,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _accent.withOpacity(0.9),
                    width: 1.5,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: _surfaceSoft,
                  backgroundImage:
                      hasProfileImage ? NetworkImage(profileImageUrl!) : null,
                  child: !hasProfileImage
                      ? const Icon(
                          Icons.person_rounded,
                          color: _secondaryText,
                          size: 27,
                        )
                      : null,
                ),
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
                    Text(
                      email.isNotEmpty ? email : '프로필 보기',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(24),
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
                  color: pointColor.withOpacity(0.13),
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
    );
  }
}