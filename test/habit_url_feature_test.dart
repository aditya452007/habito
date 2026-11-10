import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/features/habits/pages/home_page.dart';

import 'support/app_harness.dart';

void main() {
  useEmptyStore();

  testWidgets('habit card displays website globe icon when habit has a url', (tester) async {
    await seedHabits(tester, [
      testHabit(
        id: 'coding',
        name: 'LeetCode Practice',
        order: 0,
      ).copyWith(url: 'https://leetcode.com'),
      testHabit(
        id: 'exercise',
        name: 'Morning Walk',
        order: 1,
      ),
    ]);

    await pumpScreen(tester, const HomePage());

    // Coding habit has a URL, so globe icon should be rendered
    expect(find.byIcon(LucideIcons.globe), findsOneWidget);

    // Clicking globe icon tooltip contains url
    final iconButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(LucideIcons.globe),
        matching: find.byType(IconButton),
      ),
    );
    expect(iconButton.tooltip, 'https://leetcode.com');
  });
}
