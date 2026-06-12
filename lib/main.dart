import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_app_check/firebase_app_check.dart';

import 'firebase_options.dart';
import 'go_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterForegroundTask.initCommunicationPort();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // await FirebaseAppCheck.instance.activate(
  //   providerAndroid: const AndroidDebugProvider(),
  //   providerApple: const AppleDebugProvider(),
  // );

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Home Function',
      debugShowCheckedModeBanner: false,

      themeMode: ThemeMode.dark,

      darkTheme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0B0F14),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5DADEC),
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF5DADEC),
          surface: const Color(0xFF151B22),
          surfaceContainerHighest: const Color(0xFF1E2630),
          onSurface: const Color(0xFFF5F7FA),
          onSurfaceVariant: const Color(0xFF9CA3AF),
          outlineVariant: const Color(0xFF2A3441),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B0F14),
          foregroundColor: Color(0xFFF5F7FA),
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
      ),

      routeInformationParser: goRouter.routeInformationParser,
      routeInformationProvider: goRouter.routeInformationProvider,
      routerDelegate: goRouter.routerDelegate,
    );
  }
}