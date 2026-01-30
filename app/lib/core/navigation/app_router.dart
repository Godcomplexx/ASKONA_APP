import 'package:go_router/go_router.dart';
import '../../presentation/views/connection_screen.dart';
import '../../presentation/views/recording_screen.dart';
import '../../presentation/views/settings_screen.dart';
import '../../presentation/views/files_screen.dart';

// navigation router 
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'connection',
      builder: (context, state) => const ConnectionScreen(),
    ),
    GoRoute(
      path: '/recording',
      name: 'recording',
      builder: (context, state) => const RecordingScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/files',
      name: 'files',
      builder: (context, state) => const FilesScreen(),
    ),
  ],
);
