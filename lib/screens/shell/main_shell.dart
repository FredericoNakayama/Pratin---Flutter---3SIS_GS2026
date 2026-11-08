import 'package:flutter/material.dart';

import '../../models/perfil.dart';
import '../../services/perfil_service.dart';
import '../../widgets/loading_view.dart';
import '../perfil/perfil_screen.dart';

/// Navegação principal por abas e guarda do perfil atual (RF03).
///
/// As abas são recriadas a cada troca (sem `IndexedStack`) para sempre
/// recarregar os dados.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.abaInicial = abaInicio});

  static const int abaInicio = 0;
  static const int abaAtividades = 1;
  static const int abaPerfil = 2;

  final int abaInicial;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final PerfilService _perfilService = PerfilService();
  late int _aba = widget.abaInicial;
  Perfil? _perfil;
  bool _carregandoPerfil = true;

  @override
  void initState() {
    super.initState();
    _recarregarPerfil();
  }

  Future<void> _recarregarPerfil() async {
    final perfil = await _perfilService.carregar();
    if (!mounted) return;
    setState(() {
      _perfil = perfil;
      _carregandoPerfil = false;
    });
  }

  void _irParaAba(int aba) => setState(() => _aba = aba);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _carregandoPerfil ? const LoadingView() : _buildAba(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _aba,
        onDestinationSelected: _irParaAba,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Início',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Atividades',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  Widget _buildAba() {
    switch (_aba) {
      case MainShell.abaPerfil:
        return PerfilScreen(
          onPerfilSalvo: (perfil) => setState(() => _perfil = perfil),
        );
      default:
        // Início e Atividades chegam nas fases F6 e F9.
        return Center(child: Text(_perfil?.nome ?? 'Em construção'));
    }
  }
}
