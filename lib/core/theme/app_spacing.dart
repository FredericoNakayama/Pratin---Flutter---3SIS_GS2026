/// Escala de espaçamentos (múltiplos de 4) e raios usados no app.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  /// Margem lateral padrão das telas.
  static const double page = lg;

  static const double radiusCard = 12;
  static const double radiusButton = 10;

  /// Largura a partir da qual a lista vira grade de 2 colunas.
  static const double gridBreakpoint = 600;
}
