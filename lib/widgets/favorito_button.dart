import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Coração para favoritar ou desfavoritar um alimento (RF09).
class FavoritoButton extends StatelessWidget {
  const FavoritoButton({
    super.key,
    required this.favorito,
    required this.onPressed,
  });

  final bool favorito;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      tooltip: favorito ? 'Remover dos favoritos' : 'Favoritar',
      icon: Icon(
        favorito ? Icons.favorite : Icons.favorite_border,
        color: favorito ? AppColors.favorite : AppColors.textSecondary,
      ),
    );
  }
}
