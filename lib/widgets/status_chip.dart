import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/enums.dart';

/// Etiqueta colorida com o status de um alimento ou de uma reserva.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  StatusChip.alimento(StatusAlimento status, {Key? key})
    : this(key: key, label: status.label, color: status.color);

  StatusChip.reserva(StatusReserva status, {Key? key})
    : this(key: key, label: status.label, color: status.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSpacing.lg),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
