// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jiffy/main.dart';
import 'package:jiffy/presentation/widgets/button.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JiffyApp());
    await tester.pumpAndSettle();

    // Verify that the DesignSystemPage is shown
    expect(find.text('Modern Electric System'), findsOneWidget);
  });

  testWidgets('Button tap interaction', (WidgetTester tester) async {
    bool wasTapped = false;

    // Build a button with a callback
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Button(
            text: 'Test Button',
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Verify button is displayed with correct text
    expect(find.text('Test Button'), findsOneWidget);
    
    // Verify InkWell is present (for accessibility)
    expect(find.byType(InkWell), findsOneWidget);
    
    // Verify loading indicator is NOT shown
    expect(find.byType(CircularProgressIndicator), findsNothing);

    // Tap the button
    await tester.tap(find.text('Test Button'));
    // Use pump() to process the tap - we don't need animations to complete
    // to verify callback execution
    await tester.pump();

    // Verify callback was called immediately
    expect(wasTapped, isTrue);
  });

  testWidgets('Button does not respond when loading', (WidgetTester tester) async {
    bool wasTapped = false;

    // Build a button in loading state
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.light(),
        home: Scaffold(
          body: Button(
            text: 'Loading Button',
            isLoading: true,
            onTap: () {
              wasTapped = true;
            },
          ),
        ),
      ),
    );

    // Verify loading indicator is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    
    // Verify button text is NOT displayed when loading
    expect(find.text('Loading Button'), findsNothing);
    
    // Verify InkWell is NOT present when loading (button is disabled)
    expect(find.byType(InkWell), findsNothing);

    // Try to tap the button widget itself
    // Since there's no InkWell, the tap should do nothing
    await tester.tap(find.byType(Button));
    await tester.pump();

    // Verify callback was NOT called (button is disabled when loading)
    expect(wasTapped, isFalse);
  });
}
