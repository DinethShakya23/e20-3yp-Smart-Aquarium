import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:frontend/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full login flow with real backend', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Optional: Navigate to Login screen if not already there
    final emailFieldFinder = find.byKey(const Key('emailField'));
    if (emailFieldFinder.evaluate().isEmpty) {
      final loginNavButton = find.text('Login');
      if (loginNavButton.evaluate().isNotEmpty) {
        await tester.tap(loginNavButton);
        await tester.pumpAndSettle();
      }
    }

    // Now do the login
    await tester.enterText(
        find.byKey(const Key('emailField')), 'tharusha@gmail.com');
    await tester.enterText(find.byKey(const Key('passwordField')), '12345');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Check for dashboard screen
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Dashboard'),
        findsOneWidget); // Adjust to your actual dashboard title
  });
}
