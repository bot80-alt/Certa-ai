import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:certa_ai/main.dart';
import 'package:certa_ai/providers/app_state_provider.dart';

void main() {
  testWidgets('Certa-AI app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => AppStateProvider(),
        child: const CertaAIApp(),
      ),
    );

    // Verify that our app title is displayed.
    expect(find.text('Certa-AI'), findsOneWidget);
  });
}
