import '../core/constants/app_messages.dart';
import '../core/exceptions/app_exception.dart';
import '../core/utils/codigo_generator.dart';
import '../core/utils/relogio.dart';
import '../data/api/alimento_api.dart';
import '../data/api/reserva_api.dart';
import '../models/alimento.dart';
import '../models/enums.dart';
import 'reserva_service.dart';

/// Confirmação da retirada pelo código (RN10).
class RetiradaService {
  RetiradaService({
    AlimentoApi? alimentoApi,
    ReservaApi? reservaApi,
    ReservaService? reservaService,
    Relogio relogio = relogioDoSistema,
  }) : _alimentoApi = alimentoApi ?? AlimentoApi(),
       _reservaApi = reservaApi ?? ReservaApi(),
       _relogio = relogio,
       _reservaService =
           reservaService ??
           ReservaService(
             alimentoApi: alimentoApi,
             reservaApi: reservaApi,
             relogio: relogio,
           );

  final AlimentoApi _alimentoApi;
  final ReservaApi _reservaApi;
  final ReservaService _reservaService;
  final Relogio _relogio;

  static bool podeConfirmar(Alimento alimento, DateTime agora) =>
      alimento.status == StatusAlimento.reservado &&
      alimento.janelaAberta(agora);

  /// Código certo: alimento retirado e reserva concluída. Código errado:
  /// [AppException] com "Código inválido" e nada é alterado.
  Future<void> confirmar(Alimento alimento, String codigoDigitado) async {
    if (alimento.status != StatusAlimento.reservado) {
      throw const AppException(AppMessages.retiradaIndisponivel);
    }
    if (!alimento.janelaAberta(_relogio())) {
      throw const AppException(AppMessages.prazoEncerrado);
    }

    final reserva = await _reservaService.buscarAtivaDoAlimento(alimento.id);
    if (reserva == null) {
      throw const AppException(AppMessages.reservaNaoEncontrada);
    }
    if (!CodigoGenerator.confere(codigoDigitado, reserva.codigoRetirada)) {
      throw const AppException(AppMessages.codigoInvalido);
    }

    await _reservaApi.atualizar(
      reserva.copyWith(status: StatusReserva.concluida),
    );
    await _alimentoApi.atualizar(
      alimento.copyWith(status: StatusAlimento.retirado),
    );
  }
}
