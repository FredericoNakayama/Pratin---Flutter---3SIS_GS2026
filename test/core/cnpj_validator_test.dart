import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/utils/cnpj_validator.dart';

void main() {
  group('CnpjValidator', () {
    test('aceita CNPJ válido com e sem máscara', () {
      expect(CnpjValidator.isValido('11.222.333/0001-81'), isTrue);
      expect(CnpjValidator.isValido('11222333000181'), isTrue);
      expect(CnpjValidator.isValido('45.723.174/0001-10'), isTrue);
    });

    test('rejeita sequência de dígitos iguais', () {
      expect(CnpjValidator.isValido('11.111.111/1111-11'), isFalse);
      expect(CnpjValidator.isValido('00000000000000'), isFalse);
    });

    test('rejeita tamanho errado e valores vazios', () {
      expect(CnpjValidator.isValido('1122233300018'), isFalse);
      expect(CnpjValidator.isValido('112223330001811'), isFalse);
      expect(CnpjValidator.isValido(''), isFalse);
      expect(CnpjValidator.isValido(null), isFalse);
    });

    test('rejeita dígitos verificadores errados', () {
      expect(CnpjValidator.isValido('11222333000182'), isFalse);
      expect(CnpjValidator.isValido('11222333000191'), isFalse);
    });

    test('apenasDigitos remove a pontuação', () {
      expect(
        CnpjValidator.apenasDigitos('11.222.333/0001-81'),
        '11222333000181',
      );
    });
  });
}
