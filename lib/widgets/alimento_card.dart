import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/utils/formatters.dart';
import '../models/alimento.dart';
import 'alimento_imagem.dart';
import 'favorito_button.dart';

/// Card de um alimento disponível na lista do Início.
class AlimentoCard extends StatelessWidget {
  const AlimentoCard({
    super.key,
    required this.alimento,
    required this.favorito,
    required this.agora,
    required this.onTap,
    required this.onFavoritar,
  });

  final Alimento alimento;
  final bool favorito;
  final DateTime agora;
  final VoidCallback onTap;
  final VoidCallback onFavoritar;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final cinza = textTheme.bodySmall?.copyWith(color: AppColors.textSecondary);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AlimentoImagem(
                alimento: alimento,
                width: 88,
                height: 88,
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alimento.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${Formatters.numero(alimento.quantidade)} '
                      '${alimento.unidade.rotulo(alimento.quantidade)} · '
                      '${alimento.categoria.label}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: cinza,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          Formatters.venceEm(alimento.dataValidade, agora),
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Retirada ${Formatters.janela(alimento.retiradaInicio, alimento.retiradaFim)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: cinza,
                    ),
                    Text(
                      alimento.estabelecimentoNome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: cinza,
                    ),
                  ],
                ),
              ),
              FavoritoButton(favorito: favorito, onPressed: onFavoritar),
            ],
          ),
        ),
      ),
    );
  }
}
