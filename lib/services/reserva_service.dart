import '../core/constants/app_messages.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/codigo_generator.dart';
import '../core/utils/relogio.dart';
import '../data/api/alimento_api.dart';
import '../data/api/reserva_api.dart';
import '../models/alimento.dart';
import '../models/enums.dart';
import '../models/perfil.dart';
import '../models/reserva.dart';
import 'expiracao_service.dart';

/// Regras de reserva e cancelamento de reservas.
class ReservaService {
  ReservaService({
    AlimentoApi? alimentoApi,
    ReservaApi? reservaApi,
    ExpiracaoService? expiracao,
    Relogio relogio = relogioDoSistema,
  }) : _alimentoApi = alimentoApi ?? AlimentoApi(),
       _reservaApi = reservaApi ?? ReservaApi(),
       _relogio = relogio,
       _expiracao =
           expiracao ??
           ExpiracaoService(
             alimentoApi: alimentoApi,
             reservaApi: reservaApi,
             relogio: relogio,
           );

  final AlimentoApi _alimentoApi;
  final ReservaApi _reservaApi;
  final ExpiracaoService _expiracao;
  final Relogio _relogio;

  /// Reserva o lote inteiro para a ONG (RN06) e gera o código (RN07).
  Future<Reserva> reservar(Alimento alimento, Perfil ong) async {
    if (!ong.isOng) throw const AppException(AppMessages.apenasOngs);

    final Alimento atual;
    try {
      // Consulta de novo: outra ONG pode ter reservado antes.
      atual = await _alimentoApi.buscar(alimento.id);
    } on AppException catch (e) {
      if (e.tipo == TipoErro.naoEncontrado) {
        throw const AppException(AppMessages.erroNaoEncontrado);
      }
      rethrow;
    }

    final agora = _relogio();
    if (atual.status != StatusAlimento.disponivel) {
      throw const AppException(AppMessages.jaReservado);
    }
    if (!atual.janelaAberta(agora)) {
      throw const AppException(AppMessages.prazoEncerrado);
    }

    final reservado = await _alimentoApi.atualizar(
      atual.copyWith(status: StatusAlimento.reservado),
    );

    try {
      return await _reservaApi.criar(
        Reserva(
          alimentoId: reservado.id,
          alimentoNome: reservado.nome,
          estabelecimentoCnpj: reservado.estabelecimentoCnpj,
          estabelecimentoNome: reservado.estabelecimentoNome,
          ongCnpj: ong.cnpj,
          ongNome: ong.nome,
          codigoRetirada: CodigoGenerator.gerar(),
          endereco: reservado.endereco,
          retiradaInicio: reservado.retiradaInicio,
          retiradaFim: reservado.retiradaFim,
          status: StatusReserva.ativa,
          criadaEm: agora,
        ),
      );
    } on AppException {
      // Sem reserva criada, o alimento volta a ficar disponível.
      try {
        await _alimentoApi.atualizar(
          reservado.copyWith(status: StatusAlimento.disponivel),
        );
      } on AppException {
        // Melhor esforço: o erro original é o que importa ao usuário.
      }
      rethrow;
    }
  }

  /// Reservas da ONG: ativas primeiro, depois as mais recentes.
  Future<List<Reserva>> listarDaOng(String cnpj) async {
    final reservas = await _reservaApi.listar(ongCnpj: cnpj);
    return _expiracao.aplicarEmReservas(
      reservas.where((r) => r.ongCnpj == cnpj).toList(),
    )..sort(compararPorPendencia);
  }

  /// Reservas ativas dos anúncios do estabelecimento, indexadas pelo alimento.
  Future<Map<String, Reserva>> ativasDoEstabelecimento(String cnpj) async {
    final reservas = await _reservaApi.listar(estabelecimentoCnpj: cnpj);
    return {
      for (final reserva in reservas)
        if (reserva.estabelecimentoCnpj == cnpj &&
            reserva.status == StatusReserva.ativa)
          reserva.alimentoId: reserva,
    };
  }

  Future<Reserva?> buscarAtivaDoAlimento(String alimentoId) async {
    final reservas = await _reservaApi.listar(alimentoId: alimentoId);
    for (final reserva in reservas) {
      if (reserva.alimentoId == alimentoId &&
          reserva.status == StatusReserva.ativa) {
        return reserva;
      }
    }
    return null;
  }

  static bool podeCancelar(Reserva reserva, DateTime agora) =>
      reserva.status == StatusReserva.ativa && reserva.janelaAberta(agora);

  /// Cancela a reserva e devolve o alimento para disponível (RN08).
  Future<void> cancelar(Reserva reserva) async {
    if (!podeCancelar(reserva, _relogio())) {
      throw const AppException(AppMessages.naoPodeCancelarReserva);
    }
    await _reservaApi.atualizar(
      reserva.copyWith(status: StatusReserva.cancelada),
    );
    final alimento = await _alimentoApi.buscar(reserva.alimentoId);
    if (alimento.status == StatusAlimento.reservado) {
      await _alimentoApi.atualizar(
        alimento.copyWith(status: StatusAlimento.disponivel),
      );
    }
  }

  static int compararPorPendencia(Reserva a, Reserva b) {
    final aAtiva = a.status == StatusReserva.ativa;
    final bAtiva = b.status == StatusReserva.ativa;
    if (aAtiva != bAtiva) return aAtiva ? -1 : 1;
    return b.criadaEm.compareTo(a.criadaEm);
  }
}
