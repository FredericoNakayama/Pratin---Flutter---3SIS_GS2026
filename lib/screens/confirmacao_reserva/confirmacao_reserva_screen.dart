import 'package:flutter/material.dart';

import '../../core/constants/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../models/reserva.dart';
import '../../widgets/codigo_retirada_box.dart';
import '../../widgets/info_row.dart';
import '../../widgets/primary_button.dart';
import '../shell/main_shell.dart';

/// Entrega à ONG o código de retirada da reserva (RF14).
class ConfirmacaoReservaScreen extends StatelessWidget {
  const ConfirmacaoReservaScreen({super.key, required this.reserva});

  final Reserva reserva;

  void _irPara(BuildContext context, int aba) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false, arguments: aba);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Voltar sempre recarrega o Início, que já não mostra o item reservado.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _irPara(context, MainShell.abaInicio);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Reserva confirmada'),
          leading: IconButton(
            tooltip: 'Fechar',
            icon: const Icon(Icons.close),
            onPressed: () => _irPara(context, MainShell.abaInicio),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.page),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 72,
                  color: AppColors.primary,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Reserva confirmada!',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Apresente este código ao estabelecimento na retirada.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                CodigoRetiradaBox(codigo: reserva.codigoRetirada),
                const SizedBox(height: AppSpacing.xl),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.fastfood_outlined,
                          label: 'Alimento',
                          value: reserva.alimentoNome,
                        ),
                        InfoRow(
                          icon: Icons.storefront,
                          label: 'Estabelecimento',
                          value: reserva.estabelecimentoNome,
                        ),
                        InfoRow(
                          icon: Icons.place_outlined,
                          label: 'Endereço',
                          value: reserva.endereco,
                        ),
                        InfoRow(
                          icon: Icons.schedule,
                          label: 'Janela de retirada',
                          value: Formatters.janela(
                            reserva.retiradaInicio,
                            reserva.retiradaFim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: 'Ver minhas atividades',
                  icon: Icons.receipt_long,
                  onPressed: () => _irPara(context, MainShell.abaAtividades),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => _irPara(context, MainShell.abaInicio),
                  child: const Text('Voltar ao início'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
