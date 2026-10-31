import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:culturetap_app/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    // Build our app
    await tester.pumpWidget(MyApp());

    // Verify splash screen appears
    expect(find.text('CultureTap'), findsOneWidget);
    expect(find.byIcon(Icons.explore), findsOneWidget);
  });

  testWidgets('Navigate from splash to login screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    
    // Wait for splash screen duration (2 seconds)
    await tester.pump(Duration(seconds: 3));
    
    // Should be on login screen now
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('Navigate from login to register screen', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    await tester.pump(Duration(seconds: 3));
    
    // Tap register button
    await tester.tap(find.text('Don\'t have an account? Register here'));
    await tester.pumpAndSettle();
    
    // Should be on register screen
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
  });
}