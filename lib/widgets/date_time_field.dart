import 'package:flutter/material.dart';

/// Campo somente leitura que abre um seletor de data ou de data e hora.
class DateTimeField extends StatelessWidget {
  const DateTimeField({
    super.key,
    required this.label,
    required this.valorFormatado,
    required this.onTap,
    this.icon = Icons.event,
    this.errorText,
  });

  final String label;

  /// Texto exibido; `null` quando nada foi escolhido.
  final String? valorFormatado;
  final VoidCallback onTap;
  final IconData icon;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        isEmpty: valorFormatado == null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down),
          errorText: errorText,
        ),
        child: Text(valorFormatado ?? ''),
      ),
    );
  }
}
