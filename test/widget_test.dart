import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pratin/app.dart';

void main() {
  testWidgets('o app abre exibindo o logo', (tester) async {
    await tester.pumpWidget(const PratinApp());
    expect(find.byType(Image), findsOneWidget);
  });
}
