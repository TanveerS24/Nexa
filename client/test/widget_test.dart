import 'package:flutter_test/flutter_test.dart';
import 'package:nexa/main.dart';

void main() {
  testWidgets('Nexa smoke test: Renders Home UI with To-Do and Gym modules',
      (WidgetTester tester) async {
    await tester.pumpWidget(const NexaApp());

    // Verify Brand title is rendered
    expect(find.text('Nexa'), findsWidgets);

    // Verify Prompt headline is rendered
    expect(find.text('What do you\nwant to do?'), findsOneWidget);

    // Verify To-Do and Gym modules are rendered in the carousel
    expect(find.text('To-Do'), findsWidgets);
    expect(find.text('Gym'), findsWidgets);
  });
}
