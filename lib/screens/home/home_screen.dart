import 'package:flutter/material.dart';

import '../../core/constants/app_messages.dart';
import '../../core/constants/app_routes.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/alimento.dart';
import '../../models/enums.dart';
import '../../models/perfil.dart';
import '../../models/view_state.dart';
import '../../services/alimento_service.dart';
import '../../services/favoritos_service.dart';
import '../../widgets/alimento_card.dart';
import '../../widgets/categoria_filtro_bar.dart';
import '../../widgets/dialogs/perfil_necessario_dialog.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';

/// Lista de alimentos disponíveis com busca, filtros e favoritos (RF06–RF10).
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.perfil,
    required this.onPerfilAlterado,
  });

  final Perfil? perfil;
  final Future<void> Function() onPerfilAlterado;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const double _alturaCardGrade = 132;

  final AlimentoService _alimentoService = AlimentoService();
  final FavoritosService _favoritosService = FavoritosService();
  final TextEditingController _buscaController = TextEditingController();

  ViewState _estado = ViewState.inicial;
  List<Alimento> _alimentos = [];
  Set<String> _favoritos = {};
  String? _erro;
  String _busca = '';
  Categoria? _categoria;
  bool _somenteFavoritos = false;

  bool get _podeAnunciar =>
      widget.perfil == null || widget.perfil!.isEstabelecimento;

  @override
  void initState() {
    super.initState();
    _carregarFavoritos();
    _carregar();
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregar() async {
    setState(() {
      _estado = ViewState.carregando;
      _erro = null;
    });
    try {
      final alimentos = await _alimentoService.listarDisponiveis();
      if (!mounted) return;
      setState(() {
        _alimentos = alimentos;
        _estado = ViewState.sucesso;
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _estado = ViewState.erro;
      });
    }
  }

  Future<void> _carregarFavoritos() async {
    final favoritos = await _favoritosService.carregar();
    if (!mounted) return;
    setState(() => _favoritos = favoritos);
  }

  Future<void> _alternarFavorito(Alimento alimento) async {
    final favoritos = await _favoritosService.alternar(alimento.id);
    if (!mounted) return;
    setState(() => _favoritos = favoritos);
  }

  Future<void> _abrirDetalhes(Alimento alimento) async {
    final precisaRecarregar = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.detalhes, arguments: alimento);
    if (!mounted) return;
    await _carregarFavoritos();
    if (precisaRecarregar == true) await _carregar();
  }

  Future<void> _anunciar() async {
    final perfil = widget.perfil;
    if (perfil == null) {
      final salvou = await PerfilNecessarioDialog.abrir(context);
      if (salvou) await widget.onPerfilAlterado();
      return;
    }
    final publicou = await Navigator.of(
      context,
    ).pushNamed(AppRoutes.novoAnuncio, arguments: perfil);
    if (publicou == true && mounted) await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 32),
            const SizedBox(width: AppSpacing.sm),
            const Text('Pratin'),
          ],
        ),
      ),
      floatingActionButton: _podeAnunciar
          ? FloatingActionButton.extended(
              onPressed: _anunciar,
              icon: const Icon(Icons.add),
              label: const Text('Anunciar'),
            )
          : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSaudacao(),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.page),
              child: TextField(
                controller: _buscaController,
                onChanged: (valor) => setState(() => _busca = valor),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Buscar alimento',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _busca.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Limpar busca',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _buscaController.clear();
                            setState(() => _busca = '');
                          },
                        ),
                ),
              ),
            ),
            CategoriaFiltroBar(
              categoria: _categoria,
              somenteFavoritos: _somenteFavoritos,
              onCategoria: (categoria) =>
                  setState(() => _categoria = categoria),
              onSomenteFavoritos: (valor) =>
                  setState(() => _somenteFavoritos = valor),
            ),
            const SizedBox(height: AppSpacing.sm),
            Expanded(child: _buildConteudo()),
          ],
        ),
      ),
    );
  }

  Widget _buildSaudacao() {
    final textTheme = Theme.of(context).textTheme;
    final nome = widget.perfil?.nome;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nome == null ? 'Olá!' : 'Olá, $nome',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(
            'Alimentos disponíveis para doação',
            style: textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    switch (_estado) {
      case ViewState.inicial:
        return const SizedBox.shrink();
      case ViewState.carregando:
        return const LoadingView(mensagem: 'Buscando alimentos...');
      case ViewState.erro:
        return ErrorView(mensagem: _erro!, onTentarNovamente: _carregar);
      case ViewState.sucesso:
        return RefreshIndicator(onRefresh: _carregar, child: _buildLista());
    }
  }

  Widget _buildLista() {
    final visiveis = AlimentoService.filtrar(
      _alimentos,
      busca: _busca,
      categoria: _categoria,
      somenteFavoritos: _somenteFavoritos,
      favoritos: _favoritos,
    );

    if (visiveis.isEmpty) {
      final mensagem = _alimentos.isEmpty
          ? AppMessages.listaVazia
          : _somenteFavoritos
          ? AppMessages.favoritosVazio
          : AppMessages.buscaVazia;
      // ListView para o "puxar para atualizar" funcionar também aqui.
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: AppSpacing.xxl),
          EmptyView(icone: Icons.no_food_outlined, mensagem: mensagem),
        ],
      );
    }

    final agora = DateTime.now();
    Widget itemBuilder(BuildContext context, int indice) {
      final alimento = visiveis[indice];
      return AlimentoCard(
        alimento: alimento,
        favorito: _favoritos.contains(alimento.id),
        agora: agora,
        onTap: () => _abrirDetalhes(alimento),
        onFavoritar: () => _alternarFavorito(alimento),
      );
    }

    const padding = EdgeInsets.fromLTRB(
      AppSpacing.page,
      AppSpacing.xs,
      AppSpacing.page,
      96, // espaço para o FAB
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppSpacing.gridBreakpoint) {
          return GridView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: padding,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: _alturaCardGrade,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: visiveis.length,
            itemBuilder: itemBuilder,
          );
        }
        return ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: padding,
          itemCount: visiveis.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
