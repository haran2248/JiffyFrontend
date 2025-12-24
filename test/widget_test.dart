// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jiffy/main.dart';
import 'package:jiffy/presentation/widgets/input.dart';

void main() {
  testWidgets('App load smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: JiffyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Verify BasicsScreen title
    expect(find.text('Basics'), findsOneWidget);

    // Verify Inputs
    expect(find.byType(Input, skipOffstage: false), findsOneWidget); // Name
    expect(find.text('Date of Birth', skipOffstage: false), findsOneWidget);
    expect(find.text('Gender', skipOffstage: false), findsOneWidget);

    // Check for picker fields (they use InkWell containers)
    expect(find.text('Select your date of birth', skipOffstage: false),
        findsOneWidget);
    expect(
        find.text('Select your gender', skipOffstage: false), findsOneWidget);

    // Verify Button
    expect(find.text('Continue'), findsOneWidget);
  });
}
