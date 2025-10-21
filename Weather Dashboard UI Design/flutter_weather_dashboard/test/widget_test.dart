// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_weather_dashboard/app.dart';
import 'package:flutter_weather_dashboard/providers/weather_provider.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('App renders dashboard scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => WeatherProvider(),
        child: const MaterialApp(home: App()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Weather Dashboard'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
