import 'package:flutter/material.dart';

import '../../core/constants/app_messages.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/alimento.dart';
import '../../models/perfil.dart';
import '../../models/reserva.dart';
import '../../models/view_state.dart';
import '../../services/alimento_service.dart';
import '../../services/reserva_service.dart';
import '../../services/retirada_service.dart';
import '../../widgets/anuncio_card.dart';
import '../../widgets/dialogs/confirmacao_dialog.dart';
import '../../widgets/dialogs/confirmar_retirada_dialog.dart';
import '../../widgets/empty_view.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/reserva_card.dart';

/// Reservas da ONG ou anúncios do estabelecimento (RF15–RF20).
class AtividadesScreen extends StatefulWidget {
  const AtividadesScreen({
    super.key,
    required this.perfil,
    required this.onConfigurarPerfil,
  });

  final Perfil? perfil;
  final VoidCallback onConfigurarPerfil;

  @override
  State<AtividadesScreen> createState() => _AtividadesScreenState();
}

class _AtividadesScreenState extends State<AtividadesScreen> {
  final AlimentoService _alimentoService = AlimentoService();
  final ReservaService _reservaService = ReservaService();
  final RetiradaService _retiradaService = RetiradaService();

  ViewState _estado = ViewState.inicial;
  String? _erro;
  List<Reserva> _reservas = [];
  List<Alimento> _anuncios = [];
  Map<String, Reserva> _reservasAtivas = {};

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  @override
  void didUpdateWidget(covariant AtividadesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.perfil?.cnpj != widget.perfil?.cnpj ||
        oldWidget.perfil?.tipo != widget.perfil?.tipo) {
      _carregar();
    }
  }

  Future<void> _carregar() async {
    final perfil = widget.perfil;
    if (perfil == null) return;

    setState(() {
      _estado = ViewState.carregando;
      _erro = null;
    });
    try {
      if (perfil.isOng) {
        final reservas = await _reservaService.listarDaOng(perfil.cnpj);
        if (!mounted) return;
        setState(() => _reservas = reservas);
      } else {
        final resultados = await Future.wait([
          _alimentoService.listarDoEstabelecimento(perfil.cnpj),
          _reservaService.ativasDoEstabelecimento(perfil.cnpj),
        ]);
        if (!mounted) return;
        setState(() {
          _anuncios = resultados[0] as List<Alimento>;
          _reservasAtivas = resultados[1] as Map<String, Reserva>;
        });
      }
      setState(() => _estado = ViewState.sucesso);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _estado = ViewState.erro;
      });
    }
  }

  /// Executa uma ação, mostra o resultado e recarrega a lista.
  Future<void> _executar(
    Future<void> Function() acao,
    String mensagemSucesso,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await acao();
      messenger.showSnackBar(SnackBar(content: Text(mensagemSucesso)));
    } on AppException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
    if (mounted) await _carregar();
  }

  Future<void> _cancelarReserva(Reserva reserva) async {
    final confirmou = await ConfirmacaoDialog.abrir(
      context,
      titulo: 'Cancelar reserva',
      mensagem:
          'Cancelar a reserva de "${reserva.alimentoNome}"? '
          'O alimento volta a ficar disponível para outras ONGs.',
      textoConfirmar: 'Cancelar reserva',
      destrutivo: true,
    );
    if (!confirmou || !mounted) return;
    await _executar(
      () => _reservaService.cancelar(reserva),
      AppMessages.reservaCancelada,
    );
  }

  Future<void> _cancelarAnuncio(Alimento alimento) async {
    final confirmou = await ConfirmacaoDialog.abrir(
      context,
      titulo: 'Cancelar anúncio',
      mensagem: 'Cancelar o anúncio de "${alimento.nome}"?',
      textoConfirmar: 'Cancelar anúncio',
      destrutivo: true,
    );
    if (!confirmou || !mounted) return;
    await _executar(
      () => _alimentoService.cancelar(alimento),
      AppMessages.anuncioCancelado,
    );
  }

  Future<void> _confirmarRetirada(Alimento alimento) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmarRetiradaDialog(
        alimentoNome: alimento.nome,
        onConfirmar: (codigo) => _retiradaService.confirmar(alimento, codigo),
      ),
    );
    if (confirmou != true || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppMessages.retiradaConfirmada)),
    );
    await _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final perfil = widget.perfil;
    final titulo = perfil == null
        ? 'Minhas atividades'
        : perfil.isOng
        ? 'Minhas reservas'
        : 'Meus anúncios';

    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SafeArea(
        child: perfil == null
            ? EmptyView(
                icone: Icons.badge_outlined,
                mensagem: AppMessages.semPerfilAtividades,
                acaoLabel: 'Configurar perfil',
                onAcao: widget.onConfigurarPerfil,
              )
            : _buildConteudo(perfil),
      ),
    );
  }

  Widget _buildConteudo(Perfil perfil) {
    switch (_estado) {
      case ViewState.inicial:
        return const SizedBox.shrink();
      case ViewState.carregando:
        return const LoadingView();
      case ViewState.erro:
        return ErrorView(mensagem: _erro!, onTentarNovamente: _carregar);
      case ViewState.sucesso:
        return RefreshIndicator(
          onRefresh: _carregar,
          child: perfil.isOng ? _buildReservas() : _buildAnuncios(),
        );
    }
  }

  Widget _buildVazio(IconData icone, String mensagem) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: AppSpacing.xxl),
        EmptyView(icone: icone, mensagem: mensagem),
      ],
    );
  }

  Widget _buildReservas() {
    if (_reservas.isEmpty) {
      return _buildVazio(
        Icons.receipt_long_outlined,
        AppMessages.reservasVazias,
      );
    }
    final agora = DateTime.now();
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: _reservas.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, indice) {
        final reserva = _reservas[indice];
        return ReservaCard(
          reserva: reserva,
          podeCancelar: ReservaService.podeCancelar(reserva, agora),
          onCancelar: () => _cancelarReserva(reserva),
        );
      },
    );
  }

  Widget _buildAnuncios() {
    if (_anuncios.isEmpty) {
      return _buildVazio(Icons.campaign_outlined, AppMessages.anunciosVazios);
    }
    final agora = DateTime.now();
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: _anuncios.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, indice) {
        final alimento = _anuncios[indice];
        return AnuncioCard(
          alimento: alimento,
          ongNome: _reservasAtivas[alimento.id]?.ongNome,
          podeCancelar: AlimentoService.podeCancelar(alimento),
          podeConfirmarRetirada: RetiradaService.podeConfirmar(alimento, agora),
          onCancelar: () => _cancelarAnuncio(alimento),
          onConfirmarRetirada: () => _confirmarRetirada(alimento),
        );
      },
    );
  }
}
