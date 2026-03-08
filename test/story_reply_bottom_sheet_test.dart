import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jiffy/presentation/screens/stories/widgets/story_reply_bottom_sheet.dart';

void main() {
  testWidgets('StoryReplyBottomSheet interaction test',
      (WidgetTester tester) async {
    bool wasSent = false;
    String sentMessage = '';

    // Create a wrapper to show the bottom sheet
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return Center(
                child: ElevatedButton(
                  onPressed: () {
                    StoryReplyBottomSheet.show(
                      context,
                      onSend: (message) async {
                        wasSent = true;
                        sentMessage = message;
                      },
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              );
            },
          ),
        ),
      ),
    );

    // Verify button is there
    expect(find.text('Open Sheet'), findsOneWidget);

    // Tap to open bottom sheet
    await tester.tap(find.text('Open Sheet'));
    await tester.pumpAndSettle();

    // Verify bottom sheet is shown
    expect(find.byType(StoryReplyBottomSheet), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'Great story!');
    await tester.pumpAndSettle();

    // Tap send button
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // Verify callback was triggered with correct text
    expect(wasSent, isTrue);
    expect(sentMessage, 'Great story!');
  });
}
