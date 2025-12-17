import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
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
    final colorScheme = context.colorScheme;

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
        loading: () {},
        error: (_, __) {
          _navigate('/login');
        },
      );
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite,
              size: 80,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Dating App',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
