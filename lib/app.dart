import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'models/alimento.dart';
import 'models/perfil.dart';
import 'models/reserva.dart';
import 'screens/confirmacao_reserva/confirmacao_reserva_screen.dart';
import 'screens/detalhes/detalhes_alimento_screen.dart';
import 'screens/novo_anuncio/novo_anuncio_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/perfil/perfil_screen.dart';
import 'screens/shell/main_shell.dart';
import 'screens/splash/splash_screen.dart';

/// Raiz do app: tema, idioma e rotas.
class PratinApp extends StatelessWidget {
  const PratinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pratin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      // Sempre começa pela Splash, que decide a próxima tela. No web, isso
      // evita empilhar telas a partir da URL (ex.: /#/home).
      onGenerateInitialRoutes: (_) => [
        _onGenerateRoute(const RouteSettings(name: AppRoutes.splash)),
      ],
      onGenerateRoute: _onGenerateRoute,
    );
  }

  static Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final argumentos = settings.arguments;
    final Widget tela = switch (settings.name) {
      AppRoutes.splash => const SplashScreen(),
      AppRoutes.onboarding => const OnboardingScreen(),
      AppRoutes.home => MainShell(
        abaInicial: argumentos is int ? argumentos : MainShell.abaInicio,
      ),
      AppRoutes.perfil => const PerfilScreen(empilhada: true),
      AppRoutes.detalhes => DetalhesAlimentoScreen(
        alimento: argumentos! as Alimento,
      ),
      AppRoutes.novoAnuncio => NovoAnuncioScreen(perfil: argumentos! as Perfil),
      AppRoutes.confirmacaoReserva => ConfirmacaoReservaScreen(
        reserva: argumentos! as Reserva,
      ),
      // Rota desconhecida: volta ao início do app.
      _ => const SplashScreen(),
    };
    return MaterialPageRoute<dynamic>(settings: settings, builder: (_) => tela);
  }
}
