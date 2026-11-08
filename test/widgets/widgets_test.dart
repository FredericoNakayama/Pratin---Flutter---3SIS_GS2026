import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/models/enums.dart';
import 'package:pratin/widgets/alimento_card.dart';
import 'package:pratin/widgets/error_view.dart';
import 'package:pratin/widgets/status_chip.dart';

import '../helpers/fixtures.dart';

void main() {
  Widget envolver(Widget filho) => MaterialApp(home: Scaffold(body: filho));

  testWidgets('ErrorView chama "Tentar novamente"', (tester) async {
    var tentativas = 0;
    await tester.pumpWidget(
      envolver(
        ErrorView(mensagem: 'Falhou', onTentarNovamente: () => tentativas++),
      ),
    );

    await tester.tap(find.text('Tentar novamente'));
    expect(tentativas, 1);
    expect(find.text('Falhou'), findsOneWidget);
  });

  testWidgets('AlimentoCard mostra os dados e responde a toque e favorito', (
    tester,
  ) async {
    var abriu = false;
    var favoritou = false;
    await tester.pumpWidget(
      envolver(
        AlimentoCard(
          alimento: alimentoTeste(id: '1'),
          favorito: false,
          agora: agoraTeste,
          onTap: () => abriu = true,
          onFavoritar: () => favoritou = true,
        ),
      ),
    );

    expect(find.text('Pão francês'), findsOneWidget);
    expect(find.text('Vence em 2 dias'), findsOneWidget);
    expect(find.text('Retirada 10/11 14:00–18:00'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.favorite_border));
    await tester.tap(find.text('Pão francês'));
    expect(favoritou, isTrue);
    expect(abriu, isTrue);
  });

  testWidgets('StatusChip mostra o rótulo do status', (tester) async {
    await tester.pumpWidget(
      envolver(StatusChip.alimento(StatusAlimento.reservado)),
    );
    expect(find.text('Reservado'), findsOneWidget);
  });
}
