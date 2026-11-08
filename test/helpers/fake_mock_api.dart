import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pratin/data/api/api_client.dart';

/// Simula o MockAPI em memória: listagem com filtros, busca, POST e PUT.
class FakeMockApi {
  final Map<String, Map<String, Map<String, dynamic>>> recursos = {
    'alimentos': {},
    'reservas': {},
  };
  int _proximoId = 1;

  /// Quando definido, POST neste recurso responde com erro 500.
  String? falharPostEm;

  ApiClient get client =>
      ApiClient(client: MockClient(_responder), baseUrl: 'https://fake');

  void inserir(String recurso, Map<String, dynamic> json) {
    final id = json['id']?.toString() ?? '${_proximoId++}';
    recursos[recurso]![id] = {...json, 'id': id};
  }

  Future<http.Response> _responder(http.Request request) async {
    final partes = request.url.pathSegments;
    final recurso = recursos[partes.first];
    if (recurso == null) return http.Response('"Not found"', 404);
    final id = partes.length > 1 ? partes[1] : null;

    switch (request.method) {
      case 'GET' when id == null:
        final filtros = Map.of(request.url.queryParameters)
          ..remove('sortBy')
          ..remove('order');
        final lista = recurso.values.where(
          (item) => filtros.entries.every(
            (f) => item[f.key]?.toString().contains(f.value) ?? false,
          ),
        );
        return _json(lista.toList());
      case 'GET':
        final item = recurso[id];
        return item == null ? http.Response('"Not found"', 404) : _json(item);
      case 'POST':
        if (falharPostEm == partes.first) return http.Response('erro', 500);
        final novo = jsonDecode(request.body) as Map<String, dynamic>;
        final novoId = '${_proximoId++}';
        recurso[novoId] = {...novo, 'id': novoId};
        return _json(recurso[novoId], 201);
      case 'PUT':
        if (!recurso.containsKey(id)) return http.Response('"Not found"', 404);
        final dados = jsonDecode(request.body) as Map<String, dynamic>;
        recurso[id!] = {...recurso[id]!, ...dados, 'id': id};
        return _json(recurso[id]);
    }
    return http.Response('', 405);
  }

  http.Response _json(Object? corpo, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(corpo)), status);
}
