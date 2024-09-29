import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
//import 'package:flutter_api/main.dart';
import 'package:weather_state_api/main.dart';

void main() {
  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester
        .pumpWidget(const WeatherApp()); // แก้ไขจาก MainApp เป็น WeatherApp

    // Verify that the list of cities is displayed.
    expect(find.text('Cities'), findsOneWidget);
    expect(find.text('Bangkok'), findsOneWidget);

    // Simulate a tap on the 'Bangkok' city item.
    await tester.tap(find.text('Bangkok'));
    await tester.pumpAndSettle(); // รอให้การนำทางเสร็จสิ้น

    // Verify that the weather details for 'Bangkok' are displayed.
    expect(find.text('Temperature'), findsOneWidget);
  });
}
