import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/alimento.dart';
import '../../services/favoritos_service.dart';
import '../../widgets/alimento_imagem.dart';
import '../../widgets/favorito_button.dart';
import '../../widgets/info_row.dart';
import '../../widgets/status_chip.dart';

/// Anúncio completo de um alimento (RF11).
class DetalhesAlimentoScreen extends StatefulWidget {
  const DetalhesAlimentoScreen({super.key, required this.alimento});

  final Alimento alimento;

  @override
  State<DetalhesAlimentoScreen> createState() => _DetalhesAlimentoScreenState();
}

class _DetalhesAlimentoScreenState extends State<DetalhesAlimentoScreen> {
  final FavoritosService _favoritosService = FavoritosService();

  bool _favorito = false;

  Alimento get _alimento => widget.alimento;

  @override
  void initState() {
    super.initState();
    _carregarDadosLocais();
  }

  Future<void> _carregarDadosLocais() async {
    final favoritos = await _favoritosService.carregar();
    if (!mounted) return;
    setState(() => _favorito = favoritos.contains(_alimento.id));
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
}
