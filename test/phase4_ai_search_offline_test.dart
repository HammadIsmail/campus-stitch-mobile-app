import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/screens/market/market_screen.dart';
import 'package:mobile/screens/search/campus_search_screen.dart';
import 'package:mobile/screens/settings/delete_account_screen.dart';
import 'package:mobile/services/market_service.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  group('Phase 4 - AI Search (Ask)', () {
    testWidgets('CampusSearchScreen renders initial start state with ideas', (tester) async {
      await tester.pumpWidget(createTestApp(const CampusSearchScreen()));
      await tester.pump();

      expect(find.text('Ask $kAppName'), findsOneWidget);
      expect(find.text('What are you looking for?'), findsOneWidget);
      expect(find.text('Air cooler sale pe hai?'), findsOneWidget);
      expect(find.text('Aaj shaam ko koi bike available hai?'), findsOneWidget);
      expect(find.text('Hostel 3 mein printing wala koi hai?'), findsOneWidget);
    });
  });

  group('Phase 4 - Account Deletion', () {
    testWidgets('DeleteAccountScreen renders warnings and confirmation fields', (tester) async {
      await tester.pumpWidget(createTestApp(const DeleteAccountScreen()));
      await tester.pump();

      expect(find.text('Delete account'), findsOneWidget);
      expect(find.text('What will be deleted'), findsOneWidget);
      expect(find.text('Your profile, ratings and reviews'), findsOneWidget);
      expect(find.text('All chats and voice messages'), findsOneWidget);
      expect(find.text('Delete my account forever'), findsOneWidget);
      expect(find.text('Keep my account'), findsOneWidget);
    });
  });

  group('Phase 4 - Offline Caching', () {
    testWidgets('MarketScreen renders offline banner and saved items when cached', (tester) async {
      MarketService.shouldSimulateOffline = true;
      // Seed cache
      MarketService.cachedListings = [
        MarketItemModel(
          id: 'item_101',
          title: 'Air cooler, Super Asia',
          price: 14500,
          category: 'Appliances',
          condition: 'Used',
          location: 'Hostel 2',
          sellerName: 'Ali Raza',
          campusId: 'camp_1',
        ),
      ];

      await tester.pumpWidget(createTestApp(const MarketScreen()));
      // Pump initial load & async error resolution
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('You are offline'), findsOneWidget);
      expect(find.text('Air cooler, Super Asia'), findsOneWidget);
      expect(find.text('Rs 14500'), findsOneWidget);
      expect(find.text('Contact buttons and new posts need an internet connection.'), findsOneWidget);

      MarketService.shouldSimulateOffline = false;
    });
  });
}
