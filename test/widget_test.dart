import 'package:flutter_test/flutter_test.dart';
import 'package:my_chamber/main.dart';

void main() {
  testWidgets('MyChamber initial load test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyChamberApp());

    // Verify that the initial text is displayed.
    expect(find.text('MyChamber Connected to Supabase'), findsOneWidget);
  });
}
