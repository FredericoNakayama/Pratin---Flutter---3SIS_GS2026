import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/exceptions/app_exception.dart';

/// Cliente HTTP do app: base URL, timeout e tradução de erros.
///
/// Qualquer falha vira [AppException] com mensagem pronta para o usuário.
class ApiClient {
  ApiClient({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiConstants.baseUrl;

  final http.Client _client;
  final String _baseUrl;

  static const Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Lista um recurso. No MockAPI, 404 em listagem filtrada = lista vazia.
  Future<List<Map<String, dynamic>>> getList(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _enviar(
      () => _client.get(_uri(path, query), headers: _headers),
    );
    if (response.statusCode == 404) return [];
    _verificarStatus(response);

    final corpo = _decodificar(response);
    if (corpo is! List) throw AppException.dados();
    return corpo.whereType<Map<String, dynamic>>().toList();
  }

  Future<Map<String, dynamic>> getOne(String path) async {
    final response = await _enviar(
      () => _client.get(_uri(path), headers: _headers),
    );
    if (response.statusCode == 404) throw AppException.naoEncontrado();
    _verificarStatus(response);
    return _objeto(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _enviar(
      () => _client.post(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
    _verificarStatus(response);
    return _objeto(response);
  }

  /// Envia o objeto completo (o MockAPI não garante atualização parcial).
  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _enviar(
      () => _client.put(_uri(path), headers: _headers, body: jsonEncode(body)),
    );
    if (response.statusCode == 404) throw AppException.naoEncontrado();
    _verificarStatus(response);
    return _objeto(response);
  }

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    return (query == null || query.isEmpty)
        ? uri
        : uri.replace(queryParameters: query);
  }

  Future<http.Response> _enviar(
    Future<http.Response> Function() requisicao,
  ) async {
    try {
      return await requisicao().timeout(ApiConstants.timeout);
    } on TimeoutException {
      throw AppException.timeout();
    } on http.ClientException {
      // Falha de rede (sem internet, DNS, conexão recusada).
      throw AppException.semConexao();
    }
  }

  void _verificarStatus(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AppException.servidor(response.statusCode);
    }
  }

  Object? _decodificar(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw AppException.dados();
    }
  }

  Map<String, dynamic> _objeto(http.Response response) {
    final corpo = _decodificar(response);
    if (corpo is! Map<String, dynamic>) throw AppException.dados();
    return corpo;
  }
}
