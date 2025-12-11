import 'package:go_router/go_router.dart';
import '../../presentation/screens/chat_room_screen.dart';
import '../../presentation/screens/home_screen.dart';
import '../../presentation/screens/login_screen.dart';
import '../../presentation/screens/signup_screen.dart';
import '../../presentation/screens/splash_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/chat/:roomId',
      builder: (context, state) {
        final roomId = int.parse(state.pathParameters['roomId']!);
        return ChatRoomScreen(roomId: roomId);
      },
    ),
  ],
);
