import 'package:flutter/material.dart';

/// Paleta de cores do Pratin.
///
/// Telas e widgets usam estas constantes (ou o `Theme`), nunca cores soltas.
abstract final class AppColors {
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFFC8E6C9);
  static const Color secondary = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFC62828);
  static const Color textPrimary = Color(0xFF1B1B1B);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color favorite = Color(0xFFE53935);

  // Status do alimento e da reserva.
  static const Color statusDisponivel = Color(0xFF2E7D32);
  static const Color statusReservado = Color(0xFFFFA000);
  static const Color statusRetirado = Color(0xFF1565C0);
  static const Color statusCancelado = Color(0xFF757575);
  static const Color statusExpirado = Color(0xFFB71C1C);
}
