import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/presentation/screens/stories/widgets/story_reply_bottom_sheet.dart';

void main() {
  Widget buildTestApp({required Future<void> Function(String message) onSend}) {
    return MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return Center(
              child: ElevatedButton(
                onPressed: () {
                  StoryReplyBottomSheet.show(context, onSend: onSend);
                },
                child: const Text('Open Sheet'),
              ),
            );
          },
        ),
      ),
    );
  }

  group('StoryReplyBottomSheet interaction tests', () {
    testWidgets('Submitting an empty message does not call onSend',
        (WidgetTester tester) async {
      bool wasSent = false;
      await tester.pumpWidget(buildTestApp(onSend: (msg) async {
        wasSent = true;
      }));

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Tap send without entering text
      await tester.tap(find.byIcon(Icons.send));
      await tester.pump();

      expect(wasSent, isFalse);
    });

    testWidgets('Keyboard submit invokes onSend', (WidgetTester tester) async {
      bool wasSent = false;
      String sentMessage = '';
      await tester.pumpWidget(buildTestApp(onSend: (msg) async {
        wasSent = true;
        sentMessage = msg;
      }));

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Enter text and submit via keyboard action
      await tester.enterText(find.byType(TextField), 'Keyboard test');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();

      expect(wasSent, isTrue);
      expect(sentMessage, 'Keyboard test');
    });

    testWidgets(
        'Shows CircularProgressIndicator while sending and dismisses on success',
        (WidgetTester tester) async {
      bool wasSent = false;
      final completer = Completer<void>();

      await tester.pumpWidget(buildTestApp(onSend: (msg) async {
        wasSent = true;
        await completer.future; // Hold the async state
      }));

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.byType(StoryReplyBottomSheet), findsOneWidget);

      // Enter text
      await tester.enterText(find.byType(TextField), 'Loading test');
      await tester.pumpAndSettle();

      // Tap send
      await tester.tap(find.byIcon(Icons.send));
      await tester
          .pump(); // Start the animation (but don't wait for completion)

      // Verify Loading indicator appears and send icon disappears
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.send), findsNothing);

      // Complete the future
      completer.complete();
      await tester.pumpAndSettle(); // Let the bottom sheet dismiss

      expect(wasSent, isTrue);
      // Verify the bottom sheet has been dismissed
      expect(find.byType(StoryReplyBottomSheet), findsNothing);
    });
  });
}
