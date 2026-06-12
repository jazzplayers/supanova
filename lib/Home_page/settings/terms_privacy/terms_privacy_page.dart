import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  static const Color _bg = Color(0xFF0B0F14);
  static const Color _card = Color(0xFF151B22);
  static const Color _primaryText = Color(0xFFF5F7FA);
  static const Color _secondaryText = Color(0xFF9CA3AF);
  static const Color _blue = Color(0xFF5DADEC);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            '약관 및 개인정보',
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
          bottom: const TabBar(
            labelColor: _primaryText,
            unselectedLabelColor: _secondaryText,
            indicatorColor: _blue,
            indicatorWeight: 3,
            tabs: [
              Tab(text: '이용약관'),
              Tab(text: '개인정보'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _TermsView(),
            _PrivacyView(),
          ],
        ),
      ),
    );
  }
}

class _TermsView extends StatelessWidget {
  const _TermsView();

  static const String _termsText = '''
제1조 (목적)

본 약관은 SUPANOVA(이하 "서비스")가 제공하는 운동 기록 및 소셜 기능의 이용과 관련하여 서비스와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (회원가입)

회원은 서비스가 정한 절차에 따라 가입할 수 있습니다.

회원은 정확한 정보를 제공해야 하며 타인의 정보를 도용하여 가입할 수 없습니다.

제3조 (서비스 이용)

회원은 운동 기록 저장, 프로필 관리, 팔로우 기능 등 서비스가 제공하는 기능을 이용할 수 있습니다.

서비스는 운영상 필요에 따라 기능을 변경하거나 중단할 수 있습니다.

제4조 (회원의 의무)

회원은 다음 행위를 해서는 안 됩니다.

• 타인의 개인정보 도용
• 불법적이거나 부적절한 콘텐츠 게시
• 서비스 운영을 방해하는 행위
• 타 회원에 대한 괴롭힘 및 명예훼손

제5조 (계정 관리)

회원은 본인의 계정을 직접 관리해야 하며 계정 보안에 대한 책임은 회원에게 있습니다.

제6조 (회원탈퇴)

회원은 언제든지 앱 내 기능을 통해 회원탈퇴를 요청할 수 있습니다.

회원탈퇴 시 관련 데이터는 개인정보처리방침에 따라 삭제됩니다.

제7조 (면책)

서비스는 천재지변, 시스템 장애, 통신 장애 등 불가항력적인 사유로 발생한 손해에 대해 책임을 지지 않습니다.

서비스는 회원이 게시한 정보의 정확성을 보장하지 않습니다.

제8조 (약관 변경)

서비스는 관련 법령에 따라 본 약관을 변경할 수 있으며, 변경 시 앱 내 공지 또는 기타 적절한 방법으로 안내합니다.

시행일: 2026년 6월 8일
''';

  @override
  Widget build(BuildContext context) {
    return const _PolicyScrollView(
      title: '서비스 이용약관',
      description: 'SUPANOVA 서비스 이용에 필요한 기본 약관입니다.',
      content: _termsText,
    );
  }
}

class _PrivacyView extends StatelessWidget {
  const _PrivacyView();

  static const String _privacyText = '''
SUPANOVA는 이용자의 개인정보를 중요하게 생각하며 관련 법령을 준수합니다.

1. 수집하는 개인정보

서비스는 다음 정보를 수집할 수 있습니다.

• 이메일 주소
• 닉네임
• 프로필 사진
• 운동 기록
• 위치 정보(사용자가 허용한 경우)
• 서비스 이용 기록

2. 개인정보 수집 목적

수집된 정보는 다음 목적으로 사용됩니다.

• 회원 식별 및 로그인
• 운동 기록 저장 및 관리
• 팔로우 및 소셜 기능 제공
• 서비스 개선 및 오류 분석
• 고객 문의 응대

3. 개인정보 보관 기간

회원의 개인정보는 회원탈퇴 시까지 보관됩니다.

단, 관련 법령에 따라 보관이 필요한 경우 해당 기간 동안 보관될 수 있습니다.

4. 개인정보 제3자 제공

SUPANOVA는 이용자의 개인정보를 외부에 판매하거나 제공하지 않습니다.

다만 서비스 제공을 위해 아래 서비스를 이용할 수 있습니다.

• Firebase Authentication
• Cloud Firestore
• Firebase Storage

5. 위치정보

서비스는 운동 기록 기능 제공을 위해 위치정보를 사용할 수 있습니다.

위치정보 수집은 이용자의 동의 후에만 이루어집니다.

6. 이용자의 권리

이용자는 언제든지 다음 권리를 행사할 수 있습니다.

• 개인정보 수정
• 회원탈퇴
• 개인정보 삭제 요청

7. 개인정보 보호

서비스는 개인정보 보호를 위해 합리적인 보안 조치를 적용합니다.

8. 문의

개인정보 관련 문의는 아래 이메일로 연락할 수 있습니다.

woosin3535@gmail.com

시행일: 2026년 6월 8일
''';

  @override
  Widget build(BuildContext context) {
    return const _PolicyScrollView(
      title: '개인정보처리방침',
      description: 'SUPANOVA가 수집하고 이용하는 개인정보에 대한 안내입니다.',
      content: _privacyText,
    );
  }
}

class _PolicyScrollView extends StatelessWidget {
  final String title;
  final String description;
  final String content;

  const _PolicyScrollView({
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: TermsPrivacyPage._card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.description_outlined,
                color: TermsPrivacyPage._blue,
                size: 30,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(
                  color: TermsPrivacyPage._primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: TermsPrivacyPage._secondaryText,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 22),
              Text(
                content,
                style: const TextStyle(
                  color: TermsPrivacyPage._secondaryText,
                  fontSize: 14,
                  height: 1.75,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}