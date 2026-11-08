import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/alimento.dart';

/// Foto do alimento (`Image.network`) com o ícone da categoria como reserva.
class AlimentoImagem extends StatelessWidget {
  const AlimentoImagem({
    super.key,
    required this.alimento,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final Alimento alimento;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final url = alimento.fotoUrl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: url == null
            ? _buildIconeCategoria()
            : Image.network(
                url,
                fit: BoxFit.cover,
                semanticLabel: 'Foto de ${alimento.nome}',
                loadingBuilder: (context, child, progresso) =>
                    progresso == null ? child : _buildIconeCategoria(),
                errorBuilder: (context, erro, stack) => _buildIconeCategoria(),
              ),
      ),
    );
  }

  Widget _buildIconeCategoria() {
    return ColoredBox(
      color: AppColors.secondaryLight,
      child: Center(
        child: Icon(
          alimento.categoria.icon,
          color: AppColors.secondary,
          size: 40,
          semanticLabel: alimento.categoria.label,
        ),
      ),
    );
  }
}
