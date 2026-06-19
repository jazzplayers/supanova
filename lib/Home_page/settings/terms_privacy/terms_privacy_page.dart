import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TermsPrivacyPage extends StatelessWidget {
  const TermsPrivacyPage({super.key});

  static const Color _bg = Color(0xFF000000);
  static const Color _surface = Color(0xFF0B0B0D);
  static const Color _surfaceSoft = Color(0xFF121216);
  static const Color _line = Color(0xFF242428);
  static const Color _primaryText = Color(0xFFFFFFFF);
  static const Color _secondaryText = Color(0xFF9B9BA1);
  static const Color _softText = Color(0xFF66666D);
  static const Color _blue = Color(0xFF5DADEC);

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

  @override
  Widget build(BuildContext context) {
    final isIOS = _isIOS(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: _bg,
        appBar: AppBar(
          backgroundColor: _bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          toolbarHeight: _appBarHeight(context),
          leadingWidth: isIOS ? 52 : 56,
          title: const Text(
            '약관 및 개인정보',
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
            preferredSize: Size.fromHeight(49),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  color: _line,
                  height: 0.7,
                  thickness: 0.7,
                ),
                TabBar(
                  labelColor: _primaryText,
                  unselectedLabelColor: _secondaryText,
                  indicatorColor: _blue,
                  indicatorWeight: 2.6,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                  tabs: [
                    Tab(text: '이용약관'),
                    Tab(text: '개인정보'),
                    Tab(text: '위치정보'),
                  ],
                ),
              ],
            ),
          ),
        ),
        body: const SafeArea(
          top: false,
          bottom: false,
          child: TabBarView(
            children: [
              _TermsView(),
              _PrivacyView(),
              _LocationView(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsView extends StatelessWidget {
  const _TermsView();

  static const String _termsText = '''
제1조 (목적)

본 약관은 SUPANOVA가 제공하는 운동 기록, 피드, 팔로우, 프로필, 위치 기반 운동 기록 기능 등 서비스 이용과 관련하여 SUPANOVA와 회원 사이의 권리, 의무 및 책임사항을 정하는 것을 목적으로 합니다.

제2조 (회원가입 및 계정)

회원은 SUPANOVA가 정한 절차에 따라 계정을 생성하고 서비스를 이용할 수 있습니다.

회원은 정확한 정보를 입력해야 하며, 타인의 정보를 도용하거나 허위 정보를 사용해서는 안 됩니다.

회원은 본인의 계정을 직접 관리해야 하며, 계정 관리 소홀로 발생한 문제에 대한 책임은 회원 본인에게 있습니다.

제3조 (서비스 내용)

SUPANOVA는 다음 기능을 제공합니다.

• 운동 기록 저장 및 관리
• 운동 경로, 거리, 시간 등 운동 정보 확인
• 프로필 관리
• 운동 피드 작성 및 조회
• 팔로우, 좋아요 등 소셜 기능
• 랭킹 및 통계 기능
• 위치 기반 운동 기록 기능

서비스의 구체적인 기능은 운영 상황에 따라 추가, 변경 또는 중단될 수 있습니다.

제4조 (운동 기록 및 위치 정보의 정확성)

SUPANOVA는 GPS, 네트워크, 기기 센서 등을 이용해 운동 기록을 측정할 수 있습니다.

다만 사용자의 기기 상태, 위치 수신 환경, 네트워크 상태 등에 따라 거리, 속도, 경로, 시간 등의 기록이 실제와 다를 수 있습니다.

SUPANOVA의 운동 기록은 참고용 정보이며, 의료 목적의 진단, 치료, 건강 판단을 위한 정보로 사용될 수 없습니다.

제5조 (회원의 의무)

회원은 서비스를 이용할 때 다음 행위를 해서는 안 됩니다.

• 타인의 계정 또는 개인정보를 도용하는 행위
• 허위 정보 또는 부적절한 콘텐츠를 게시하는 행위
• 타인에게 불쾌감, 피해, 명예훼손을 유발하는 행위
• 서비스 운영을 방해하거나 시스템에 비정상적으로 접근하는 행위
• 법령 또는 공서양속에 반하는 행위
• 서비스의 목적과 무관한 광고, 홍보, 스팸 행위

제6조 (게시물 및 운동 피드)

회원이 작성한 운동 피드, 사진, 프로필 정보 등은 서비스 내에서 다른 회원에게 표시될 수 있습니다.

회원은 본인이 게시한 콘텐츠에 대한 책임을 부담합니다.

SUPANOVA는 부적절하거나 서비스 운영에 지장을 줄 수 있는 콘텐츠에 대해 노출 제한, 삭제, 이용 제한 등의 조치를 할 수 있습니다.

제7조 (서비스 이용 제한)

SUPANOVA는 회원이 본 약관을 위반하거나 서비스 운영을 방해하는 경우 서비스 이용을 제한할 수 있습니다.

이용 제한의 범위와 기간은 위반 내용, 피해 정도, 반복 여부 등을 고려하여 정할 수 있습니다.

제8조 (회원탈퇴)

회원은 언제든지 앱 내 회원탈퇴 기능을 통해 탈퇴를 요청할 수 있습니다.

회원탈퇴가 완료되면 계정 정보, 프로필, 운동 기록, 피드, 팔로우 관계, 좋아요 기록 등 관련 정보가 삭제될 수 있습니다.

단, 관련 법령에 따라 일정 기간 보관이 필요한 정보는 해당 기간 동안 보관될 수 있습니다.

삭제된 정보는 복구할 수 없습니다.

제9조 (서비스 변경 및 중단)

SUPANOVA는 안정적인 서비스 제공을 위해 필요한 경우 서비스의 일부 또는 전부를 변경하거나 일시적으로 중단할 수 있습니다.

시스템 점검, 장애, 통신 문제, 천재지변 등 불가피한 사유가 있는 경우 사전 안내 없이 서비스가 중단될 수 있습니다.

제10조 (면책)

SUPANOVA는 회원의 귀책사유로 발생한 서비스 이용 장애에 대해 책임을 지지 않습니다.

SUPANOVA는 회원이 서비스에 게시한 정보의 정확성, 신뢰성, 적법성을 보장하지 않습니다.

SUPANOVA는 GPS 오차, 네트워크 문제, 기기 오류 등으로 발생한 운동 기록의 차이에 대해 책임을 지지 않습니다.

제11조 (약관 변경)

SUPANOVA는 관련 법령 또는 서비스 운영상 필요한 경우 본 약관을 변경할 수 있습니다.

약관이 변경되는 경우 앱 내 공지 또는 기타 적절한 방법으로 안내합니다.

시행일: 2026년 6월 8일
''';

  @override
  Widget build(BuildContext context) {
    return const _PolicyScrollView(
      icon: Icons.description_outlined,
      title: '서비스 이용약관',
      description: 'SUPANOVA 서비스 이용에 필요한 기본 약관입니다.',
      content: _termsText,
    );
  }
}

class _PrivacyView extends StatelessWidget {
  const _PrivacyView();

  static const String _privacyText = '''
SUPANOVA는 이용자의 개인정보를 중요하게 생각하며, 관련 법령에 따라 개인정보를 안전하게 처리하기 위해 노력합니다.

1. 수집하는 개인정보

SUPANOVA는 서비스 제공을 위해 다음 정보를 수집할 수 있습니다.

필수 정보

• 이메일 주소
• 로그인 계정 정보
• 닉네임
• 서비스 이용 기록

선택 정보

• 프로필 사진
• 자기소개
• 운동 기록
• 운동 피드 사진
• 위치 정보
• 팔로우, 좋아요 등 서비스 활동 정보

위치 정보와 사진은 이용자가 해당 기능을 사용하거나 권한을 허용한 경우에만 수집됩니다.

2. 개인정보 수집 및 이용 목적

수집된 정보는 다음 목적으로 이용됩니다.

• 회원 식별 및 로그인
• 계정 관리
• 프로필 표시 및 관리
• 운동 기록 저장 및 조회
• 운동 피드, 팔로우, 좋아요 등 소셜 기능 제공
• 랭킹 및 통계 기능 제공
• 서비스 안정성 개선 및 오류 확인
• 고객 문의 응대
• 부정 이용 방지 및 서비스 보호

3. 개인정보 보관 기간

회원의 개인정보는 원칙적으로 회원탈퇴 시까지 보관됩니다.

회원탈퇴가 완료되면 계정 정보와 관련 이용 기록은 삭제됩니다.

단, 관련 법령에 따라 보관이 필요한 정보는 법령에서 정한 기간 동안 보관될 수 있습니다.

4. 개인정보 파기 절차 및 방법

회원탈퇴 또는 개인정보 보관 목적이 달성된 경우, 해당 정보는 복구할 수 없도록 안전한 방식으로 삭제됩니다.

전자적 파일 형태의 정보는 복구 및 재생이 어렵도록 삭제합니다.

5. 개인정보 제3자 제공

SUPANOVA는 이용자의 개인정보를 외부에 판매하지 않습니다.

SUPANOVA는 이용자의 동의가 있거나 법령에 따라 필요한 경우를 제외하고 개인정보를 제3자에게 제공하지 않습니다.

6. 서비스 제공을 위해 이용하는 외부 서비스

SUPANOVA는 안정적인 서비스 제공을 위해 다음과 같은 외부 서비스를 이용할 수 있습니다.

• 로그인 및 계정 관리 서비스
• 데이터 저장 서비스
• 이미지 저장 서비스
• 오류 분석 및 서비스 안정화 도구

해당 서비스는 회원가입, 로그인, 운동 기록 저장, 이미지 업로드, 서비스 안정성 개선을 위해 사용됩니다.

7. 위치 정보 처리

SUPANOVA는 운동 기록 기능 제공을 위해 위치 정보를 사용할 수 있습니다.

위치 정보는 이용자가 권한을 허용하고 운동 기록 기능을 사용하는 경우에만 수집됩니다.

자세한 내용은 위치정보 탭에서 확인할 수 있습니다.

8. 이용자의 권리

이용자는 언제든지 다음 권리를 행사할 수 있습니다.

• 개인정보 조회
• 개인정보 수정
• 회원탈퇴
• 개인정보 삭제 요청
• 위치 정보 이용 동의 철회

회원탈퇴는 앱 내 설정 화면에서 진행할 수 있습니다.

9. 개인정보 보호를 위한 조치

SUPANOVA는 개인정보 보호를 위해 필요한 보안 조치를 적용합니다.

서비스 운영에 필요한 범위 내에서 개인정보 접근을 제한하고, 개인정보가 분실, 유출, 변조되지 않도록 관리합니다.

10. 개인정보 관련 문의

개인정보와 관련한 문의는 아래 이메일로 연락할 수 있습니다.

woosin3535@gmail.com

11. 개인정보처리방침 변경

본 개인정보처리방침은 서비스 변경 또는 관련 법령 변경에 따라 수정될 수 있습니다.

내용이 변경되는 경우 앱 내 공지 또는 기타 적절한 방법으로 안내합니다.

시행일: 2026년 6월 8일
''';

  @override
  Widget build(BuildContext context) {
    return const _PolicyScrollView(
      icon: Icons.privacy_tip_outlined,
      title: '개인정보처리방침',
      description: 'SUPANOVA가 수집하고 이용하는 개인정보에 대한 안내입니다.',
      content: _privacyText,
    );
  }
}

class _LocationView extends StatelessWidget {
  const _LocationView();

  static const String _locationText = '''
SUPANOVA는 운동 기록 기능을 제공하기 위해 이용자의 동의를 받은 경우 위치 정보를 사용할 수 있습니다.

1. 위치정보 이용 목적

위치정보는 다음 목적으로 이용됩니다.

• 운동 경로 기록
• 이동 거리 측정
• 운동 시간 및 속도 계산
• 운동 기록 저장 및 조회
• 운동 피드에 운동 경로 표시
• 랭킹 및 통계 기능 제공

2. 수집하는 위치정보

SUPANOVA는 운동 기록 기능 사용 중 다음 정보를 수집할 수 있습니다.

• 현재 위치 좌표
• 이동 경로
• 운동 시작 및 종료 위치
• 이동 거리
• 운동 시간
• 속도 및 페이스 계산 정보

3. 위치정보 수집 시점

위치정보는 이용자가 위치 권한을 허용하고 운동 기록 기능을 실행한 경우에만 수집됩니다.

운동 기록을 시작하지 않은 상태에서는 위치정보가 운동 기록으로 저장되지 않습니다.

4. 위치정보 보관 및 삭제

운동 기록에 포함된 위치정보는 회원의 운동 기록으로 저장됩니다.

이용자가 운동 기록을 삭제하거나 회원탈퇴를 하는 경우 관련 위치정보도 함께 삭제될 수 있습니다.

단, 관련 법령에 따라 보관이 필요한 경우 해당 기간 동안 보관될 수 있습니다.

5. 위치정보 제공 여부

SUPANOVA는 이용자의 동의 없이 개인 위치정보를 외부에 판매하거나 제공하지 않습니다.

다만 법령에 따라 요청이 있는 경우 관련 법령이 정한 범위 내에서 제공될 수 있습니다.

6. 이용자의 권리

이용자는 언제든지 위치정보 이용에 대한 동의를 철회할 수 있습니다.

이용자는 기기의 설정에서 위치 권한을 끄거나, 앱 내 기능 사용을 중단할 수 있습니다.

위치 권한을 끄는 경우 운동 기록, 경로 표시, 거리 측정 등 일부 기능이 제한될 수 있습니다.

7. 위치정보 정확성

위치정보는 GPS, 네트워크, 기기 센서 상태에 따라 오차가 발생할 수 있습니다.

건물 내부, 지하, 터널, 고층 건물 주변, 네트워크 상태가 좋지 않은 환경에서는 위치 기록이 실제와 다르게 표시될 수 있습니다.

8. 문의

위치정보 이용과 관련한 문의는 아래 이메일로 연락할 수 있습니다.

woosin3535@gmail.com

시행일: 2026년 6월 8일
''';

  @override
  Widget build(BuildContext context) {
    return const _PolicyScrollView(
      icon: Icons.location_on_outlined,
      title: '위치정보 이용 안내',
      description: '운동 기록 기능에서 위치정보가 어떻게 사용되는지 안내합니다.',
      content: _locationText,
    );
  }
}

class _PolicyScrollView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String content;

  const _PolicyScrollView({
    required this.icon,
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final width = media.size.width;
    final horizontalPadding = width >= 600 ? 24.0 : 16.0;

    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      physics: TermsPrivacyPage._scrollPhysics(context),
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        16,
        horizontalPadding,
        28 + media.padding.bottom,
      ),
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 720,
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                width < 360 ? 17 : 20,
                20,
                width < 360 ? 17 : 20,
                22,
              ),
              decoration: BoxDecoration(
                color: TermsPrivacyPage._surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: TermsPrivacyPage._line,
                  width: 0.8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PolicyHeader(
                    icon: icon,
                    title: title,
                    description: description,
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 0.7,
                    color: TermsPrivacyPage._line,
                  ),
                  const SizedBox(height: 20),
                  SelectableText(
                    content.trim(),
                    style: const TextStyle(
                      color: TermsPrivacyPage._secondaryText,
                      fontSize: 14,
                      height: 1.72,
                      fontWeight: FontWeight.w500,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PolicyHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: TermsPrivacyPage._blue.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: TermsPrivacyPage._blue,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 1),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: TermsPrivacyPage._primaryText,
                  fontSize: 19,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                description,
                style: const TextStyle(
                  color: TermsPrivacyPage._secondaryText,
                  fontSize: 13.3,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}