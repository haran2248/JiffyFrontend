import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/presentation/screens/onboarding/co_pilot_intro/co_pilot_intro_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/profile_setup/profile_setup_screen.dart';

void main() {
  testWidgets('CoPilotIntroScreen displays all feature items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CoPilotIntroScreen(),
        ),
      ),
    );

    expect(find.text("Your Conversation Co-Pilot"), findsOneWidget);
    expect(find.text("Smart Icebreakers"), findsOneWidget);
    expect(find.text("Fresh Topics"), findsOneWidget);
    expect(find.text("You're in Control"), findsOneWidget);
    expect(find.text("See it in Action"), findsOneWidget);

    // Cleanup
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('CoPilotIntroScreen navigate to ProfileSetup on button tap',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: CoPilotIntroScreen(),
        ),
      ),
    );

    final button = find.text("Got it, Let's Continue");
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for transition

    expect(find.byType(ProfileSetupScreen), findsOneWidget);

    // Cleanup
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}
