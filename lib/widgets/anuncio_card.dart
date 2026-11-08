import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/formatters.dart';
import '../models/alimento.dart';
import 'alimento_imagem.dart';
import 'info_row.dart';
import 'status_chip.dart';

/// Anúncio do estabelecimento na tela Minhas atividades (RF17–RF19).
class AnuncioCard extends StatelessWidget {
  const AnuncioCard({
    super.key,
    required this.alimento,
    required this.ongNome,
    required this.podeCancelar,
    required this.podeConfirmarRetirada,
    required this.onCancelar,
    required this.onConfirmarRetirada,
  });

  final Alimento alimento;

  /// ONG da reserva ativa, quando o anúncio está reservado.
  final String? ongNome;
  final bool podeCancelar;
  final bool podeConfirmarRetirada;
  final VoidCallback onCancelar;
  final VoidCallback onConfirmarRetirada;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AlimentoImagem(
                  alimento: alimento,
                  width: 48,
                  height: 48,
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    alimento.nome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusChip.alimento(alimento.status),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            InfoRow(
              icon: Icons.inventory_2_outlined,
              label: 'Quantidade',
              value:
                  '${Formatters.numero(alimento.quantidade)} '
                  '${alimento.unidade.rotulo(alimento.quantidade)}',
            ),
            InfoRow(
              icon: Icons.schedule,
              label: 'Janela de retirada',
              value: Formatters.janela(
                alimento.retiradaInicio,
                alimento.retiradaFim,
              ),
            ),
            if (ongNome != null)
              InfoRow(
                icon: Icons.volunteer_activism,
                label: 'Reservado por',
                value: ongNome!,
              ),
            if (podeCancelar || podeConfirmarRetirada) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: podeConfirmarRetirada
                    ? ElevatedButton.icon(
                        onPressed: onConfirmarRetirada,
                        icon: const Icon(Icons.qr_code_2),
                        label: const Text('Confirmar retirada'),
                      )
                    : OutlinedButton.icon(
                        onPressed: onCancelar,
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar anúncio'),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
