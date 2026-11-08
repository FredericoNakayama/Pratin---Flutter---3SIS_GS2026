import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/onboarding_service.dart';

/// Mostra a marca e decide entre a introdução e o Início (RF01).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const Duration duracao = Duration(seconds: 2);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final OnboardingService _onboardingService = OnboardingService();

  @override
  void initState() {
    super.initState();
    _iniciar();
  }

  Future<void> _iniciar() async {
    final resultados = await Future.wait([
      _onboardingService.deveMostrar(),
      Future<void>.delayed(SplashScreen.duracao),
    ]);
    if (!mounted) return;

    final mostrarOnboarding = resultados.first as bool;
    await Navigator.of(context).pushReplacementNamed(
      mostrarOnboarding ? AppRoutes.onboarding : AppRoutes.home,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 160,
              semanticLabel: 'Logo do Pratin',
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Pratin',
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Alimento bom não se joga fora',
              style: textTheme.titleMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
