import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/models/alimento.dart';
import 'package:pratin/models/enums.dart';
import 'package:pratin/models/perfil.dart';
import 'package:pratin/models/reserva.dart';

void main() {
  final alimentoJson = <String, dynamic>{
    'id': '1',
    'nome': 'Pão francês',
    'categoria': 'paes',
    'quantidade': 40,
    'unidade': 'unidade',
    'dataValidade': '2026-11-12',
    'retiradaInicio': '2026-11-10T16:00:00',
    'retiradaFim': '2026-11-10T19:00:00',
    'endereco': 'Rua das Flores, 120',
    'fotoUrl': '',
    'status': 'DISPONIVEL',
    'estabelecimentoCnpj': '11222333000181',
    'estabelecimentoNome': 'Padaria Pão Quente',
    'declaracaoProprio': true,
    'criadoEm': '2026-11-10T10:00:00',
  };

  group('Alimento', () {
    test('fromJson converte todos os campos', () {
      final alimento = Alimento.fromJson(alimentoJson);
      expect(alimento.id, '1');
      expect(alimento.categoria, Categoria.paes);
      expect(alimento.quantidade, 40.0);
      expect(alimento.unidade, Unidade.unidade);
      expect(alimento.dataValidade, DateTime(2026, 11, 12));
      expect(alimento.retiradaFim, DateTime(2026, 11, 10, 19));
      expect(alimento.fotoUrl, isNull);
      expect(alimento.status, StatusAlimento.disponivel);
      expect(alimento.declaracaoProprio, isTrue);
    });

    test('toJson e fromJson preservam os dados', () {
      final original = Alimento.fromJson(alimentoJson);
      final copia = Alimento.fromJson(original.toJson());
      expect(copia.toJson(), original.toJson());
      expect(original.toJson()['status'], 'DISPONIVEL');
      expect(original.toJson()['dataValidade'], '2026-11-12');
    });

    test('aceita quantidade decimal vinda como texto', () {
      final json = Map<String, dynamic>.from(alimentoJson)
        ..['quantidade'] = '8,5';
      expect(Alimento.fromJson(json).quantidade, 8.5);
    });

    test('valores desconhecidos não geram exceção', () {
      final json = Map<String, dynamic>.from(alimentoJson)
        ..['categoria'] = 'xyz'
        ..['status'] = 'ABC';
      final alimento = Alimento.fromJson(json);
      expect(alimento.categoria, Categoria.outros);
      expect(alimento.status, StatusAlimento.cancelado);
    });

    test('campo obrigatório ausente lança FormatException', () {
      final json = Map<String, dynamic>.from(alimentoJson)..remove('nome');
      expect(() => Alimento.fromJson(json), throwsFormatException);
    });

    test('copyWith altera apenas o status', () {
      final alimento = Alimento.fromJson(alimentoJson);
      final reservado = alimento.copyWith(status: StatusAlimento.reservado);
      expect(reservado.status, StatusAlimento.reservado);
      expect(reservado.nome, alimento.nome);
    });
  });

  group('Reserva', () {
    test('toJson e fromJson preservam os dados', () {
      final reserva = Reserva(
        id: '7',
        alimentoId: '1',
        alimentoNome: 'Pão francês',
        estabelecimentoCnpj: '11222333000181',
        estabelecimentoNome: 'Padaria Pão Quente',
        ongCnpj: '45723174000110',
        ongNome: 'ONG Mesa Cheia',
        codigoRetirada: 'PX7K2Q',
        endereco: 'Rua das Flores, 120',
        retiradaInicio: DateTime(2026, 11, 10, 16),
        retiradaFim: DateTime(2026, 11, 10, 19),
        status: StatusReserva.ativa,
        criadaEm: DateTime(2026, 11, 10, 11),
      );
      final copia = Reserva.fromJson(reserva.toJson());
      expect(copia.toJson(), reserva.toJson());
      expect(reserva.toJson()['status'], 'ATIVA');
    });
  });

  group('Perfil', () {
    test('toJson e fromJson preservam os dados', () {
      const perfil = Perfil(
        tipo: TipoPerfil.estabelecimento,
        nome: 'Padaria Pão Quente',
        cnpj: '11222333000181',
        endereco: 'Rua das Flores, 120',
      );
      final copia = Perfil.fromJson(perfil.toJson());
      expect(copia.tipo, TipoPerfil.estabelecimento);
      expect(copia.isEstabelecimento, isTrue);
      expect(copia.toJson(), perfil.toJson());
    });
  });
}
