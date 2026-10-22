import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('CampusStitchApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CampusStitchApp());
    expect(find.byType(CampusStitchApp), findsOneWidget);
  });
}
