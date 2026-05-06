import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cinematic_weather/main.dart' as app;
import 'package:cinematic_weather/presentation/widgets/city_search_bar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end: City weather flow', () {
    testWidgets(
      'open app → default city loads → search updates UI',
      (tester) async {
        // App uses MockWeatherSource when OWM_API_KEY is not set.
        app.main();
        await tester.pump();

        // Default city (Amsterdam) loads via mock source.
        await tester.pumpAndSettle(const Duration(seconds: 3));
        expect(find.text('Amsterdam'), findsOneWidget);

        // Search for London.
        final searchField = find.byType(TextField);
        await tester.tap(searchField);
        await tester.enterText(searchField, 'London');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // UI updates to show London.
        expect(find.text('London'), findsOneWidget);
        expect(find.text('Amsterdam'), findsNothing);
      },
    );

    testWidgets(
      'searching unknown city shows not-found error',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final searchField = find.byType(TextField);
        await tester.tap(searchField);
        await tester.enterText(searchField, 'XYZ_NONEXISTENT_9999');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.textContaining('not found'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'retry button re-shows weather after error is tapped',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        // Trigger an error.
        final searchField = find.byType(TextField);
        await tester.tap(searchField);
        await tester.enterText(searchField, 'XYZ_NONEXISTENT_9999');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Retry'), findsOneWidget);

        // Tap retry — retries the same failing city, stays on error.
        await tester.tap(find.text('Retry'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.text('Retry'), findsOneWidget);
      },
    );

    testWidgets(
      'CitySearchBar widget is present on home screen',
      (tester) async {
        app.main();
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byType(CitySearchBar), findsOneWidget);
      },
    );
  });
}
