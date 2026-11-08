import '../../core/constants/api_constants.dart';
import '../../models/reserva.dart';
import 'api_client.dart';
import 'json_converter.dart';

/// Acesso ao recurso `reservas` do MockAPI.
class ReservaApi {
  ReservaApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Reserva>> listar({
    String? ongCnpj,
    String? estabelecimentoCnpj,
    String? alimentoId,
  }) async {
    final query = <String, String>{
      'ongCnpj': ?ongCnpj,
      'estabelecimentoCnpj': ?estabelecimentoCnpj,
      'alimentoId': ?alimentoId,
    };
    final lista = await _client.getList(ApiConstants.reservas, query: query);
    return lista.map((json) => converterJson(json, Reserva.fromJson)).toList();
  }

  Future<Reserva> criar(Reserva reserva) async {
    final json = await _client.post(ApiConstants.reservas, reserva.toJson());
    return converterJson(json, Reserva.fromJson);
  }

  Future<Reserva> atualizar(Reserva reserva) async {
    final json = await _client.put(
      '${ApiConstants.reservas}/${reserva.id}',
      reserva.toJson(),
    );
    return converterJson(json, Reserva.fromJson);
  }
}
