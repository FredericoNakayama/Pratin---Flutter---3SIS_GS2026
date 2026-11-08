/// Leitura tolerante de campos JSON vindos da API.
///
/// Campos obrigatórios inválidos lançam [FormatException], que a camada de
/// dados converte em erro de "dados inesperados".
abstract final class JsonReader {
  static String texto(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor == null) throw FormatException('Campo "$campo" ausente');
    return valor.toString();
  }

  static String? textoOuNulo(Map<String, dynamic> json, String campo) {
    final valor = json[campo]?.toString().trim();
    return (valor == null || valor.isEmpty) ? null : valor;
  }

  /// Aceita `int`, `double` ou texto numérico (`"8.5"` ou `"8,5"`).
  static double numero(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is num) return valor.toDouble();
    final convertido = double.tryParse(
      valor?.toString().replaceAll(',', '.') ?? '',
    );
    if (convertido == null) throw FormatException('Campo "$campo" inválido');
    return convertido;
  }

  static bool booleano(Map<String, dynamic> json, String campo) {
    final valor = json[campo];
    if (valor is bool) return valor;
    return valor?.toString().toLowerCase() == 'true';
  }

  static DateTime data(Map<String, dynamic> json, String campo) {
    final convertido = DateTime.tryParse(json[campo]?.toString() ?? '');
    if (convertido == null) throw FormatException('Campo "$campo" inválido');
    // A API guarda horário local sem fuso; um "Z" eventual é convertido.
    return convertido.isUtc ? convertido.toLocal() : convertido;
  }
}
