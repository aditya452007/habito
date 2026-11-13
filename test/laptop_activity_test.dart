import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:streak/features/statistics/widgets/laptop_activity_card.dart';
import 'package:streak/services/laptop_activity_store.dart';

import 'support/app_harness.dart';

void main() {
  useEmptyStore();

  group('AppClassifier', () {
    test('classifies popular development tools', () {
      expect(AppClassifier.classify('Code.exe').category, AppCategory.development);
      expect(AppClassifier.classify('Code.exe').name, 'Visual Studio Code');
      expect(AppClassifier.classify('idea64.exe').category, AppCategory.development);
      expect(AppClassifier.classify('WindowsTerminal.exe').category, AppCategory.development);
      expect(AppClassifier.classify('powershell.exe').category, AppCategory.development);
    });

    test('classifies web browsers', () {
      expect(AppClassifier.classify('chrome.exe').category, AppCategory.browsing);
      expect(AppClassifier.classify('chrome.exe').name, 'Google Chrome');
      expect(AppClassifier.classify('msedge.exe').category, AppCategory.browsing);
      expect(AppClassifier.classify('firefox.exe').category, AppCategory.browsing);
      expect(AppClassifier.classify('brave.exe').category, AppCategory.browsing);
    });

    test('classifies productivity apps', () {
      expect(AppClassifier.classify('notion.exe').category, AppCategory.productivity);
      expect(AppClassifier.classify('slack.exe').category, AppCategory.productivity);
      expect(AppClassifier.classify('streak.exe').category, AppCategory.productivity);
    });

    test('classifies entertainment and media', () {
      expect(AppClassifier.classify('spotify.exe').category, AppCategory.entertainment);
      expect(AppClassifier.classify('discord.exe').category, AppCategory.entertainment);
      expect(AppClassifier.classify('steam.exe').category, AppCategory.entertainment);
    });
  });

  group('LaptopActivityStore', () {
    test('records and aggregates active usage and idle time', () {
      LaptopActivityStore.recordActiveUsage('Code.exe', 3600); // 1 hour
      LaptopActivityStore.recordActiveUsage('Code.exe', 1800); // 30 mins
      LaptopActivityStore.recordActiveUsage('chrome.exe', 900); // 15 mins
      LaptopActivityStore.recordIdle(600); // 10 mins

      final today = LaptopActivityStore.getTodayActivity();
      expect(today.totalActiveSeconds, 6300); // 1h 45m
      expect(today.formattedActiveTime, '1h 45m');
      expect(today.totalIdleSeconds, 600);
      expect(today.formattedIdleTime, '10m');
      expect(today.totalAwakeSeconds, 6900); // 1h 55m
      expect(today.formattedAwakeTime, '1h 55m');

      expect(today.apps.length, 2);
      expect(today.apps.first.displayName, 'Visual Studio Code');
      expect(today.apps.first.seconds, 5400); // 1h 30m
      expect(today.apps.first.formattedDuration, '1h 30m');

      final catMap = today.categorySeconds;
      expect(catMap[AppCategory.development], 5400);
      expect(catMap[AppCategory.browsing], 900);
    });

    test('persists data across flushSync', () {
      LaptopActivityStore.recordActiveUsage('spotify.exe', 1200);
      LaptopActivityStore.flushSync();

      final today = LaptopActivityStore.getTodayActivity();
      expect(today.apps.any((a) => a.displayName == 'Spotify'), isTrue);
    });
  });

  group('LaptopActivityCard widget', () {
    testWidgets('renders active summary and top apps list', (tester) async {
      LaptopActivityStore.recordActiveUsage('Code.exe', 7200); // 2 hours
      LaptopActivityStore.recordActiveUsage('chrome.exe', 1800); // 30 mins
      LaptopActivityStore.recordIdle(300);

      await pumpScreen(
        tester,
        const Scaffold(
          body: SingleChildScrollView(
            child: LaptopActivityCard(accent: Colors.cyan),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Laptop & Screen Activity'), findsOneWidget);
      expect(find.text('Visual Studio Code'), findsOneWidget);
      expect(find.text('Google Chrome'), findsOneWidget);
      expect(find.text('Top Applications'), findsOneWidget);
      expect(find.text('Tracking'), findsOneWidget);
    });
  });
}
