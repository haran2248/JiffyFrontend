import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jiffy/main.dart';
import 'package:jiffy/presentation/widgets/input.dart';

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
    expect(find.byType(Input), findsOneWidget); // Name
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
}
