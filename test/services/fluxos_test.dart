import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/constants/app_messages.dart';
import 'package:pratin/core/exceptions/app_exception.dart';
import 'package:pratin/data/api/alimento_api.dart';
import 'package:pratin/data/api/reserva_api.dart';
import 'package:pratin/models/enums.dart';
import 'package:pratin/services/alimento_service.dart';
import 'package:pratin/services/reserva_service.dart';
import 'package:pratin/services/retirada_service.dart';

import '../helpers/fake_mock_api.dart';
import '../helpers/fixtures.dart';

void main() {
  late FakeMockApi fake;
  late AlimentoApi alimentoApi;
  late ReservaApi reservaApi;
  late AlimentoService alimentoService;
  late ReservaService reservaService;
  late RetiradaService retiradaService;

  setUp(() {
    fake = FakeMockApi();
    final client = fake.client;
    alimentoApi = AlimentoApi(client: client);
    reservaApi = ReservaApi(client: client);
    alimentoService = AlimentoService(api: alimentoApi, relogio: relogioTeste);
    reservaService = ReservaService(
      alimentoApi: alimentoApi,
      reservaApi: reservaApi,
      relogio: relogioTeste,
    );
    retiradaService = RetiradaService(
      alimentoApi: alimentoApi,
      reservaApi: reservaApi,
      relogio: relogioTeste,
    );
  });

  Matcher erroCom(String mensagem) => throwsA(
    isA<AppException>().having((e) => e.mensagem, 'mensagem', mensagem),
  );

  group('AlimentoService', () {
    test(
      'lista só disponíveis com janela aberta, vencimento primeiro',
      () async {
        fake
          ..inserir(
            'alimentos',
            alimentoTeste(
              id: '1',
              dataValidade: DateTime(2026, 11, 14),
            ).toJson(),
          )
          ..inserir(
            'alimentos',
            alimentoTeste(
              id: '2',
              dataValidade: DateTime(2026, 11, 11),
            ).toJson(),
          )
          ..inserir(
            'alimentos',
            alimentoTeste(id: '3', status: StatusAlimento.reservado).toJson(),
          )
          ..inserir(
            'alimentos',
            alimentoTeste(
              id: '4',
              retiradaInicio: DateTime(2026, 11, 10, 7),
              retiradaFim: DateTime(2026, 11, 10, 9),
            ).toJson(),
          );

        final lista = await alimentoService.listarDisponiveis();

        expect(lista.map((a) => a.id), ['2', '1']);
      },
    );

    test('filtrar combina busca sem acento, categoria e favoritos', () {
      final itens = [
        alimentoTeste(id: '1', nome: 'Pão francês'),
        alimentoTeste(id: '2', nome: 'Pão de forma'),
        alimentoTeste(id: '3', nome: 'Banana', categoria: Categoria.hortifruti),
      ];
      expect(AlimentoService.filtrar(itens, busca: 'pao').length, 2);
      expect(
        AlimentoService.filtrar(
          itens,
          categoria: Categoria.hortifruti,
        ).single.id,
        '3',
      );
      expect(
        AlimentoService.filtrar(
          itens,
          somenteFavoritos: true,
          favoritos: {'2'},
        ).single.id,
        '2',
      );
    });

    test('publicar valida as regras antes de enviar', () async {
      await expectLater(
        alimentoService.publicar(alimentoTeste(nome: 'P')),
        erroCom(AppMessages.nomeAlimentoInvalido),
      );
      final publicado = await alimentoService.publicar(alimentoTeste());
      expect(publicado.id, isNotEmpty);
      expect(publicado.status, StatusAlimento.disponivel);
    });

    test('cancelar só funciona para anúncio disponível', () async {
      fake
        ..inserir('alimentos', alimentoTeste(id: '1').toJson())
        ..inserir(
          'alimentos',
          alimentoTeste(id: '2', status: StatusAlimento.reservado).toJson(),
        );

      await alimentoService.cancelar(alimentoTeste(id: '1'));
      expect(fake.recursos['alimentos']!['1']!['status'], 'CANCELADO');
      await expectLater(
        alimentoService.cancelar(alimentoTeste(id: '2')),
        erroCom(AppMessages.naoPodeCancelarAnuncio),
      );
    });
  });

  group('ReservaService', () {
    test(
      'reservar muda o alimento e cria a reserva ativa com código',
      () async {
        fake.inserir('alimentos', alimentoTeste(id: '1').toJson());

        final reserva = await reservaService.reservar(
          alimentoTeste(id: '1'),
          ongTeste,
        );

        expect(reserva.status, StatusReserva.ativa);
        expect(reserva.codigoRetirada, hasLength(6));
        expect(reserva.ongCnpj, ongTeste.cnpj);
        expect(fake.recursos['alimentos']!['1']!['status'], 'RESERVADO');
      },
    );

    test('segunda reserva recebe "já reservado"', () async {
      fake.inserir('alimentos', alimentoTeste(id: '1').toJson());
      await reservaService.reservar(alimentoTeste(id: '1'), ongTeste);

      await expectLater(
        reservaService.reservar(alimentoTeste(id: '1'), ongTeste),
        erroCom(AppMessages.jaReservado),
      );
    });

    test('estabelecimento não pode reservar', () async {
      await expectLater(
        reservaService.reservar(alimentoTeste(id: '1'), estabelecimentoTeste),
        erroCom(AppMessages.apenasOngs),
      );
    });

    test('se a reserva falhar, o alimento volta a ficar disponível', () async {
      fake
        ..inserir('alimentos', alimentoTeste(id: '1').toJson())
        ..falharPostEm = 'reservas';

      await expectLater(
        reservaService.reservar(alimentoTeste(id: '1'), ongTeste),
        throwsA(isA<AppException>()),
      );
      expect(fake.recursos['alimentos']!['1']!['status'], 'DISPONIVEL');
    });

    test('cancelar a reserva devolve o alimento para disponível', () async {
      fake.inserir('alimentos', alimentoTeste(id: '1').toJson());
      final reserva = await reservaService.reservar(
        alimentoTeste(id: '1'),
        ongTeste,
      );

      await reservaService.cancelar(reserva);

      expect(fake.recursos['reservas']![reserva.id]!['status'], 'CANCELADA');
      expect(fake.recursos['alimentos']!['1']!['status'], 'DISPONIVEL');
    });
  });

  group('RetiradaService', () {
    test('código errado não altera nada; código certo conclui', () async {
      fake.inserir('alimentos', alimentoTeste(id: '1').toJson());
      final reserva = await reservaService.reservar(
        alimentoTeste(id: '1'),
        ongTeste,
      );
      final reservado = alimentoTeste(
        id: '1',
        status: StatusAlimento.reservado,
      );

      await expectLater(
        retiradaService.confirmar(reservado, 'ZZZZZZ'),
        erroCom(AppMessages.codigoInvalido),
      );
      expect(fake.recursos['alimentos']!['1']!['status'], 'RESERVADO');

      await retiradaService.confirmar(
        reservado,
        reserva.codigoRetirada.toLowerCase(),
      );

      expect(fake.recursos['alimentos']!['1']!['status'], 'RETIRADO');
      expect(fake.recursos['reservas']![reserva.id]!['status'], 'CONCLUIDA');
    });
  });

  group('Expiração', () {
    test('alimento reservado com janela encerrada vira expirado', () async {
      fake.inserir(
        'alimentos',
        alimentoTeste(
          id: '1',
          status: StatusAlimento.reservado,
          retiradaInicio: DateTime(2026, 11, 10, 7),
          retiradaFim: DateTime(2026, 11, 10, 9),
        ).toJson(),
      );

      final lista = await alimentoService.listarDoEstabelecimento(
        estabelecimentoTeste.cnpj,
      );

      expect(lista.single.status, StatusAlimento.expirado);
    });
  });
}
