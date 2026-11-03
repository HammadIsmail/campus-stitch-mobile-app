import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/models/bike_model.dart';
import 'package:mobile/models/market_item_model.dart';
import 'package:mobile/models/roommate_model.dart';
import 'package:mobile/screens/bikes/bike_detail_screen.dart';
import 'package:mobile/screens/bikes/bike_requests_screen.dart';
import 'package:mobile/screens/bikes/bikes_screen.dart';
import 'package:mobile/screens/bikes/list_bike_screen.dart';
import 'package:mobile/screens/bikes/my_bikes_screen.dart';
import 'package:mobile/screens/market/market_item_detail_screen.dart';
import 'package:mobile/screens/market/market_item_owner_screen.dart';
import 'package:mobile/screens/market/market_item_owner_sold_screen.dart';
import 'package:mobile/screens/market/market_screen.dart';
import 'package:mobile/screens/market/sell_item_screen.dart';
import 'package:mobile/screens/profile/edit_profile_screen.dart';
import 'package:mobile/screens/profile/profile_screen.dart';
import 'package:mobile/screens/profile/user_profile_screen.dart';
import 'package:mobile/screens/roommates/post_roommate_screen.dart';
import 'package:mobile/screens/roommates/roommate_detail_screen.dart';
import 'package:mobile/screens/roommates/roommates_screen.dart';
import 'package:mobile/screens/services/offer_service_screen.dart';
import 'package:mobile/screens/services/services_screen.dart';
import 'package:mobile/screens/settings/settings_screen.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  group('Phase 2 - Services Screen & Form', () {
    testWidgets('ServicesScreen renders header, search and filter chips', (tester) async {
      await tester.pumpWidget(createTestApp(const ServicesScreen()));
      await tester.pump();

      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Offer a service'), findsOneWidget);
      expect(find.text('Search printing, repair, laundry'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Printing'), findsOneWidget);
    });

    testWidgets('OfferServiceScreen renders form fields and submit button', (tester) async {
      await tester.pumpWidget(createTestApp(const OfferServiceScreen()));
      await tester.pump();

      expect(find.text('Offer a service'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Service title'), findsOneWidget);
      expect(find.text('What do you offer?'), findsOneWidget);
      expect(find.text('Publish to my campus'), findsOneWidget);
    });
  });

  group('Phase 2 - Roommates Screen & Detail', () {
    testWidgets('RoommatesScreen renders segmented control', (tester) async {
      await tester.pumpWidget(createTestApp(const RoommatesScreen()));
      await tester.pump();

      expect(find.text('Roommates'), findsOneWidget);
      expect(find.text('Rooms available'), findsOneWidget);
      expect(find.text('Looking for a room'), findsOneWidget);
    });

    testWidgets('PostRoommateScreen renders custom preference adding', (tester) async {
      await tester.pumpWidget(createTestApp(const PostRoommateScreen()));
      await tester.pump();

      expect(find.text('New roommate post'), findsOneWidget);
      expect(find.text('Rent per person (Rs)'), findsOneWidget);
      expect(find.text('Post to my campus'), findsOneWidget);
    });

    testWidgets('RoommateDetailScreen renders stats and actions', (tester) async {
      final post = RoommatePostModel(
        id: 'p1',
        title: 'One seat open in a 3-person room',
        rent: 'Rs 9,000 / mo',
        area: 'Hostel 2, Block A',
        who: 'Hamza A.',
        tags: ['Non-smoker', 'Quiet'],
      );

      await tester.pumpWidget(createTestApp(RoommateDetailScreen(post: post)));
      await tester.pump();

      expect(find.text('Post details'), findsOneWidget);
      expect(find.text('One seat open in a 3-person room'), findsOneWidget);
      expect(find.text('Rent per person'), findsOneWidget);
      expect(find.text('Message in app'), findsOneWidget);
    });
  });

  group('Phase 2 - Bikes Screen & Owner Management', () {
    testWidgets('BikesScreen renders filters and header', (tester) async {
      await tester.pumpWidget(createTestApp(const BikesScreen()));
      await tester.pump();

      expect(find.text('Bikes'), findsOneWidget);
      expect(find.text('List yours'), findsOneWidget);
      expect(find.text('Available now'), findsOneWidget);
    });

    testWidgets('BikeDetailScreen renders rates and slot options', (tester) async {
      final bike = BikeModel(
        id: 'b1',
        model: 'Honda CD 70',
        dailyRate: 500,
        hourlyRate: 80,
        location: 'Hostel 2 gate',
        ownerName: 'Hamza A.',
      );

      await tester.pumpWidget(createTestApp(BikeDetailScreen(bike: bike)));
      await tester.pump();

      expect(find.text('Bike details'), findsOneWidget);
      expect(find.text('Honda CD 70'), findsOneWidget);
      expect(find.text('Per hour'), findsOneWidget);
      expect(find.text('Per day'), findsOneWidget);
      expect(find.text('Send rental request'), findsOneWidget);
    });

    testWidgets('ListBikeScreen renders bike listing form', (tester) async {
      await tester.pumpWidget(createTestApp(const ListBikeScreen()));
      await tester.pump();

      expect(find.text('List your bike'), findsOneWidget);
      expect(find.text('Bike model'), findsOneWidget);
      expect(find.text('Rs per hour'), findsOneWidget);
      expect(find.text('Publish my bike'), findsOneWidget);
    });

    testWidgets('MyBikesScreen renders review requests banner', (tester) async {
      await tester.pumpWidget(createTestApp(const MyBikesScreen()));
      await tester.pump();

      expect(find.text('My bikes'), findsOneWidget);
      expect(find.text('Review rental requests'), findsOneWidget);
    });

    testWidgets('BikeRequestsScreen renders pending and booked tabs', (tester) async {
      await tester.pumpWidget(createTestApp(const BikeRequestsScreen()));
      await tester.pump();

      expect(find.text('Rental requests'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Booked'), findsOneWidget);
    });
  });

  group('Phase 2 - Market Screen, Buy Requests & Owner States', () {
    testWidgets('MarketScreen renders category chips and search', (tester) async {
      await tester.pumpWidget(createTestApp(const MarketScreen()));
      await tester.pump();

      expect(find.text('Market'), findsOneWidget);
      expect(find.text('Sell'), findsOneWidget);
      expect(find.text('Search air coolers, tables, books'), findsOneWidget);
    });

    testWidgets('SellItemScreen renders category and condition selectors', (tester) async {
      await tester.pumpWidget(createTestApp(const SellItemScreen()));
      await tester.pump();

      expect(find.text('Sell an item'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Condition'), findsOneWidget);
      expect(find.text('List on my campus market'), findsOneWidget);
    });

    testWidgets('MarketItemDetailScreen renders offer inputs and CTAs', (tester) async {
      final item = MarketItemModel(
        id: 'm1',
        title: 'Air cooler, Super Asia',
        price: 14500,
        category: 'Appliances',
        condition: 'Used one season',
        sellerName: 'Sana M.',
        campusId: 'camp_1',
      );

      await tester.pumpWidget(createTestApp(MarketItemDetailScreen(item: item)));
      await tester.pump();

      expect(find.text('Item details'), findsOneWidget);
      expect(find.text('Air cooler, Super Asia'), findsOneWidget);
      expect(find.text('Request to buy'), findsOneWidget);
    });

    testWidgets('MarketItemOwnerScreen renders owner actions', (tester) async {
      final item = MarketItemModel(
        id: 'm1',
        title: 'Air cooler, Super Asia',
        price: 14500,
        category: 'Appliances',
        condition: 'Used',
        sellerName: 'Ali R.',
        campusId: 'camp_1',
      );

      await tester.pumpWidget(createTestApp(MarketItemOwnerScreen(item: item)));
      await tester.pump();

      expect(find.text('My listing'), findsOneWidget);
      expect(find.text('Mark as sold out'), findsOneWidget);
    });

    testWidgets('MarketItemOwnerSoldScreen renders marked sold confirmation', (tester) async {
      final item = MarketItemModel(
        id: 'm1',
        title: 'Air cooler, Super Asia',
        price: 14500,
        category: 'Appliances',
        condition: 'Used',
        sellerName: 'Ali R.',
        campusId: 'camp_1',
      );

      await tester.pumpWidget(createTestApp(MarketItemOwnerSoldScreen(item: item)));
      await tester.pump();

      expect(find.text('Marked as sold out'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
    });
  });

  group('Phase 2 - Profile & Settings', () {
    testWidgets('ProfileScreen renders user info and activity rows', (tester) async {
      await tester.pumpWidget(createTestApp(const ProfileScreen()));
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('My services'), findsOneWidget);
      expect(find.text('My bikes'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
    });

    testWidgets('EditProfileScreen renders editable profile fields', (tester) async {
      await tester.pumpWidget(createTestApp(const EditProfileScreen()));
      await tester.pump();

      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('Save changes'), findsOneWidget);
    });

    testWidgets('SettingsScreen renders account actions and settings options', (tester) async {
      await tester.pumpWidget(createTestApp(const SettingsScreen()));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Edit profile'), findsOneWidget);
      expect(find.text('Log out'), findsOneWidget);
      expect(find.text('Delete my account'), findsOneWidget);
    });

    testWidgets('UserProfileScreen renders rating breakdown and recent reviews', (tester) async {
      await tester.pumpWidget(createTestApp(const UserProfileScreen(
        userName: 'Hamza A.',
        ratingAvg: 4.8,
        ratingCount: 23,
        reviews: [
          {'name': 'Ali R.', 'stars': 5, 'when': 'Today', 'text': 'Bike was ready on time.'},
        ],
      )));
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('Recent reviews'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('UserProfileScreen renders honest empty state when no reviews exist', (tester) async {
      await tester.pumpWidget(createTestApp(const UserProfileScreen()));
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('No ratings yet'), findsOneWidget);
      expect(find.text('No reviews yet'), findsOneWidget);
    });
  });
}
