import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/app.dart';
import 'package:pratin/core/constants/app_routes.dart';
import 'package:pratin/core/constants/prefs_keys.dart';
import 'package:pratin/screens/onboarding/onboarding_screen.dart';
import 'package:pratin/screens/splash/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('primeiro acesso: Splash leva ao Onboarding', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const PratinApp());

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Pratin'), findsOneWidget);

    await tester.pump(SplashScreen.duracao);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Comida boa no lixo, não!'), findsOneWidget);
  });

  testWidgets('Onboarding navega e salva "Não mostrar novamente"', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: const OnboardingScreen(),
        routes: {AppRoutes.home: (_) => const Scaffold(body: Text('Início'))},
      ),
    );

    expect(find.text('Voltar'), findsOneWidget); // oculto, mas reserva espaço
    await tester.tap(find.text('Avançar'));
    await tester.pumpAndSettle();
    expect(find.text('Anuncie o que sobrou'), findsOneWidget);

    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();
    expect(find.text('Começar'), findsOneWidget);

    await tester.tap(find.text('Não mostrar novamente'));
    await tester.pump();
    await tester.tap(find.text('Começar'));
    await tester.pumpAndSettle();

    expect(find.text('Início'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool(PrefsKeys.onboardingVisualizado), isTrue);
    expect(prefs.getBool(PrefsKeys.onboardingNaoMostrar), isTrue);
  });

  testWidgets('introdução já dispensada: Splash vai direto ao Início', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      PrefsKeys.onboardingVisualizado: true,
      PrefsKeys.onboardingNaoMostrar: true,
    });
    await tester.pumpWidget(const PratinApp());
    await tester.pump(SplashScreen.duracao);
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(SplashScreen), findsNothing);
  });
}
