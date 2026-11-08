import '../core/constants/app_messages.dart';
import '../core/utils/formatters.dart';
import '../core/utils/imagem_utils.dart';
import '../models/alimento.dart';

/// Regras de um anúncio válido (RN03).
///
/// Cada método devolve a mensagem de erro, ou `null` quando o valor é válido.
abstract final class AnuncioValidator {
  static const int nomeMinimo = 2;
  static const int nomeMaximo = 60;
  static const int enderecoMinimo = 5;
  static const int diasMaximosValidade = 7;
  static const Duration janelaMinima = Duration(hours: 1);
  static const Duration toleranciaInicio = Duration(minutes: 5);

  static String? validarNome(String? valor) {
    final tamanho = (valor ?? '').trim().length;
    return (tamanho < nomeMinimo || tamanho > nomeMaximo)
        ? AppMessages.nomeAlimentoInvalido
        : null;
  }

  /// Converte o texto digitado (aceita vírgula) em quantidade.
  static double? lerQuantidade(String? valor) =>
      double.tryParse((valor ?? '').trim().replaceAll(',', '.'));

  static String? validarQuantidade(String? valor) {
    final quantidade = lerQuantidade(valor);
    return (quantidade == null || quantidade <= 0)
        ? AppMessages.quantidadeInvalida
        : null;
  }

  static String? validarValidade(DateTime? validade, DateTime agora) {
    if (validade == null) return AppMessages.validadeObrigatoria;
    final dias = Formatters.diasEntre(agora, validade);
    return (dias < 0 || dias > diasMaximosValidade)
        ? AppMessages.validadeForaDoPrazo
        : null;
  }

  /// Último instante em que a retirada pode terminar: 23:59 da validade.
  static DateTime limiteDaJanela(DateTime validade) =>
      DateTime(validade.year, validade.month, validade.day, 23, 59, 59);

  static String? validarJanela({
    required DateTime? inicio,
    required DateTime? fim,
    required DateTime? validade,
    required DateTime agora,
  }) {
    if (inicio == null || fim == null) return AppMessages.janelaObrigatoria;
    if (!fim.isAfter(agora) ||
        inicio.isBefore(agora.subtract(toleranciaInicio))) {
      return AppMessages.janelaNoPassado;
    }
    if (fim.difference(inicio) < janelaMinima) return AppMessages.janelaCurta;
    if (validade != null && fim.isAfter(limiteDaJanela(validade))) {
      return AppMessages.janelaAposValidade;
    }
    return null;
  }

  static String? validarEndereco(String? valor) =>
      (valor ?? '').trim().length < enderecoMinimo
      ? AppMessages.enderecoInvalido
      : null;

  /// Vazia, endereço `http(s)` ou foto do aparelho (data URL).
  static String? validarFotoUrl(String? valor) {
    final url = (valor ?? '').trim();
    return (url.isEmpty || url.startsWith('http') || ImagemUtils.isDataUrl(url))
        ? null
        : AppMessages.fotoUrlInvalida;
  }

  static String? validarDeclaracao(bool declarado) =>
      declarado ? null : AppMessages.declaracaoObrigatoria;

  /// Valida o anúncio inteiro e devolve o primeiro erro encontrado.
  static String? validar(Alimento alimento, DateTime agora) {
    return validarNome(alimento.nome) ??
        (alimento.quantidade > 0 ? null : AppMessages.quantidadeInvalida) ??
        validarValidade(alimento.dataValidade, agora) ??
        validarJanela(
          inicio: alimento.retiradaInicio,
          fim: alimento.retiradaFim,
          validade: alimento.dataValidade,
          agora: agora,
        ) ??
        validarEndereco(alimento.endereco) ??
        validarFotoUrl(alimento.fotoUrl) ??
        validarDeclaracao(alimento.declaracaoProprio);
  }
}
