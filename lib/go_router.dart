import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_function/Home_page/page/home_page.dart';
import 'package:home_function/Home_page/settings/app_setting/notification/notification_settings_page.dart';
import 'package:home_function/Home_page/settings/contact/contact_page.dart';
import 'package:home_function/Home_page/settings/delete_account/delete_account_page.dart';
import 'package:home_function/Home_page/settings/page/settings_page.dart';
import 'package:home_function/Home_page/settings/privacy_settings/privacy_settings_page.dart';
import 'package:home_function/Home_page/settings/profile_edit/profile_edit_page.dart';
import 'package:home_function/Home_page/settings/terms_privacy/terms_privacy_page.dart';
import 'package:home_function/Home_page/user_search/user_serach.dart';
import 'package:home_function/auth/model/auth/auth_provider.dart';
import 'package:home_function/auth/presentation/user_login_page.dart';
import 'package:home_function/auth/presentation/user_register_page.dart';
import 'package:home_function/follow/follow_following_list/FollowUserListPage.dart';
import 'package:home_function/map/map_page.dart';
import 'package:home_function/ranking/run_ranking_page.dart';
import 'package:home_function/workout/workout_UI/workout_page.dart';
import 'package:home_function/workout_finish/feed/feed_page.dart';
import 'package:home_function/workout_finish/workout_finish.dart';
import 'package:home_function/workout_finish/workout_finish_page.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'go_router.g.dart';

@riverpod
GoRouter goRouter(Ref ref) {
  final authRepo = ref.watch(userAuthRepositoryProvider);
  final authChanged = authRepo.userAuthStateChanges();

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: GoRouterRefreshStream(authChanged),
    redirect: (context, state) {
      final user = authRepo.currentUser;
      final path = state.uri.path;

      final isLogin = path == '/login';
      final isRegister = path == '/register';
      final isAuthPage = isLogin || isRegister;

      if (user == null) {
        if (isAuthPage) {
          return null;
        }

        return '/login';
      }

      if (isAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const UserLoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const UserRegisterPage(),
      ),
      GoRoute(
        path: '/settings-privacy',
        builder: (context, state) => const PrivacySettingsPage(),
      ),
      GoRoute(
        path: '/terms-privacy',
        builder: (context, state) => const TermsPrivacyPage(),
      ),
      GoRoute(
        path: '/settings-edit-profile',
        builder: (context, state) => const ProfileEditPage(),
      ),
      GoRoute(
        path: '/settings-contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: '/settings-notification',
        builder: (context, state) => const NotificationSettingsPage(),
      ),
      GoRoute(
        path: '/settings-delete-account',
        builder: (context, state) => const DeleteAccountPage(),
      ),
      GoRoute(
        path: '/workfinish',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is! WorkoutFinish) {
            return const Scaffold(
              body: Center(
                child: Text('운동 완료 정보가 없습니다.'),
              ),
            );
          }

          return WorkoutFinishPage(finish: extra);
        },
      ),
      GoRoute(
        path: '/user/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'];

          if (userId == null || userId.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('사용자 정보가 없습니다.'),
              ),
            );
          }

          return HomePage(userId: userId);
        },
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId'];

          if (userId == null || userId.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('사용자 정보가 없습니다.'),
              ),
            );
          }

          return HomePage(userId: userId);
        },
      ),
      GoRoute(
        path: '/workoutFeed',
        builder: (context, state) {
          final extra = state.extra;

          if (extra is! WorkoutFinish) {
            return const Scaffold(
              body: Center(
                child: Text('운동 기록 정보가 없습니다.'),
              ),
            );
          }

          if (extra.workoutId == null || extra.workoutId!.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('운동 기록 ID가 없습니다.'),
              ),
            );
          }

          return FeedPage(
            workoutFinish: extra,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) {
          return const SettingsPage();
        },
      ),
      GoRoute(
        path: '/followersList',
        builder: (context, state) {
          final extra = state.extra;
          final userId = extra is String ? extra : null;

          if (userId == null || userId.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('사용자 정보가 없습니다.'),
              ),
            );
          }

          return FollowUserListPage(
            title: '팔로워',
            userId: userId,
            type: FollowListType.followers,
          );
        },
      ),
      GoRoute(
        path: '/followingsList',
        builder: (context, state) {
          final extra = state.extra;
          final userId = extra is String ? extra : null;

          if (userId == null || userId.isEmpty) {
            return const Scaffold(
              body: Center(
                child: Text('사용자 정보가 없습니다.'),
              ),
            );
          }

          return FollowUserListPage(
            title: '팔로잉',
            userId: userId,
            type: FollowListType.followings,
          );
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _HomeShell(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) {
              final user = authRepo.currentUser;

              if (user == null) {
                return const NoTransitionPage(
                  child: UserLoginPage(),
                );
              }

              return NoTransitionPage(
                child: HomePage(userId: user.uid),
              );
            },
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) {
              final user = authRepo.currentUser;

              if (user == null) {
                return const NoTransitionPage(
                  child: UserLoginPage(),
                );
              }

              return NoTransitionPage(
                child: UserSearchPage(
                  currentUserId: user.uid,
                ),
              );
            },
          ),
          GoRoute(
            path: '/workout',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: WorkoutPage(),
              );
            },
          ),
          GoRoute(
            path: '/ranking',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: RunRankingScreen(),
              );
            },
          ),
          GoRoute(
            path: '/map',
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: MapPage(),
              );
            },
          ),
        ],
      ),
    ],
  );
}

class _HomeShell extends ConsumerWidget {
  const _HomeShell({
    required this.child,
    required this.location,
  });

  final Widget child;
  final String location;

  static const Color _background = Color(0xFF000000);

  int _indexFromLocation() {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/search')) return 1;
    if (location.startsWith('/workout')) return 2;
    if (location.startsWith('/ranking')) return 3;
    if (location.startsWith('/map')) return 4;

    return 0;
  }

  String _locationFromIndex(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/search';
      case 2:
        return '/workout';
      case 3:
        return '/ranking';
      case 4:
        return '/map';
      default:
        return '/home';
    }
  }

  void _goToIndex(BuildContext context, int index) {
    final nextLocation = _locationFromIndex(index);

    if (nextLocation == location) return;

    FocusManager.instance.primaryFocus?.unfocus();
    context.go(nextLocation);
  }

  bool get _canSwipePage {
    if (location.startsWith('/map')) return false;
    if (location.startsWith('/workout')) return false;

    return true;
  }

  void _onHorizontalSwipe(BuildContext context, DragEndDetails details) {
    if (!_canSwipePage) return;

    final velocity = details.primaryVelocity ?? 0;
    final currentIndex = _indexFromLocation();

    if (velocity.abs() < 450) return;

    if (velocity > 0) {
      final previousIndex = currentIndex - 1;

      if (previousIndex >= 0) {
        _goToIndex(context, previousIndex);
      }

      return;
    }

    if (velocity < 0) {
      final nextIndex = currentIndex + 1;

      if (nextIndex <= 4) {
        _goToIndex(context, nextIndex);
      }

      return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = _indexFromLocation();

    return Scaffold(
      backgroundColor: _background,
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: _canSwipePage
            ? (details) {
                _onHorizontalSwipe(context, details);
              }
            : null,
        child: child,
      ),
      bottomNavigationBar: _InstagramBottomNavBar(
        selectedIndex: selectedIndex,
        onSelected: (index) {
          _goToIndex(context, index);
        },
      ),
    );
  }
}

class _InstagramBottomNavBar extends StatelessWidget {
  const _InstagramBottomNavBar({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const Color _background = Color(0xFF000000);
  static const Color _border = Color(0xFF1C1C1E);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _background,
        border: Border(
          top: BorderSide(
            color: _border,
            width: 0.6,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              _InstagramNavItem(
                index: 0,
                selectedIndex: selectedIndex,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                onTap: onSelected,
              ),
              _InstagramNavItem(
                index: 1,
                selectedIndex: selectedIndex,
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                onTap: onSelected,
              ),
              _InstagramNavItem(
                index: 2,
                selectedIndex: selectedIndex,
                icon: Icons.add_box_outlined,
                selectedIcon: Icons.add_box,
                onTap: onSelected,
              ),
              _InstagramNavItem(
                index: 3,
                selectedIndex: selectedIndex,
                icon: Icons.emoji_events_outlined,
                selectedIcon: Icons.emoji_events,
                onTap: onSelected,
              ),
              _InstagramNavItem(
                index: 4,
                selectedIndex: selectedIndex,
                icon: Icons.map_outlined,
                selectedIcon: Icons.map,
                onTap: onSelected,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InstagramNavItem extends StatelessWidget {
  const _InstagramNavItem({
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.selectedIcon,
    required this.onTap,
  });

  final int index;
  final int selectedIndex;
  final IconData icon;
  final IconData selectedIcon;
  final ValueChanged<int> onTap;

  static const Color _selected = Color(0xFFFFFFFF);
  static const Color _unselected = Color(0xFF8E8E93);

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;

    return Expanded(
      child: InkResponse(
        onTap: () {
          onTap(index);
        },
        radius: 32,
        containedInkWell: false,
        highlightShape: BoxShape.circle,
        child: Center(
          child: AnimatedScale(
            scale: isSelected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Icon(
              isSelected ? selectedIcon : icon,
              size: 28,
              color: isSelected ? _selected : _unselected,
            ),
          ),
        ),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}