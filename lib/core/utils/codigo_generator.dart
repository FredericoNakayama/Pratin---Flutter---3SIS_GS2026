import 'dart:math';

/// Gera o código de retirada de uma reserva (RN07).
abstract final class CodigoGenerator {
  /// Sem O, 0, I e 1, que se confundem na leitura.
  static const String alfabeto = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int tamanho = 6;

  static String gerar([Random? random]) {
    final gerador = random ?? Random.secure();
    return List.generate(
      tamanho,
      (_) => alfabeto[gerador.nextInt(alfabeto.length)],
    ).join();
  }

  /// Compara o código digitado com o esperado, sem diferenciar maiúsculas.
  static bool confere(String digitado, String esperado) =>
      digitado.trim().toUpperCase() == esperado.trim().toUpperCase();
}
