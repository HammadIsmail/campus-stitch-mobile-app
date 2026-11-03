import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('CampusStitchApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusStitchApp());
    expect(find.byType(CampusStitchApp), findsOneWidget);
    // Advance time past the splash delay so all timers finish and navigate
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
