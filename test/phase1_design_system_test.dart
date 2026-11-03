import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/core/constants/app_constants.dart';
import 'package:mobile/core/localization/app_strings.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/widgets/app_button.dart';
import 'package:mobile/widgets/app_header.dart';
import 'package:mobile/widgets/app_text_field.dart';
import 'package:mobile/widgets/bottom_tab_bar.dart';
import 'package:mobile/widgets/chip_filter_row.dart';
import 'package:mobile/widgets/segmented_control.dart';
import 'package:mobile/widgets/state_view.dart';
import 'package:mobile/widgets/status_pill.dart';
import 'package:mobile/widgets/sub_header.dart';

void main() {
  group('Phase 1 - Design System & Tokens', () {
    test('Light theme tokens match exact design specification', () {
      const light = AppColorsExtension.light;
      expect(light.background, const Color(0xFFF5F4EF));
      expect(light.surface, const Color(0xFFFFFFFF));
      expect(light.border, const Color(0xFFE2E0D8));
      expect(light.divider, const Color(0xFFEEECE4));
      expect(light.inputBorder, const Color(0xFFCFCCC1));
      expect(light.text, const Color(0xFF16231F));
      expect(light.mutedText, const Color(0xFF5E6B66));
      expect(light.primary, const Color(0xFF0E6B50));
      expect(light.primarySoft, const Color(0xFFDCEFE7));
      expect(light.textOnSoft, const Color(0xFF0B4F3B));
      expect(light.amberAccent, const Color(0xFFE8962E));
      expect(light.amberSoft, const Color(0xFFFBE9CF));
      expect(light.textOnAmberSoft, const Color(0xFF5E3300));
      expect(light.danger, const Color(0xFFB3261E));
      expect(light.skeleton, const Color(0xFFE7E5DC));
    });

    test('Dark theme tokens match exact design specification', () {
      const dark = AppColorsExtension.dark;
      expect(dark.background, const Color(0xFF101A16));
      expect(dark.surface, const Color(0xFF1A2822));
      expect(dark.border, const Color(0xFF2E3D36));
      expect(dark.text, const Color(0xFFEAF2EE));
      expect(dark.mutedText, const Color(0xFFA3B5AD));
      expect(dark.primary, const Color(0xFF4CC59B));
      expect(dark.textOnPrimary, const Color(0xFF062A1E));
      expect(dark.danger, const Color(0xFFFF9A92));
    });

    test('Dimensions meet design rules', () {
      expect(AppDimensions.radiusInput, 12.0);
      expect(AppDimensions.radiusCard, 16.0);
      expect(AppDimensions.radiusButton, 14.0);
      expect(AppDimensions.radiusChip, 999.0);
      expect(AppDimensions.buttonHeight, 52.0);
      expect(AppDimensions.chipHeight, 44.0);
      expect(AppDimensions.minTouchTarget, 44.0);
    });

    test('App name constant exists and is configurable', () {
      expect(kAppName, isNotEmpty);
      expect(kAppName, 'CampuStitch');
    });
  });

  group('Phase 1 - Shared Widgets', () {
    testWidgets('AppHeader renders campus lock line, title, and action pill', (tester) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppHeader(
              title: 'Services',
              actionLabel: 'Offer a service',
              onAction: () => actionTapped = true,
              unreadMessagesCount: 2,
              unreadNotificationsCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('Services'), findsOneWidget);
      expect(find.text('Offer a service'), findsOneWidget);
      expect(find.byIcon(LucideIcons.lock), findsOneWidget);
      expect(find.byIcon(LucideIcons.sparkles), findsOneWidget);
      expect(find.byIcon(LucideIcons.messageSquare), findsOneWidget);
      expect(find.byIcon(LucideIcons.bell), findsOneWidget);

      await tester.tap(find.text('Offer a service'));
      await tester.pump();
      expect(actionTapped, isTrue);
    });

    testWidgets('SubHeader renders back button and title', (tester) async {
      bool backTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            appBar: SubHeader(
              title: 'Offer a service',
              onBack: () => backTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Offer a service'), findsOneWidget);
      expect(find.byIcon(LucideIcons.chevronLeft), findsOneWidget);

      await tester.tap(find.byIcon(LucideIcons.chevronLeft));
      await tester.pump();
      expect(backTapped, isTrue);
    });

    testWidgets('BottomTabBar displays all 5 tabs and handles tab selection', (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                bottomNavigationBar: BottomTabBar(
                  currentIndex: selectedTab,
                  onTabSelected: (idx) {
                    setState(() => selectedTab = idx);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text(AppStrings.tabServices), findsOneWidget);
      expect(find.text(AppStrings.tabRoommates), findsOneWidget);
      expect(find.text(AppStrings.tabBikes), findsOneWidget);
      expect(find.text(AppStrings.tabMarket), findsOneWidget);
      expect(find.text(AppStrings.tabProfile), findsOneWidget);

      await tester.tap(find.text(AppStrings.tabBikes));
      await tester.pump();
      expect(selectedTab, 2);
    });

    testWidgets('StateView.empty renders title, body, and CTA', (tester) async {
      bool ctaPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StateView.empty(
              icon: LucideIcons.bike,
              title: 'No bikes available',
              body: 'Check back soon or list your own bike.',
              ctaText: 'List your bike',
              onCta: () => ctaPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('No bikes available'), findsOneWidget);
      expect(find.text('Check back soon or list your own bike.'), findsOneWidget);
      expect(find.text('List your bike'), findsOneWidget);

      await tester.tap(find.text('List your bike'));
      await tester.pump();
      expect(ctaPressed, isTrue);
    });

    testWidgets('AppButton renders label and triggers callback', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: 'Submit',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      await tester.pump();
      expect(pressed, isTrue);
    });

    testWidgets('AppTextField renders label and hint', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: AppTextField(
              label: 'Full name',
              placeholder: 'e.g. Ali Raza',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('e.g. Ali Raza'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField), 'Hamza Ahmed');
      await tester.pump();
      expect(controller.text, 'Hamza Ahmed');
    });

    testWidgets('ChipFilterRow switches selected filter', (tester) async {
      String selected = 'All';

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: ChipFilterRow(
                  options: const ['All', 'Printing', 'Repair', 'Laundry'],
                  selectedOption: selected,
                  onSelected: (opt) {
                    setState(() => selected = opt);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Printing'), findsOneWidget);
      await tester.tap(find.text('Printing'));
      await tester.pump();
      expect(selected, 'Printing');
    });

    testWidgets('AppSegmentedControl switches active segment', (tester) async {
      int activeIndex = 0;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: AppSegmentedControl(
                  segments: const ['Rooms available', 'Looking for a room'],
                  selectedIndex: activeIndex,
                  onValueChanged: (idx) {
                    setState(() => activeIndex = idx);
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('Looking for a room'), findsOneWidget);
      await tester.tap(find.text('Looking for a room'));
      await tester.pump();
      expect(activeIndex, 1);
    });

    testWidgets('StatusPill renders label with appropriate variant styling', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                StatusPill(label: 'Pending', variant: StatusPillVariant.pending),
                StatusPill(label: 'Available', variant: StatusPillVariant.available),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
    });
  });
}
