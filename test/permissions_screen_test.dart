import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jiffy/presentation/screens/onboarding/permissions/permissions_screen.dart';
import 'package:jiffy/presentation/screens/onboarding/permissions/widgets/permission_card.dart';
import 'package:jiffy/core/services/service_providers.dart';
import 'mocks.dart';

void main() {
  testWidgets('PermissionsScreen displays all permission items',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          permissionServiceProvider.overrideWithValue(MockPermissionService()),
          notificationServiceProvider
              .overrideWithValue(MockNotificationService()),
        ],
        child: const MaterialApp(
          home: PermissionsScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text("Just a couple of things..."), findsOneWidget);
    expect(find.text("Enable Location"), findsOneWidget);
    expect(find.text("Push Notifications"), findsOneWidget);

    // Cleanup
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('PermissionCard displays correctly and responds to tap',
      (WidgetTester tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PermissionCard(
            icon: Icons.location_on,
            title: "Test Location",
            description: "Test Description",
            isGranted: false,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    expect(find.text("Test Location"), findsOneWidget);
    expect(find.text("Enable"), findsOneWidget);

    await tester.tap(find.text("Enable"));
    expect(tapped, isTrue);

    // Cleanup
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('PermissionCard displays correctly when granted',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PermissionCard(
            icon: Icons.location_on,
            title: "Test Location",
            description: "Test Description",
            isGranted: true,
            onTap: _mockOnTap,
          ),
        ),
      ),
    );

    expect(find.text("Test Location"), findsOneWidget);
    expect(find.text("Enabled"), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    // Cleanup
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 5));
  });
}

void _mockOnTap() {}
