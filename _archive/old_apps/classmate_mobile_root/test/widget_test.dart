import 'package:flutter_test/flutter_test.dart';
import 'package:classmate_mobile/app/app.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.byType(App), findsOneWidget);
  });
}
