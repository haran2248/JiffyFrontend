import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jiffy/main.dart';
import 'package:jiffy/presentation/widgets/input.dart';
import 'package:jiffy/presentation/widgets/button.dart';

void main() {
  testWidgets('Basics multi-step flow test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: JiffyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // --- STEP 1: Name & Photo ---
    expect(find.text('Basics'), findsOneWidget);

    // Verify Step 1 elements
    expect(find.byType(ThemedInput), findsOneWidget); // Name
    expect(find.text('Date of Birth'), findsNothing); // Should not be on Step 1

    // Enter Name
    await tester.enterText(find.byType(TextField), 'Alice');
    await tester.pumpAndSettle();

    // Tap Continue
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    // --- STEP 2: Vitals ---
    expect(find.text('A little more'), findsOneWidget);

    // Verify Step 2 elements
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Gender'), findsOneWidget);
    expect(find.text('Select your date of birth'), findsOneWidget);
    expect(find.text('Select your gender'), findsOneWidget);

    // Verify Back button works
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // Should be back on Step 1
    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Alice'), findsOneWidget); // Value should be preserved
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

    // Clear the widget tree to stop animations and timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Button does not respond when loading',
      (WidgetTester tester) async {
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

    // Clear the widget tree to stop animations and timers
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 3));
  });
}
