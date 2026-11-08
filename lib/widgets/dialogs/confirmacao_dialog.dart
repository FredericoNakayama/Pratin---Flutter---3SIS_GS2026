import 'package:flutter/material.dart';

/// Diálogo genérico de confirmação. Devolve `true` quando o usuário confirma.
class ConfirmacaoDialog extends StatelessWidget {
  const ConfirmacaoDialog({
    super.key,
    required this.titulo,
    required this.mensagem,
    required this.textoConfirmar,
    this.destrutivo = false,
  });

  final String titulo;
  final String mensagem;
  final String textoConfirmar;

  /// Pinta o botão de confirmação com a cor de erro (ex.: cancelamentos).
  final bool destrutivo;

  static Future<bool> abrir(
    BuildContext context, {
    required String titulo,
    required String mensagem,
    required String textoConfirmar,
    bool destrutivo = false,
  }) async {
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (_) => ConfirmacaoDialog(
        titulo: titulo,
        mensagem: mensagem,
        textoConfirmar: textoConfirmar,
        destrutivo: destrutivo,
      ),
    );
    return confirmou ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final corErro = Theme.of(context).colorScheme.error;
    return AlertDialog(
      title: Text(titulo),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Voltar'),
        ),
        ElevatedButton(
          style: destrutivo
              ? ElevatedButton.styleFrom(backgroundColor: corErro)
              : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(textoConfirmar),
        ),
      ],
    );
  }
}
