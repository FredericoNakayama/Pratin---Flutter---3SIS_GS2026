import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Estado vazio com ícone, mensagem e uma ação opcional.
class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icone,
    required this.mensagem,
    this.acaoLabel,
    this.onAcao,
  });

  final IconData icone;
  final String mensagem;
  final String? acaoLabel;
  final VoidCallback? onAcao;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 72, color: AppColors.primaryLight),
            const SizedBox(height: AppSpacing.lg),
            Text(
              mensagem,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: AppColors.textSecondary),
            ),
            if (acaoLabel != null && onAcao != null) ...[
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(onPressed: onAcao, child: Text(acaoLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
