import 'package:flutter_test/flutter_test.dart';
import 'package:weathergpt_mobile/main.dart';

void main() {
  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AppRoot());
    expect(find.byType(AppRoot), findsOneWidget);
  });
}
