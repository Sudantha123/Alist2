import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/models/file_model.dart';
import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/login/login_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/file_list/file_list_screen.dart';
import '../presentation/screens/video_player/video_player_screen.dart';
import '../presentation/screens/image_viewer/image_viewer_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'files',
            builder: (context, state) {
              final path = state.uri.queryParameters['path'] ?? '/';
              return FileListScreen(path: path);
            },
          ),
          GoRoute(
            path: 'video',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return VideoPlayerScreen(
                url: extra['url'],
                title: extra['title'],
              );
            },
          ),
          GoRoute(
            path: 'image',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>;
              return ImageViewerScreen(
                url: extra['url'],
                title: extra['title'],
              );
            },
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
