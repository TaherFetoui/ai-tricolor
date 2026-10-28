import 'package:flutter_test/flutter_test.dart';
import 'package:ai_tricolor/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const AiTricolorApp());
    expect(find.byType(AiTricolorApp), findsOneWidget);
  });
}
