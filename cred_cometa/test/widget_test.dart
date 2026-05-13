import 'package:flutter_test/flutter_test.dart';
import 'package:cred_cometa/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CredCometaApp());

    // Verify that the title is present
    expect(find.text('Meus Débitos'), findsOneWidget);
  });
}
