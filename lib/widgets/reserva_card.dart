import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../core/utils/formatters.dart';
import '../models/enums.dart';
import '../models/reserva.dart';
import 'codigo_retirada_box.dart';
import 'info_row.dart';
import 'status_chip.dart';

/// Reserva da ONG na tela Minhas atividades (RF15, RF16).
class ReservaCard extends StatelessWidget {
  const ReservaCard({
    super.key,
    required this.reserva,
    required this.podeCancelar,
    required this.onCancelar,
  });

  final Reserva reserva;
  final bool podeCancelar;
  final VoidCallback onCancelar;

  @override
  Widget build(BuildContext context) {
    final ativa = reserva.status == StatusReserva.ativa;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    reserva.alimentoNome,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusChip.reserva(reserva.status),
              ],
            ),
            if (ativa) ...[
              const SizedBox(height: AppSpacing.md),
              CodigoRetiradaBox(codigo: reserva.codigoRetirada, compacto: true),
            ],
            const SizedBox(height: AppSpacing.sm),
            InfoRow(
              icon: Icons.storefront,
              label: 'Estabelecimento',
              value: reserva.estabelecimentoNome,
            ),
            InfoRow(
              icon: Icons.schedule,
              label: 'Janela de retirada',
              value: Formatters.janela(
                reserva.retiradaInicio,
                reserva.retiradaFim,
              ),
            ),
            InfoRow(
              icon: Icons.place_outlined,
              label: 'Endereço',
              value: reserva.endereco,
            ),
            if (podeCancelar) ...[
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: onCancelar,
                  icon: const Icon(Icons.close),
                  label: const Text('Cancelar reserva'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
