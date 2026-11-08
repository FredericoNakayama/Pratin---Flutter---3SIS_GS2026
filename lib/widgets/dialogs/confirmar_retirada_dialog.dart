import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_messages.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/utils/codigo_generator.dart';

/// Pede o código de retirada da ONG e mostra o erro no próprio diálogo
/// (RF19). Devolve `true` quando a retirada foi confirmada.
class ConfirmarRetiradaDialog extends StatefulWidget {
  const ConfirmarRetiradaDialog({
    super.key,
    required this.alimentoNome,
    required this.onConfirmar,
  });

  final String alimentoNome;

  /// Confirma na API; lança [AppException] quando o código não confere.
  final Future<void> Function(String codigo) onConfirmar;

  @override
  State<ConfirmarRetiradaDialog> createState() =>
      _ConfirmarRetiradaDialogState();
}

class _ConfirmarRetiradaDialogState extends State<ConfirmarRetiradaDialog> {
  final TextEditingController _codigoController = TextEditingController();
  String? _erro;
  bool _confirmando = false;

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    final codigo = _codigoController.text.trim();
    if (codigo.length != CodigoGenerator.tamanho) {
      setState(() => _erro = AppMessages.codigoTamanho);
      return;
    }

    setState(() {
      _confirmando = true;
      _erro = null;
    });
    try {
      await widget.onConfirmar(codigo);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.mensagem;
        _confirmando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Confirmar retirada'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Digite o código apresentado pela ONG para "${widget.alimentoNome}".',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _codigoController,
            autofocus: true,
            enabled: !_confirmando,
            maxLength: CodigoGenerator.tamanho,
            textCapitalization: TextCapitalization.characters,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, letterSpacing: 6),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
              TextInputFormatter.withFunction(
                (_, novo) => novo.copyWith(text: novo.text.toUpperCase()),
              ),
            ],
            onSubmitted: (_) => _confirmar(),
            decoration: InputDecoration(
              hintText: 'PX7K2Q',
              errorText: _erro,
              counterText: '',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _confirmando
              ? null
              : () => Navigator.of(context).pop(false),
          child: const Text('Voltar'),
        ),
        ElevatedButton(
          onPressed: _confirmando ? null : _confirmar,
          child: _confirmando
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirmar'),
        ),
      ],
    );
  }
}
