import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/core/constants/app_messages.dart';
import 'package:pratin/core/constants/prefs_keys.dart';
import 'package:pratin/screens/perfil/perfil_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<void> abrir(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: PerfilScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('CNPJ inválido mostra erro e não salva', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await abrir(tester);

    await tester.enterText(find.byType(TextFormField).at(0), 'Padaria Teste');
    await tester.enterText(find.byType(TextFormField).at(1), '11222333000182');
    await tester.enterText(find.byType(TextFormField).at(2), 'Rua A, 10');
    await tester.tap(find.text('Salvar perfil'));
    await tester.pumpAndSettle();

    expect(find.text(AppMessages.cnpjInvalido), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(PrefsKeys.perfil), isNull);
  });

  testWidgets('perfil válido é salvo e o resumo aparece', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await abrir(tester);

    await tester.tap(find.text('ONG'));
    await tester.enterText(find.byType(TextFormField).at(0), 'ONG Mesa Cheia');
    await tester.enterText(
      find.byType(TextFormField).at(1),
      '45.723.174/0001-10',
    );
    await tester.enterText(find.byType(TextFormField).at(2), 'Rua B, 20');
    await tester.tap(find.text('Salvar perfil'));
    await tester.pumpAndSettle();

    expect(find.text('Meu perfil'), findsOneWidget);
    expect(find.text('45.723.174/0001-10'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(PrefsKeys.perfil),
      contains('"cnpj":"45723174000110"'),
    );
    expect(prefs.getString(PrefsKeys.perfil), contains('"tipo":"ong"'));
  });
}
