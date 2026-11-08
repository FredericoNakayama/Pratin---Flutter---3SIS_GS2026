import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/constants/app_messages.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';

/// Código de retirada em destaque, com botão para copiar.
class CodigoRetiradaBox extends StatelessWidget {
  const CodigoRetiradaBox({
    super.key,
    required this.codigo,
    this.compacto = false,
  });

  final String codigo;

  /// Versão menor, usada nos cards da lista de atividades.
  final bool compacto;

  Future<void> _copiar(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: codigo));
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text(AppMessages.codigoCopiado)));
  }

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).textTheme.headlineMedium?.copyWith(
      fontWeight: FontWeight.bold,
      letterSpacing: compacto ? 4 : 8,
      color: AppColors.primary,
      fontSize: compacto ? 20 : null,
    );

    return Semantics(
      label: 'Código de retirada ${codigo.split('').join(' ')}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compacto ? AppSpacing.md : AppSpacing.xl,
          vertical: compacto ? AppSpacing.xs : AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
          border: Border.all(color: AppColors.primary, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(codigo, style: estilo),
            IconButton(
              tooltip: 'Copiar código',
              onPressed: () => _copiar(context),
              icon: const Icon(Icons.copy, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
