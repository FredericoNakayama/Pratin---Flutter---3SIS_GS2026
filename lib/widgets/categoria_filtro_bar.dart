import 'package:flutter/material.dart';

import '../core/theme/app_spacing.dart';
import '../models/enums.dart';

/// Chips de filtro: Favoritos, Todos e as categorias (RF08).
class CategoriaFiltroBar extends StatelessWidget {
  const CategoriaFiltroBar({
    super.key,
    required this.categoria,
    required this.somenteFavoritos,
    required this.onCategoria,
    required this.onSomenteFavoritos,
  });

  final Categoria? categoria;
  final bool somenteFavoritos;
  final ValueChanged<Categoria?> onCategoria;
  final ValueChanged<bool> onSomenteFavoritos;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      child: Row(
        children: [
          FilterChip(
            avatar: Icon(
              somenteFavoritos ? Icons.favorite : Icons.favorite_border,
              size: 18,
            ),
            label: const Text('Favoritos'),
            selected: somenteFavoritos,
            showCheckmark: false,
            onSelected: onSomenteFavoritos,
          ),
          const SizedBox(width: AppSpacing.sm),
          ChoiceChip(
            label: const Text('Todos'),
            selected: categoria == null,
            onSelected: (_) => onCategoria(null),
          ),
          for (final item in Categoria.values) ...[
            const SizedBox(width: AppSpacing.sm),
            ChoiceChip(
              avatar: Icon(item.icon, size: 18),
              label: Text(item.label),
              selected: categoria == item,
              onSelected: (_) => onCategoria(item),
            ),
          ],
        ],
      ),
    );
  }
}
