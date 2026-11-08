import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/constants/app_messages.dart';
import 'package:pratin/services/anuncio_validator.dart';

import '../helpers/fixtures.dart';

void main() {
  final agora = agoraTeste; // 10/11/2026 10:00

  group('AnuncioValidator', () {
    test('nome entre 2 e 60 caracteres', () {
      expect(AnuncioValidator.validarNome('Pão'), isNull);
      expect(
        AnuncioValidator.validarNome('P'),
        AppMessages.nomeAlimentoInvalido,
      );
      expect(AnuncioValidator.validarNome('x' * 61), isNotNull);
    });

    test('quantidade maior que zero, aceitando vírgula', () {
      expect(AnuncioValidator.validarQuantidade('8,5'), isNull);
      expect(AnuncioValidator.lerQuantidade('8,5'), 8.5);
      expect(AnuncioValidator.validarQuantidade('0'), isNotNull);
      expect(AnuncioValidator.validarQuantidade('-2'), isNotNull);
      expect(AnuncioValidator.validarQuantidade('abc'), isNotNull);
    });

    test('validade entre hoje e hoje + 7 dias', () {
      expect(
        AnuncioValidator.validarValidade(DateTime(2026, 11, 10), agora),
        isNull,
      );
      expect(
        AnuncioValidator.validarValidade(DateTime(2026, 11, 17), agora),
        isNull,
      );
      expect(
        AnuncioValidator.validarValidade(DateTime(2026, 11, 18), agora),
        AppMessages.validadeForaDoPrazo,
      );
      expect(
        AnuncioValidator.validarValidade(DateTime(2026, 11, 9), agora),
        AppMessages.validadeForaDoPrazo,
      );
      expect(
        AnuncioValidator.validarValidade(null, agora),
        AppMessages.validadeObrigatoria,
      );
    });

    String? janela(DateTime? inicio, DateTime? fim, [DateTime? validade]) =>
        AnuncioValidator.validarJanela(
          inicio: inicio,
          fim: fim,
          validade: validade ?? DateTime(2026, 11, 12),
          agora: agora,
        );

    test('janela válida de pelo menos 1 hora', () {
      expect(
        janela(DateTime(2026, 11, 10, 14), DateTime(2026, 11, 10, 15)),
        isNull,
      );
      expect(
        janela(DateTime(2026, 11, 10, 14), DateTime(2026, 11, 10, 14, 30)),
        AppMessages.janelaCurta,
      );
    });

    test('janela precisa estar preenchida e no futuro', () {
      expect(
        janela(null, DateTime(2026, 11, 10, 15)),
        AppMessages.janelaObrigatoria,
      );
      expect(
        janela(DateTime(2026, 11, 10, 8), DateTime(2026, 11, 10, 9)),
        AppMessages.janelaNoPassado,
      );
      // Tolerância de 5 minutos no início.
      expect(
        janela(DateTime(2026, 11, 10, 9, 57), DateTime(2026, 11, 10, 11)),
        isNull,
      );
    });

    test('janela termina até 23:59 do dia da validade', () {
      final validade = DateTime(2026, 11, 11);
      expect(
        janela(
          DateTime(2026, 11, 11, 20),
          DateTime(2026, 11, 11, 23, 59),
          validade,
        ),
        isNull,
      );
      expect(
        janela(
          DateTime(2026, 11, 11, 22),
          DateTime(2026, 11, 12, 0, 30),
          validade,
        ),
        AppMessages.janelaAposValidade,
      );
    });

    test('URL da foto opcional e declaração obrigatória', () {
      expect(AnuncioValidator.validarFotoUrl(''), isNull);
      expect(AnuncioValidator.validarFotoUrl('https://x.com/a.jpg'), isNull);
      expect(
        AnuncioValidator.validarFotoUrl('foto.jpg'),
        AppMessages.fotoUrlInvalida,
      );
      expect(AnuncioValidator.validarDeclaracao(true), isNull);
      expect(
        AnuncioValidator.validarDeclaracao(false),
        AppMessages.declaracaoObrigatoria,
      );
    });

    test('validar aceita o anúncio completo e aponta o primeiro erro', () {
      expect(AnuncioValidator.validar(alimentoTeste(), agora), isNull);
      expect(
        AnuncioValidator.validar(alimentoTeste(nome: 'P'), agora),
        AppMessages.nomeAlimentoInvalido,
      );
    });
  });
}
