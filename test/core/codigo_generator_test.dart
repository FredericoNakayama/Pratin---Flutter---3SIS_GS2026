import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/utils/codigo_generator.dart';

void main() {
  group('CodigoGenerator', () {
    test('gera códigos de 6 caracteres do alfabeto permitido', () {
      for (var i = 0; i < 1000; i++) {
        final codigo = CodigoGenerator.gerar();
        expect(codigo.length, CodigoGenerator.tamanho);
        for (final caractere in codigo.split('')) {
          expect(CodigoGenerator.alfabeto.contains(caractere), isTrue);
        }
      }
    });

    test('nunca usa caracteres ambíguos', () {
      final todos = List.generate(1000, (_) => CodigoGenerator.gerar()).join();
      for (final ambiguo in ['O', '0', 'I', '1']) {
        expect(todos.contains(ambiguo), isFalse, reason: 'contém $ambiguo');
      }
    });

    test('confere ignora maiúsculas e espaços nas pontas', () {
      expect(CodigoGenerator.confere(' px7k2q ', 'PX7K2Q'), isTrue);
      expect(CodigoGenerator.confere('PX7K2R', 'PX7K2Q'), isFalse);
    });
  });
}
