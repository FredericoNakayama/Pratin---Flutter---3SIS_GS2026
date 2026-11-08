import 'package:flutter/material.dart';

import '../../core/constants/app_messages.dart';
import '../../core/constants/app_routes.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/alimento.dart';
import '../../models/enums.dart';
import '../../models/perfil.dart';
import '../../services/favoritos_service.dart';
import '../../services/perfil_service.dart';
import '../../services/reserva_service.dart';
import '../../widgets/alimento_imagem.dart';
import '../../widgets/dialogs/confirmacao_dialog.dart';
import '../../widgets/dialogs/perfil_necessario_dialog.dart';
import '../../widgets/favorito_button.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/status_chip.dart';

/// Anúncio completo de um alimento e reserva pela ONG (RF11, RF13).
///
/// Devolve `true` quando o Início precisa recarregar a lista.
class DetalhesAlimentoScreen extends StatefulWidget {
  const DetalhesAlimentoScreen({super.key, required this.alimento});

  final Alimento alimento;

  @override
  State<DetalhesAlimentoScreen> createState() => _DetalhesAlimentoScreenState();
}

class _DetalhesAlimentoScreenState extends State<DetalhesAlimentoScreen> {
  final PerfilService _perfilService = PerfilService();
  final FavoritosService _favoritosService = FavoritosService();
  final ReservaService _reservaService = ReservaService();

  Perfil? _perfil;
  bool _favorito = false;
  bool _reservando = false;

  Alimento get _alimento => widget.alimento;

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  Future<void> _carregarDadosLocais() async {
    final perfil = await _perfilService.carregar();
    final favoritos = await _favoritosService.carregar();
    if (!mounted) return;
    setState(() {
      _perfil = perfil;
      _favorito = favoritos.contains(_alimento.id);
    });
  }

  Future<void> _reservar() async {
    var perfil = _perfil;
    if (perfil == null) {
      final salvou = await PerfilNecessarioDialog.abrir(context);
      if (!salvou || !mounted) return;
      await _carregarDadosLocais();
      perfil = _perfil;
      // Quem acabou de virar estabelecimento não pode reservar.
      if (perfil == null || !perfil.isOng || !mounted) return;
    }

    final confirmou = await ConfirmacaoDialog.abrir(
      context,
      titulo: 'Reservar alimento',
      mensagem:
          'Reservar "${_alimento.nome}"? A reserva vale para o lote inteiro.',
      textoConfirmar: 'Reservar',
    );
    if (!confirmou || !mounted) return;

    setState(() => _reservando = true);
    try {
      final reserva = await _reservaService.reservar(_alimento, perfil);
      if (!mounted) return;
      await Navigator.of(
        context,
      ).pushReplacementNamed(AppRoutes.confirmacaoReserva, arguments: reserva);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _reservando = false);
      final messenger = ScaffoldMessenger.of(context);
      messenger.showSnackBar(SnackBar(content: Text(e.mensagem)));
      // Item reservado por outra ONG ou fora do prazo: volta e recarrega.
      if (e.tipo == TipoErro.regraNegocio) Navigator.of(context).pop(true);
    }
  }

  Future<void> _alternarFavorito() async {
    final favoritos = await _favoritosService.alternar(_alimento.id);
    if (!mounted) return;
    setState(() => _favorito = favoritos.contains(_alimento.id));
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final agora = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(_alimento.nome),
        actions: [
          FavoritoButton(favorito: _favorito, onPressed: _alternarFavorito),
        ],
      ),
      bottomNavigationBar: _buildAcao(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AlimentoImagem(alimento: _alimento, height: 220),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _alimento.nome,
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatusChip.alimento(_alimento.status),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        Chip(
                          avatar: Icon(_alimento.categoria.icon, size: 18),
                          label: Text(_alimento.categoria.label),
                        ),
                        const Chip(
                          avatar: Icon(
                            Icons.volunteer_activism,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          label: Text('Doação gratuita'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            InfoRow(
                              icon: Icons.inventory_2_outlined,
                              label: 'Quantidade',
                              value:
                                  '${Formatters.numero(_alimento.quantidade)} '
                                  '${_alimento.unidade.rotulo(_alimento.quantidade)}',
                            ),
                            InfoRow(
                              icon: Icons.event,
                              label: 'Validade',
                              value:
                                  '${Formatters.data(_alimento.dataValidade)} · '
                                  '${Formatters.venceEm(_alimento.dataValidade, agora)}',
                            ),
                            InfoRow(
                              icon: Icons.schedule,
                              label: 'Janela de retirada',
                              value: Formatters.janela(
                                _alimento.retiradaInicio,
                                _alimento.retiradaFim,
                              ),
                            ),
                            InfoRow(
                              icon: Icons.storefront,
                              label: 'Estabelecimento',
                              value: _alimento.estabelecimentoNome,
                            ),
                            InfoRow(
                              icon: Icons.place_outlined,
                              label: 'Endereço',
                              value: _alimento.endereco,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Declarado próprio para consumo pelo estabelecimento.',
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ONG e quem não tem perfil veem "Reservar"; estabelecimento vê um aviso.
  Widget? _buildAcao() {
    if (_alimento.status != StatusAlimento.disponivel) return null;
    final perfil = _perfil;

    final Widget conteudo;
    if (perfil != null && perfil.isEstabelecimento) {
      conteudo = Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppMessages.apenasOngs,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    } else {
      conteudo = PrimaryButton(
        label: 'Reservar',
        icon: Icons.volunteer_activism,
        carregando: _reservando,
        onPressed: _reservar,
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.sm,
          AppSpacing.page,
          AppSpacing.page,
        ),
        child: conteudo,
      ),
    );
  }
}
