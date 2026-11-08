import '../../core/constants/api_constants.dart';
import '../../models/alimento.dart';
import '../../models/enums.dart';
import 'api_client.dart';
import 'json_converter.dart';

/// Acesso ao recurso `alimentos` do MockAPI.
class AlimentoApi {
  AlimentoApi({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  Future<List<Alimento>> listar({
    StatusAlimento? status,
    String? estabelecimentoCnpj,
  }) async {
    final query = <String, String>{
      'status': ?status?.codigo,
      'estabelecimentoCnpj': ?estabelecimentoCnpj,
      'sortBy': 'dataValidade',
      'order': 'asc',
    };
    final lista = await _client.getList(ApiConstants.alimentos, query: query);
    return lista.map((json) => converterJson(json, Alimento.fromJson)).toList();
  }

  Future<Alimento> buscar(String id) async {
    final json = await _client.getOne('${ApiConstants.alimentos}/$id');
    return converterJson(json, Alimento.fromJson);
  }

  Future<Alimento> criar(Alimento alimento) async {
    final json = await _client.post(ApiConstants.alimentos, alimento.toJson());
    return converterJson(json, Alimento.fromJson);
  }

  Future<Alimento> atualizar(Alimento alimento) async {
    final json = await _client.put(
      '${ApiConstants.alimentos}/${alimento.id}',
      alimento.toJson(),
    );
    return converterJson(json, Alimento.fromJson);
  }
}
