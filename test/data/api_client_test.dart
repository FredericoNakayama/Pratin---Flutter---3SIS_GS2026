import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:pratin/core/exceptions/app_exception.dart';
import 'package:pratin/data/api/api_client.dart';

void main() {
  ApiClient clienteCom(MockClientHandler handler) =>
      ApiClient(client: MockClient(handler), baseUrl: 'https://api.teste');

  group('ApiClient', () {
    test('getList devolve a lista e envia os filtros', () async {
      late Uri chamada;
      final api = clienteCom((request) async {
        chamada = request.url;
        return http.Response(
          jsonEncode([
            {'id': '1'},
          ]),
          200,
        );
      });

      final lista = await api.getList('/alimentos', query: {'status': 'X'});

      expect(lista, hasLength(1));
      expect(chamada.toString(), 'https://api.teste/alimentos?status=X');
    });

    test('getList trata 404 como lista vazia', () async {
      final api = clienteCom((_) async => http.Response('"Not found"', 404));
      expect(await api.getList('/alimentos'), isEmpty);
    });

    test('getOne lança naoEncontrado em 404', () async {
      final api = clienteCom((_) async => http.Response('"Not found"', 404));
      await expectLater(
        api.getOne('/alimentos/9'),
        throwsA(
          isA<AppException>().having(
            (e) => e.tipo,
            'tipo',
            TipoErro.naoEncontrado,
          ),
        ),
      );
    });

    test('status 500 vira erro de servidor', () async {
      final api = clienteCom((_) async => http.Response('erro', 500));
      await expectLater(
        api.getList('/alimentos'),
        throwsA(
          isA<AppException>().having((e) => e.tipo, 'tipo', TipoErro.servidor),
        ),
      );
    });

    test('falha de rede vira erro de conexão', () async {
      final api = clienteCom(
        (_) async => throw http.ClientException('offline'),
      );
      await expectLater(
        api.getList('/alimentos'),
        throwsA(
          isA<AppException>().having(
            (e) => e.tipo,
            'tipo',
            TipoErro.semConexao,
          ),
        ),
      );
    });

    test('timeout vira erro de timeout', () async {
      final api = clienteCom((_) async => throw TimeoutException('lento'));
      await expectLater(
        api.getList('/alimentos'),
        throwsA(
          isA<AppException>().having((e) => e.tipo, 'tipo', TipoErro.timeout),
        ),
      );
    });

    test('JSON inválido vira erro de dados', () async {
      final api = clienteCom((_) async => http.Response('{quebrado', 200));
      await expectLater(
        api.getList('/alimentos'),
        throwsA(
          isA<AppException>().having((e) => e.tipo, 'tipo', TipoErro.dados),
        ),
      );
    });

    test('post envia JSON e devolve o objeto criado', () async {
      final api = clienteCom((request) async {
        expect(request.method, 'POST');
        expect(jsonDecode(request.body), {'nome': 'Pão'});
        // A API responde em UTF-8.
        return http.Response.bytes(
          utf8.encode(jsonEncode({'id': '5', 'nome': 'Pão'})),
          201,
        );
      });
      final criado = await api.post('/alimentos', {'nome': 'Pão'});
      expect(criado['id'], '5');
      expect(criado['nome'], 'Pão');
    });
  });
}
