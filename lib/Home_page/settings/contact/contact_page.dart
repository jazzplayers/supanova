import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

  static const String _email = 'woosin3535@gmail.com';

  static bool _isIOS(BuildContext context) {
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  static IconData _backIcon(BuildContext context) {
    return _isIOS(context)
        ? Icons.arrow_back_ios_new_rounded
        : Icons.arrow_back_rounded;
  }

  static double _appBarHeight(BuildContext context) {
    return _isIOS(context) ? 52 : 56;
  }

  static ScrollPhysics _scrollPhysics(BuildContext context) {
    return _isIOS(context)
        ? const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          )
        : const ClampingScrollPhysics();
  }

  Future<void> _sendEmail(BuildContext context) async {
    final uri = Uri(
      scheme: 'mailto',
      path: _email,
      queryParameters: {
        'subject': 'SUPANOVA 문의',
        'body': '''
문의 유형: 버그 신고 / 기능 제안 / 계정 문제 / 기타

문의 내용:


문제가 발생한 화면:
사용 기기:
OS 버전:
앱 버전:
''',
      },
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );

      if (!launched && context.mounted) {
        _showEmailFallback(context);
      }
    } catch (_) {
      if (context.mounted) {
        _showEmailFallback(context);
      }
    }
  }

  Future<void> _copyEmail(BuildContext context) async {
    await Clipboard.setData(
      const ClipboardData(text: _email),
    );

    if (!context.mounted) return;

    _showCopiedSnackBar(context);
  }

  void _showCopiedSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          elevation: 0,
          backgroundColor: Colors.transparent,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 22),
          duration: const Duration(seconds: 2),
          content: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 14,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF12333A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _blue.withValues(alpha: 0.35),
                width: 0.8,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: _blue,
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '이메일 주소가 복사되었습니다.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  void _showEmailFallback(BuildContext context) {
    final isIOS = _isIOS(context);

    showDialog<void>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          backgroundColor: _surface,
          surfaceTintColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: isIOS ? 24 : 28,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isIOS ? 22 : 20),
            side: const BorderSide(
              color: _line,
              width: 0.8,
            ),
          ),
          titlePadding: const EdgeInsets.fromLTRB(22, 22, 22, 0),
          contentPadding: const EdgeInsets.fromLTRB(22, 12, 22, 6),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          title: const Text(
            '메일 앱을 열 수 없습니다',
            style: TextStyle(
              color: _primaryText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '기기에 메일 앱이 설정되어 있지 않거나, 메일 앱을 바로 열 수 없는 상태입니다.\n\n아래 이메일 주소로 문의해주세요.',
                style: TextStyle(
                  color: _secondaryText,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _surfaceSoft,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: _line,
                    width: 0.8,
                  ),
                ),
                child: const SelectableText(
                  _email,
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                '확인',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: _email),
                );

                if (!dialogContext.mounted) return;

                Navigator.of(dialogContext).pop();

                if (context.mounted) {
                  _showCopiedSnackBar(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: const Size(96, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '이메일 복사',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isIOS = _isIOS(context);
    final maxWidth = math.min(media.size.width, 720.0);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: _appBarHeight(context),
        leadingWidth: isIOS ? 52 : 56,
        title: const Text(
          '문의하기',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.35,
          ),
        ),
        leading: IconButton(
          tooltip: '뒤로가기',
          visualDensity: VisualDensity.compact,
          onPressed: () => context.pop(),
          icon: Icon(
            _backIcon(context),
            color: _primaryText,
            size: isIOS ? 20 : 23,
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
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
            ),
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: _scrollPhysics(context),
              padding: EdgeInsets.fromLTRB(
                16,
                16,
                16,
                28 + media.padding.bottom,
              ),
              children: [
                _ContactMainCard(
                  onSendEmail: () => _sendEmail(context),
                  onCopyEmail: () => _copyEmail(context),
                ),
                const SizedBox(height: 24),
                const _SectionTitle(title: '문의 전 확인해주세요'),
                const SizedBox(height: 10),
                const _InfoCard(
                  icon: Icons.bug_report_outlined,
                  title: '버그 신고',
                  body: '문제가 발생한 화면, 사용 기기, 앱 버전을 함께 적어주시면 확인이 빨라집니다.',
                ),
                const SizedBox(height: 10),
                const _InfoCard(
                  icon: Icons.lightbulb_outline_rounded,
                  title: '기능 제안',
                  body: '추가되었으면 하는 기능이나 불편했던 부분을 자유롭게 보내주세요.',
                ),
                const SizedBox(height: 10),
                const _InfoCard(
                  icon: Icons.person_outline_rounded,
                  title: '계정 문제',
                  body: '로그인, 프로필, 회원탈퇴, 데이터 관련 문제를 문의할 수 있습니다.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactMainCard extends StatelessWidget {
  final VoidCallback onSendEmail;
  final VoidCallback onCopyEmail;

  const _ContactMainCard({
    required this.onSendEmail,
    required this.onCopyEmail,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final compact = width < 360;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        compact ? 18 : 22,
        22,
        compact ? 18 : 22,
        20,
      ),
      decoration: BoxDecoration(
        color: ContactPage._surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: ContactPage._line,
          width: 0.8,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: ContactPage._blue.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mail_outline_rounded,
              color: ContactPage._blue,
              size: 30,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'SUPANOVA 문의',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: ContactPage._primaryText,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '버그 신고, 기능 제안, 계정 문제 등\n도움이 필요한 내용을 보내주세요.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: ContactPage._secondaryText,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.1,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: ContactPage._surfaceSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: ContactPage._line,
                width: 0.8,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.alternate_email_rounded,
                  color: ContactPage._blue,
                  size: 18,
                ),
                SizedBox(width: 9),
                Expanded(
                  child: SelectableText(
                    ContactPage._email,
                    style: TextStyle(
                      color: ContactPage._primaryText,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onSendEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: ContactPage._blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: ContactPage._surfaceSoft,
                disabledForegroundColor: ContactPage._softText,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                '이메일로 문의하기',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onCopyEmail,
            child: const Text(
              '이메일 주소 복사하기',
              style: TextStyle(
                color: ContactPage._secondaryText,
                fontWeight: FontWeight.w800,
                fontSize: 14,
                letterSpacing: -0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(1, 0, 1, 0),
      child: Text(
        '문의 전 확인해주세요',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: ContactPage._secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ContactPage._surface,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: ContactPage._line,
            width: 0.8,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: BoxDecoration(
                color: ContactPage._blue.withValues(alpha: 0.13),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: ContactPage._blue,
                size: 21,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: ContactPage._primaryText,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    body,
                    style: const TextStyle(
                      color: ContactPage._secondaryText,
                      fontSize: 12.8,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.05,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}