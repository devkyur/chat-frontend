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
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    // 최소 2초 후에 네비게이션 시도
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isNavigated) {
        _navigateBasedOnAuth();
      }
    });
  }

  void _navigateBasedOnAuth() {
    if (_isNavigated) return;

    final authState = ref.read(authProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          _navigate('/home');
        } else {
          _navigate('/login');
        }
      },
      loading: () {
        // 타임아웃 후에도 로딩이면 로그인 화면으로
        _navigate('/login');
      },
      error: (_, __) {
        _navigate('/login');
      },
    );
  }

  void _navigate(String route) {
    if (!mounted || _isNavigated) return;
    _isNavigated = true;
    context.go(route);
  }

  @override
  Widget build(BuildContext context) {
    // authProvider의 상태를 watch하여 변경사항 감지
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      if (_isNavigated || !mounted) return;

      next.when(
        data: (user) {
          if (user != null) {
            _navigate('/home');
          } else {
            _navigate('/login');
          }
        },
        loading: () {
          // 로딩 중에는 아무것도 하지 않음
        },
        error: (_, __) {
          _navigate('/login');
        },
      );
    });

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
