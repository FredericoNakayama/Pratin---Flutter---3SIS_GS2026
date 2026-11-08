import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/constants/app_messages.dart';
import 'package:pratin/screens/novo_anuncio/novo_anuncio_screen.dart';

import '../helpers/fixtures.dart';

void main() {
  testWidgets('publicar sem preencher mostra os erros de cada campo', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3200);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(home: NovoAnuncioScreen(perfil: estabelecimentoTeste)),
    );

    // O endereço vem preenchido com o do perfil.
    expect(find.text(estabelecimentoTeste.endereco), findsOneWidget);

    await tester.tap(find.text('Publicar anúncio'));
    await tester.pump();

    expect(find.text(AppMessages.nomeAlimentoInvalido), findsOneWidget);
    expect(find.text(AppMessages.categoriaObrigatoria), findsOneWidget);
    expect(find.text(AppMessages.quantidadeInvalida), findsOneWidget);
    expect(find.text(AppMessages.validadeObrigatoria), findsOneWidget);
    expect(find.text(AppMessages.janelaObrigatoria), findsOneWidget);
    expect(find.text(AppMessages.declaracaoObrigatoria), findsOneWidget);
  });
}
