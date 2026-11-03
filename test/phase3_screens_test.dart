import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/models/chat_model.dart';
import 'package:mobile/screens/messages/chat_detail_screen.dart';
import 'package:mobile/screens/messages/messages_screen.dart';
import 'package:mobile/screens/notifications/notifications_screen.dart';
import 'package:mobile/screens/ratings/rate_user_screen.dart';
import 'package:mobile/screens/ratings/rating_sent_screen.dart';
import 'package:mobile/widgets/voice_message_bubble.dart';
import 'package:mobile/widgets/voice_recorder_bar.dart';

Widget createTestApp(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  group('Phase 3 - Messaging & Voice Chat', () {
    testWidgets('MessagesScreen renders header', (tester) async {
      await tester.pumpWidget(createTestApp(const MessagesScreen()));
      await tester.pump();

      expect(find.text('Messages'), findsOneWidget);
    });

    testWidgets('ChatDetailScreen renders conversation header and input bar', (tester) async {
      final convo = ConversationModel(
        id: 'conv_1',
        contactId: 'u_hamza',
        contactName: 'Hamza A.',
        contextType: 'bike',
        contextTitle: 'Honda CD 70',
        lastMessage: 'Sure, sounds good',
        lastTime: '2m',
        campusId: 'camp_1',
      );

      await tester.pumpWidget(createTestApp(ChatDetailScreen(conversation: convo)));
      await tester.pump();

      expect(find.text('Hamza A.'), findsOneWidget);
      expect(find.text('Regarding: Honda CD 70'), findsOneWidget);
      expect(find.text('Type a message...'), findsOneWidget);
    });

    testWidgets('VoiceMessageBubble renders play button, waveform and duration', (tester) async {
      final msg = ChatMessageModel(
        id: 'vm_1',
        conversationId: 'conv_1',
        senderId: 'u_hamza',
        senderName: 'Hamza A.',
        voiceUrl: 'https://example.com/audio.m4a',
        duration: '0:12',
        waveformPeaks: [0.2, 0.5, 0.8, 0.4, 0.6],
        createdAt: DateTime.now(),
        isMe: false,
      );

      await tester.pumpWidget(createTestApp(VoiceMessageBubble(message: msg, isMe: false)));
      await tester.pump();

      expect(find.text('0:12'), findsOneWidget);
    });

    testWidgets('VoiceRecorderBar renders timer, cancel and send buttons', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          VoiceRecorderBar(
            onSendVoice: (path, dur, peaks) {},
            onCancel: () {},
            onPermissionDenied: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('0:00'), findsOneWidget);
    });
  });

  group('Phase 3 - Notifications Screen & Actions', () {
    testWidgets('NotificationsScreen renders filter chips and mark all read', (tester) async {
      await tester.pumpWidget(createTestApp(const NotificationsScreen()));
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Requests'), findsOneWidget);
      expect(find.text('Ratings'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);
    });
  });

  group('Phase 3 - Ratings Flow & Screens', () {
    testWidgets('RateUserScreen renders peer card, stars, tags and submit', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const RateUserScreen(
            peerId: 'u_hamza',
            peerName: 'Hamza A.',
            contextTitle: 'Bike rental: Honda CD 70',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Rate your experience'), findsOneWidget);
      expect(find.text('Hamza A.'), findsOneWidget);
      expect(find.text('Bike rental: Honda CD 70'), findsOneWidget);
      expect(find.text('What went well?'), findsOneWidget);
      expect(find.text('On time'), findsOneWidget);
      expect(find.text('Honest'), findsOneWidget);
      expect(find.text('Submit rating'), findsOneWidget);
    });

    testWidgets('RatingSentScreen renders checkmark, thanks title and buttons', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          const RatingSentScreen(
            peerName: 'Hamza A.',
            rating: 5,
            tags: ['On time', 'Honest'],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Thanks for rating Hamza A.'), findsOneWidget);
      expect(find.text('On time'), findsOneWidget);
      expect(find.text('Honest'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Edit my rating'), findsOneWidget);
    });
  });
}
