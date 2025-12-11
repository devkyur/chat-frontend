import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // 최소 1초 대기 (스플래시 화면 표시)
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // authProvider 상태를 watch하여 변경사항 감지
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (!mounted) return;

      next.whenOrNull(
        data: (user) {
          if (user != null) {
            context.go('/home');
          } else {
            context.go('/login');
          }
        },
        error: (_, __) {
          context.go('/login');
        },
      );
    });

    // 최대 3초 타임아웃 후 상태 확인
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final authState = ref.read(authProvider);
    authState.whenOrNull(
      data: (user) {
        if (user != null) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      },
      error: (_, __) {
        context.go('/login');
      },
    );

    // 여전히 loading이면 로그인 화면으로
    if (authState.isLoading) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: Color(0xFFFF4458),
            ),
            SizedBox(height: 16),
            Text(
              'Dating App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
