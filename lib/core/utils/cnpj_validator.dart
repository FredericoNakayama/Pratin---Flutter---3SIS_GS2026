/// Validação de CNPJ pelo cálculo dos dígitos verificadores (RN02).
abstract final class CnpjValidator {
  static const int tamanho = 14;
  // dart format off
  static const List<int> _pesosPrimeiroDigito = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  static const List<int> _pesosSegundoDigito = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  // dart format on

  /// Remove tudo o que não for dígito.
  static String apenasDigitos(String valor) =>
      valor.replaceAll(RegExp(r'\D'), '');

  static bool isValido(String? valor) {
    if (valor == null) return false;
    final cnpj = apenasDigitos(valor);
    if (cnpj.length != tamanho) return false;
    if (RegExp(r'^(\d)\1*$').hasMatch(cnpj)) return false;

    final digitos = cnpj.split('').map(int.parse).toList();
    final primeiro = _calcularDigito(
      digitos.sublist(0, 12),
      _pesosPrimeiroDigito,
    );
    final segundo = _calcularDigito(
      digitos.sublist(0, 13),
      _pesosSegundoDigito,
    );
    return digitos[12] == primeiro && digitos[13] == segundo;
  }

  static int _calcularDigito(List<int> digitos, List<int> pesos) {
    var soma = 0;
    for (var i = 0; i < pesos.length; i++) {
      soma += digitos[i] * pesos[i];
    }
    final resto = soma % 11;
    return resto < 2 ? 0 : 11 - resto;
  }
}
