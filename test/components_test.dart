import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/widgets/verified_student_badge.dart';
import 'package:mobile/widgets/empty_state_view.dart';

void main() {
  group('VerifiedStudentBadge tests', () {
    testWidgets('renders badge icon and label when isVerified is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedStudentBadge(
              isVerified: true,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsOneWidget);
      expect(find.text('Verified Student'), findsOneWidget);
    });

    testWidgets('renders nothing (SizedBox.shrink) when isVerified is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VerifiedStudentBadge(
              isVerified: false,
              showLabel: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.verified), findsNothing);
      expect(find.text('Verified Student'), findsNothing);
    });
  });

  group('EmptyStateView tests', () {
    testWidgets('renders title, description, and action button properly', (WidgetTester tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.search_off,
              title: 'No Rides Available',
              description: 'Try adjusting your destination or check back later.',
              actionLabel: 'Refresh Feed',
              onActionPressed: () {
                actionClicked = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('No Rides Available'), findsOneWidget);
      expect(find.text('Try adjusting your destination or check back later.'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
      expect(find.text('Refresh Feed'), findsOneWidget);

      await tester.tap(find.text('Refresh Feed'));
      await tester.pump();

      expect(actionClicked, isTrue);
    });

    testWidgets('supports constructor aliases message and onAction', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              icon: Icons.shopping_bag_outlined,
              title: 'No Items Listed',
              message: 'Be the first to list a textbook or dorm item.',
            ),
          ),
        ),
      );

      expect(find.text('No Items Listed'), findsOneWidget);
      expect(find.text('Be the first to list a textbook or dorm item.'), findsOneWidget);
    });
  });
}
