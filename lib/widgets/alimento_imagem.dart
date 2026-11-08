import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/utils/imagem_utils.dart';
import '../models/alimento.dart';
import '../models/enums.dart';

/// Foto do alimento com o ícone da categoria como reserva.
///
/// Aceita endereço da internet (`Image.network`) ou foto do aparelho guardada
/// como data URL (`Image.memory`).
class AlimentoImagem extends StatelessWidget {
  AlimentoImagem({
    super.key,
    required Alimento alimento,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  }) : fotoUrl = alimento.fotoUrl,
       categoria = alimento.categoria,
       descricao = alimento.nome;

  /// Pré-visualização no formulário, antes de o anúncio existir.
  const AlimentoImagem.preview({
    super.key,
    required this.fotoUrl,
    required this.categoria,
    this.descricao = 'Foto do anúncio',
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
  });

  final String? fotoUrl;
  final Categoria categoria;
  final String descricao;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(width: width, height: height, child: _buildImagem()),
    );
  }

  Widget _buildImagem() {
    final url = fotoUrl;
    if (url == null || url.isEmpty) return _buildIconeCategoria();

    if (ImagemUtils.isDataUrl(url)) {
      final bytes = ImagemUtils.bytesDe(url);
      if (bytes == null) return _buildIconeCategoria();
      return Image.memory(
        bytes,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        semanticLabel: 'Foto de $descricao',
        errorBuilder: (context, erro, stack) => _buildIconeCategoria(),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      semanticLabel: 'Foto de $descricao',
      loadingBuilder: (context, child, progresso) =>
          progresso == null ? child : _buildIconeCategoria(),
      errorBuilder: (context, erro, stack) => _buildIconeCategoria(),
    );
  }

  Widget _buildIconeCategoria() {
    return ColoredBox(
      color: AppColors.secondaryLight,
      child: Center(
        child: Icon(
          categoria.icon,
          color: AppColors.secondary,
          size: 40,
          semanticLabel: categoria.label,
        ),
      ),
    );
  }
}
