import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    final agora = DateTime(2026, 11, 10, 15, 30);

    test('venceEm segue a regra RN14', () {
      expect(Formatters.venceEm(DateTime(2026, 11, 10), agora), 'Vence hoje');
      expect(Formatters.venceEm(DateTime(2026, 11, 11), agora), 'Vence amanhã');
      expect(
        Formatters.venceEm(DateTime(2026, 11, 14), agora),
        'Vence em 4 dias',
      );
      expect(Formatters.venceEm(DateTime(2026, 11, 9), agora), 'Vencido');
    });

    test('janela no mesmo dia e em dias diferentes', () {
      expect(
        Formatters.janela(
          DateTime(2026, 11, 10, 14),
          DateTime(2026, 11, 10, 18),
        ),
        '10/11 14:00–18:00',
      );
      expect(
        Formatters.janela(
          DateTime(2026, 11, 10, 20),
          DateTime(2026, 11, 11, 8),
        ),
        '10/11 20:00 – 11/11 08:00',
      );
    });

    test('formatos da API', () {
      final valor = DateTime(2026, 11, 10, 9, 5);
      expect(Formatters.isoData(valor), '2026-11-10');
      expect(Formatters.isoDataHora(valor), '2026-11-10T09:05:00');
    });

    test('numero usa vírgula e omite casas desnecessárias', () {
      expect(Formatters.numero(40), '40');
      expect(Formatters.numero(8.5), '8,5');
      expect(Formatters.numero(0.25), '0,25');
    });

    test('cnpj aplica a máscara', () {
      expect(Formatters.cnpj('11222333000181'), '11.222.333/0001-81');
    });
  });
}
