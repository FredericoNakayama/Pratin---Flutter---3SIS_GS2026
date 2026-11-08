import 'package:flutter/material.dart';

import '../../core/constants/app_messages.dart';
import '../../core/constants/app_routes.dart';

/// Pede que o usuário configure o perfil antes de anunciar ou reservar (RF21).
class PerfilNecessarioDialog extends StatelessWidget {
  const PerfilNecessarioDialog({super.key});

  /// Mostra o diálogo e, se o usuário aceitar, abre a tela de Perfil.
  /// Devolve `true` quando um perfil foi salvo.
  static Future<bool> abrir(BuildContext context) async {
    final configurar = await showDialog<bool>(
      context: context,
      builder: (_) => const PerfilNecessarioDialog(),
    );
    if (configurar != true || !context.mounted) return false;
    final salvou = await Navigator.of(context).pushNamed(AppRoutes.perfil);
    return salvou == true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      icon: const Icon(Icons.badge_outlined),
      title: const Text('Perfil necessário'),
      content: const Text(AppMessages.perfilNecessario),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Agora não'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Configurar perfil'),
        ),
      ],
    );
  }
}
