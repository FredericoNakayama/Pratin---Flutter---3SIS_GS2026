import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../services/onboarding_service.dart';
import '../../widgets/onboarding_page_content.dart';

/// Introdução em 3 páginas com "Não mostrar novamente" (RF02).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const List<OnboardingPageContent> _paginas = [
    OnboardingPageContent(
      icone: Icons.no_food,
      titulo: 'Comida boa no lixo, não!',
      descricao:
          'Todos os dias, alimentos próprios para consumo são descartados '
          'por estarem perto do vencimento.',
    ),
    OnboardingPageContent(
      icone: Icons.storefront,
      titulo: 'Anuncie o que sobrou',
      descricao:
          'Padarias, mercados e restaurantes publicam em poucos toques os '
          'alimentos que vencem em até 7 dias.',
    ),
    OnboardingPageContent(
      icone: Icons.volunteer_activism,
      titulo: 'Reserve e retire',
      descricao:
          'A ONG reserva o lote, recebe um código e retira no local para '
          'levar a quem precisa.',
    ),
  ];

  final OnboardingService _onboardingService = OnboardingService();
  final PageController _pageController = PageController();
  int _pagina = 0;
  bool _naoMostrarNovamente = false;
  bool _salvando = false;

  bool get _ultimaPagina => _pagina == _paginas.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _irParaPagina(int pagina) => _pageController.animateToPage(
    pagina,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );

  Future<void> _avancar() async {
    if (_ultimaPagina) {
      await _comecar();
    } else {
      await _irParaPagina(_pagina + 1);
    }
  }

  Future<void> _comecar() async {
    setState(() => _salvando = true);
    await _onboardingService.concluir(
      naoMostrarNovamente: _naoMostrarNovamente,
    );
    if (!mounted) return;

    final navigator = Navigator.of(context);
    // Aberta pelo Perfil ("Ver introdução novamente"): só volta.
    if (navigator.canPop()) {
      navigator.pop();
    } else {
      await navigator.pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Visibility(
                visible: !_ultimaPagina,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: TextButton(
                  onPressed: () => _irParaPagina(_paginas.length - 1),
                  child: const Text('Pular'),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (pagina) => setState(() => _pagina = pagina),
                children: _paginas,
              ),
            ),
            _buildIndicadores(),
            const SizedBox(height: AppSpacing.lg),
            if (_ultimaPagina)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                child: CheckboxListTile(
                  value: _naoMostrarNovamente,
                  onChanged: (valor) =>
                      setState(() => _naoMostrarNovamente = valor ?? false),
                  title: const Text('Não mostrar novamente'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  Visibility(
                    visible: _pagina > 0,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: TextButton.icon(
                      onPressed: () => _irParaPagina(_pagina - 1),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Voltar'),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _salvando ? null : _avancar,
                    icon: Icon(
                      _ultimaPagina ? Icons.check : Icons.arrow_forward,
                    ),
                    label: Text(_ultimaPagina ? 'Começar' : 'Avançar'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadores() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_paginas.length, (indice) {
        final ativo = indice == _pagina;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          width: ativo ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: ativo ? AppColors.primary : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSpacing.xs),
          ),
        );
      }),
    );
  }
}
