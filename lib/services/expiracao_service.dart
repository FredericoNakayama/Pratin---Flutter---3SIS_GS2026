import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/exceptions/app_exception.dart';
import '../core/utils/relogio.dart';
import '../data/api/alimento_api.dart';
import '../data/api/reserva_api.dart';
import '../models/alimento.dart';
import '../models/enums.dart';
import '../models/reserva.dart';

/// Expiração automática quando a janela de retirada termina (RN11).
///
/// A tela recebe o novo status na hora; a gravação na API é feita em segundo
/// plano e, se falhar, não interrompe o carregamento.
class ExpiracaoService {
  ExpiracaoService({
    AlimentoApi? alimentoApi,
    ReservaApi? reservaApi,
    Relogio relogio = relogioDoSistema,
  }) : _alimentoApi = alimentoApi ?? AlimentoApi(),
       _reservaApi = reservaApi ?? ReservaApi(),
       _relogio = relogio;

  final AlimentoApi _alimentoApi;
  final ReservaApi _reservaApi;
  final Relogio _relogio;

  static bool alimentoDeveExpirar(Alimento alimento, DateTime agora) =>
      alimento.status.pendente && !alimento.janelaAberta(agora);

  static bool reservaDeveExpirar(Reserva reserva, DateTime agora) =>
      reserva.status == StatusReserva.ativa && !reserva.janelaAberta(agora);

  List<Alimento> aplicarEmAlimentos(List<Alimento> alimentos) {
    final agora = _relogio();
    return alimentos.map((alimento) {
      if (!alimentoDeveExpirar(alimento, agora)) return alimento;
      final expirado = alimento.copyWith(status: StatusAlimento.expirado);
      unawaited(
        _persistirAlimento(
          expirado,
          tinhaReserva: alimento.status == StatusAlimento.reservado,
        ),
      );
      return expirado;
    }).toList();
  }

  List<Reserva> aplicarEmReservas(List<Reserva> reservas) {
    final agora = _relogio();
    return reservas.map((reserva) {
      if (!reservaDeveExpirar(reserva, agora)) return reserva;
      final expirada = reserva.copyWith(status: StatusReserva.expirada);
      unawaited(_persistirReserva(expirada));
      return expirada;
    }).toList();
  }

  Future<void> _persistirAlimento(
    Alimento alimento, {
    required bool tinhaReserva,
  }) async {
    try {
      await _alimentoApi.atualizar(alimento);
      if (!tinhaReserva) return;
      final reservas = await _reservaApi.listar(alimentoId: alimento.id);
      for (final reserva in reservas) {
        if (reserva.alimentoId == alimento.id &&
            reserva.status == StatusReserva.ativa) {
          await _reservaApi.atualizar(
            reserva.copyWith(status: StatusReserva.expirada),
          );
        }
      }
    } on AppException catch (e) {
      debugPrint('Expiração do alimento ${alimento.id} não gravada: $e');
    }
  }

  Future<void> _persistirReserva(Reserva reserva) async {
    try {
      await _reservaApi.atualizar(reserva);
      final alimento = await _alimentoApi.buscar(reserva.alimentoId);
      if (alimento.status == StatusAlimento.reservado) {
        await _alimentoApi.atualizar(
          alimento.copyWith(status: StatusAlimento.expirado),
        );
      }
    } on AppException catch (e) {
      debugPrint('Expiração da reserva ${reserva.id} não gravada: $e');
    }
  }
}
