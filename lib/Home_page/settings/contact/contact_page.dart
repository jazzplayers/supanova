import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  static const String _email = 'woosin3535@gmail.com';

  Future<void> _sendEmail(BuildContext context) async {
    final subject = Uri.encodeComponent('SUPANOVA 문의');
    final body = Uri.encodeComponent('''
문의 유형: 버그 신고 / 기능 제안 / 계정 문제 / 기타

문의 내용:


사용 기기:
앱 버전:
''');

    final uri = Uri.parse('mailto:$_email?subject=$subject&body=$body');

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

  void _showEmailFallback(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            '메일 앱을 열 수 없습니다',
            style: TextStyle(
              color: _primaryText,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            '기기에 메일 앱이 설정되어 있지 않을 수 있습니다.\n아래 이메일 주소로 문의해주세요.\n\n$_email',
            style: TextStyle(
              color: _secondaryText,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: _email),
                );

                if (!dialogContext.mounted) return;

                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('이메일 주소가 복사되었습니다.'),
                  ),
                );
              },
              child: const Text(
                '이메일 복사',
                style: TextStyle(
                  color: _blue,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                '확인',
                style: TextStyle(
                  color: _secondaryText,
                  fontWeight: FontWeight.w700,
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
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '문의하기',
          style: TextStyle(
            color: _primaryText,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: _primaryText,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _blue.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mail_outline_rounded,
                    color: _blue,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'SUPANOVA 문의',
                  style: TextStyle(
                    color: _primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '버그 신고, 기능 제안, 계정 문제 등\n문의 내용을 보내주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondaryText,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => _sendEmail(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _blue,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Text(
                      '이메일로 문의하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () async {
                    await Clipboard.setData(
                      const ClipboardData(text: _email),
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('이메일 주소가 복사되었습니다.'),
                      ),
                    );
                  },
                  child: const Text(
                    '이메일 주소 복사하기',
                    style: TextStyle(
                      color: _secondaryText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '문의 전 확인해주세요',
            style: TextStyle(
              color: _secondaryText,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const _InfoCard(
            icon: Icons.bug_report_outlined,
            title: '버그 신고',
            body: '어떤 화면에서 문제가 발생했는지 함께 적어주시면 좋아요.',
          ),
          const SizedBox(height: 10),
          const _InfoCard(
            icon: Icons.lightbulb_outline_rounded,
            title: '기능 제안',
            body: '추가되었으면 하는 기능이나 개선 의견을 보내주세요.',
          ),
          const SizedBox(height: 10),
          const _InfoCard(
            icon: Icons.person_outline_rounded,
            title: '계정 문제',
            body: '로그인, 프로필, 데이터 관련 문제를 문의할 수 있어요.',
          ),
        ],
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ContactPage._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: ContactPage._blue,
            size: 24,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ContactPage._primaryText,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: ContactPage._secondaryText,
                    fontSize: 12.5,
                    height: 1.4,
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