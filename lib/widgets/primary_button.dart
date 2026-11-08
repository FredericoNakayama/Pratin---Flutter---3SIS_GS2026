import 'package:flutter/material.dart';

/// Botão principal de largura total, com estado de carregamento.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.carregando = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final conteudo = carregando
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: carregando ? null : onPressed,
        child: conteudo,
      ),
    );
  }
}
