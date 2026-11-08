import '../core/constants/app_messages.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/relogio.dart';
import '../data/api/alimento_api.dart';
import '../models/alimento.dart';
import '../models/enums.dart';
import 'anuncio_validator.dart';
import 'expiracao_service.dart';

/// Regras de listagem, publicação e cancelamento de anúncios.
class AlimentoService {
  AlimentoService({
    AlimentoApi? api,
    ExpiracaoService? expiracao,
    Relogio relogio = relogioDoSistema,
  }) : _api = api ?? AlimentoApi(),
       _expiracao = expiracao ?? ExpiracaoService(relogio: relogio),
       _relogio = relogio;

  final AlimentoApi _api;
  final ExpiracaoService _expiracao;
  final Relogio _relogio;

  /// Lista do Início: disponíveis, com janela aberta, vencimento mais próximo
  /// primeiro (RN05).
  Future<List<Alimento>> listarDisponiveis() async {
    final itens = await _api.listar(status: StatusAlimento.disponivel);
    final agora = _relogio();
    return _expiracao
        .aplicarEmAlimentos(itens)
        .where(
          (a) => a.status == StatusAlimento.disponivel && a.janelaAberta(agora),
        )
        .toList()
      ..sort(compararPorVencimento);
  }

  /// Anúncios do estabelecimento: pendentes primeiro, depois os mais recentes.
  Future<List<Alimento>> listarDoEstabelecimento(String cnpj) async {
    final itens = await _api.listar(estabelecimentoCnpj: cnpj);
    return _expiracao.aplicarEmAlimentos(
      itens.where((a) => a.estabelecimentoCnpj == cnpj).toList(),
    )..sort(compararPorPendencia);
  }

  /// Valida (RN03) e publica o anúncio como disponível.
  Future<Alimento> publicar(Alimento alimento) async {
    final erro = AnuncioValidator.validar(alimento, _relogio());
    if (erro != null) throw AppException(erro);
    return _api.criar(alimento.copyWith(status: StatusAlimento.disponivel));
  }

  static bool podeCancelar(Alimento alimento) =>
      alimento.status == StatusAlimento.disponivel;

  /// Cancela um anúncio que ainda está disponível (RN09).
  Future<void> cancelar(Alimento alimento) async {
    final atual = await _api.buscar(alimento.id);
    if (!podeCancelar(atual)) {
      throw const AppException(AppMessages.naoPodeCancelarAnuncio);
    }
    await _api.atualizar(atual.copyWith(status: StatusAlimento.cancelado));
  }

  /// Busca por nome (sem diferenciar maiúsculas e acentos), categoria e
  /// favoritos (RF07, RF08).
  static List<Alimento> filtrar(
    List<Alimento> alimentos, {
    String busca = '',
    Categoria? categoria,
    bool somenteFavoritos = false,
    Set<String> favoritos = const {},
  }) {
    final termo = normalizar(busca.trim());
    return alimentos.where((alimento) {
      if (categoria != null && alimento.categoria != categoria) return false;
      if (somenteFavoritos && !favoritos.contains(alimento.id)) return false;
      return termo.isEmpty || normalizar(alimento.nome).contains(termo);
    }).toList();
  }

  static int compararPorVencimento(Alimento a, Alimento b) {
    final porValidade = a.dataValidade.compareTo(b.dataValidade);
    return porValidade != 0
        ? porValidade
        : a.retiradaFim.compareTo(b.retiradaFim);
  }

  static int compararPorPendencia(Alimento a, Alimento b) {
    if (a.status.pendente != b.status.pendente) {
      return a.status.pendente ? -1 : 1;
    }
    return b.criadoEm.compareTo(a.criadoEm);
  }

  // dart format off
  static const Map<String, String> _acentos = {
    'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a',
    'é': 'e', 'ê': 'e', 'è': 'e', 'ë': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
    'ç': 'c',
  };
  // dart format on

  static String normalizar(String texto) => texto
      .toLowerCase()
      .split('')
      .map((letra) => _acentos[letra] ?? letra)
      .join();
}
