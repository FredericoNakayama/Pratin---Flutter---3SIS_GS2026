import 'package:intl/intl.dart';

import 'cnpj_validator.dart';

/// Formatação de datas, números e CNPJ para exibição e para a API (RN15).
abstract final class Formatters {
  static final DateFormat _data = DateFormat('dd/MM/yyyy');
  static final DateFormat _diaMes = DateFormat('dd/MM');
  static final DateFormat _hora = DateFormat('HH:mm');
  static final DateFormat _isoData = DateFormat('yyyy-MM-dd');
  static final DateFormat _isoDataHora = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

  /// `10/11/2026`
  static String data(DateTime valor) => _data.format(valor);

  /// `14:00`
  static String hora(DateTime valor) => _hora.format(valor);

  /// `10/11/2026 14:00`
  static String dataHora(DateTime valor) => '${data(valor)} ${hora(valor)}';

  /// `10/11 14:00–18:00`, ou `10/11 20:00 – 11/11 08:00` em dias diferentes.
  static String janela(DateTime inicio, DateTime fim) {
    if (mesmoDia(inicio, fim)) {
      return '${_diaMes.format(inicio)} ${hora(inicio)}–${hora(fim)}';
    }
    return '${_diaMes.format(inicio)} ${hora(inicio)} – '
        '${_diaMes.format(fim)} ${hora(fim)}';
  }

  /// Data no formato da API: `2026-11-10`.
  static String isoData(DateTime valor) => _isoData.format(valor);

  /// Data e hora no formato da API, sem fuso: `2026-11-10T14:00:00`.
  static String isoDataHora(DateTime valor) => _isoDataHora.format(valor);

  /// `40`, `8,5` ou `0,25` (até duas casas, vírgula decimal).
  static String numero(double valor) {
    if (valor == valor.roundToDouble()) return valor.toInt().toString();
    var texto = valor.toStringAsFixed(2);
    texto = texto.replaceFirst(RegExp(r'0+$'), '');
    return texto.replaceAll('.', ',');
  }

  /// `00.000.000/0000-00` a partir dos dígitos.
  static String cnpj(String valor) {
    final d = CnpjValidator.apenasDigitos(valor);
    if (d.length != CnpjValidator.tamanho) return valor;
    return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/'
        '${d.substring(8, 12)}-${d.substring(12)}';
  }

  /// Texto de vencimento (RN14).
  static String venceEm(DateTime validade, DateTime agora) {
    final dias = diasEntre(agora, validade);
    if (dias < 0) return 'Vencido';
    if (dias == 0) return 'Vence hoje';
    if (dias == 1) return 'Vence amanhã';
    return 'Vence em $dias dias';
  }

  /// Diferença em dias de calendário, ignorando as horas.
  static int diasEntre(DateTime de, DateTime ate) =>
      apenasData(ate).difference(apenasData(de)).inDays;

  static DateTime apenasData(DateTime valor) =>
      DateTime(valor.year, valor.month, valor.day);

  static bool mesmoDia(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
