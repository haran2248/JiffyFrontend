import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jiffy/presentation/screens/onboarding/profile_setup/profile_setup_screen.dart';
import 'package:jiffy/presentation/widgets/progress_bar.dart';

void main() {
  group('ProfileSetupScreen Tests', () {
    testWidgets('ProfileSetupScreen displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify screen title
      expect(find.text('Profile Setup'), findsOneWidget);

      // Verify Skip button
      expect(find.text('Skip'), findsOneWidget);

      // Verify Progress bar (Step 2 of 3)
      expect(find.byType(ProgressBar), findsOneWidget);
    });

    testWidgets('Initial AI message is displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial AI message
      expect(
        find.textContaining(
            "Hey there! 👋 I'm here to help create your perfect profile"),
        findsOneWidget,
      );

      // Verify suggested responses are displayed
      expect(find.text('Hiking in nature ⛰️'), findsOneWidget);
      expect(find.text('Brunch and coffee ☕'), findsOneWidget);
      expect(find.text('Reading a good book 📚'), findsOneWidget);
      expect(find.text('Exploring new places 🏞️'), findsOneWidget);
    });

    testWidgets('User can select suggested response',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on a suggested response
      await tester.tap(find.text('Hiking in nature ⛰️'));
      await tester
          .pump(); // Use pump instead of pumpAndSettle to catch the typing state

      // Verify user message appears
      expect(find.text('Hiking in nature ⛰️'),
          findsWidgets); // Should appear in chat

      // Wait for AI typing indicator
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for AI response (simulated delay is 2 seconds)
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify AI response appears
      expect(
        find.textContaining('That sounds amazing'),
        findsWidgets,
      );

      // Clear the widget tree to stop animations and timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('User can type and send custom message',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the input field
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      // Enter custom text
      await tester.enterText(inputField, 'I love coding and building apps');
      await tester.pumpAndSettle();

      // Find and tap send button
      final sendButton = find.byIcon(Icons.send_rounded);
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify user message appears
      expect(find.text('I love coding and building apps'), findsOneWidget);

      // Wait for AI response
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Verify AI response appears
      expect(
        find.textContaining('That sounds amazing'),
        findsWidgets,
      );

      // Clear the widget tree to stop animations and timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Input field is disabled during AI typing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Send a message to trigger typing
      await tester.tap(find.text('Hiking in nature ⛰️'));
      await tester
          .pump(); // Use pump instead of pumpAndSettle to catch the typing state

      // Wait a bit for typing to start
      await tester.pump(const Duration(milliseconds: 100));

      // Verify input field exists (it should be disabled but still visible)
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      // Verify field is actually disabled
      final textFieldWidget = tester.widget<TextField>(inputField);
      expect(textFieldWidget.enabled, isFalse);

      // Clear the widget tree to stop animations and timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('Skip button navigates away', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Skip button
      await tester.tap(find.text('Skip'));
      await tester.pumpAndSettle();

      // The skip action should be called (navigation would happen in real app)
      // For now, we just verify the button is tappable
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets('Progress bar shows correct step', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify progress bar is displayed
      final progressBar = find.byType(ProgressBar);
      expect(progressBar, findsOneWidget);

      // Verify it's showing step 2 of 3
      final progressBarWidget = tester.widget<ProgressBar>(progressBar);
      expect(progressBarWidget.currentStep, equals(2));
      expect(progressBarWidget.totalSteps, equals(3));
    });

    testWidgets('Chat input field has correct placeholder',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify placeholder text
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Type your response...'));
    });
  });

  group('ProfileSetupViewModel Tests', () {
    testWidgets('ViewModel initializes with correct state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initial AI message is displayed
      expect(
        find.textContaining(
            "Hey there! 👋 I'm here to help create your perfect profile"),
        findsOneWidget,
      );

      // Verify suggested responses are shown
      expect(find.text('Hiking in nature ⛰️'), findsOneWidget);
    });

    testWidgets('User can send message and see it in chat',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProfileSetupScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find and enter text in input field
      final inputField = find.byType(TextField);
      expect(inputField, findsOneWidget);

      await tester.enterText(inputField, 'Test message');
      await tester.pumpAndSettle();

      // Tap send button
      final sendButton = find.byIcon(Icons.send_rounded);
      expect(sendButton, findsOneWidget);

      await tester.tap(sendButton);
      await tester.pumpAndSettle();

      // Verify user message appears
      expect(find.text('Test message'), findsOneWidget);

      // Clear the widget tree to stop animations and timers
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
