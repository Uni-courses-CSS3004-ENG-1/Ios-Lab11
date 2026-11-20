import 'package:flutter_test/flutter_test.dart';
import 'package:offline_notes_vault/main.dart';

void main() {
  testWidgets('app starts', (tester) async {
    await tester.pumpWidget(const VaultApp());
    expect(find.text('Notes & Settings Vault'), findsOneWidget);
  });
}
