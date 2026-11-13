import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/app/home_shell.dart';
import 'package:streak/core/database/local_store.dart';
import 'package:streak/features/habits/pages/home_page.dart';

import 'support/app_harness.dart';

void main() {
  useEmptyStore();

  testWidgets('wide layout supports resizable 3-pane split with Antigravity toggle icons',
      (tester) async {
    await seedHabits(tester, [
      testHabit(id: 'h1', name: 'Exercise'),
    ]);

    await pumpScreen(tester, const HomeShell());
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    await tester.pumpAndSettle();

    // Verify initial home page exists
    expect(find.byType(HomePage), findsOneWidget);

    // Verify Antigravity collapse sidebar icon exists in rail header
    expect(find.byIcon(LucideIcons.panelLeftClose), findsOneWidget);
    // Verify Antigravity collapse detail pane icon exists
    expect(find.byIcon(LucideIcons.panelRightClose), findsOneWidget);

    // Tap collapse sidebar icon
    await tester.tap(find.byIcon(LucideIcons.panelLeftClose));
    await tester.pumpAndSettle();

    // Sidebar should be collapsed, and expand sidebar icon should appear
    expect(find.byIcon(LucideIcons.panelLeftOpen), findsOneWidget);
    expect(LocalStore.setting<bool>('layout_rail_open', true), isFalse);

    // Tap expand sidebar icon
    await tester.tap(find.byIcon(LucideIcons.panelLeftOpen));
    await tester.pumpAndSettle();

    // Sidebar is open again
    expect(find.byIcon(LucideIcons.panelLeftClose), findsOneWidget);
    expect(LocalStore.setting<bool>('layout_rail_open', false), isTrue);

    // Tap collapse detail pane icon
    await tester.tap(find.byIcon(LucideIcons.panelRightClose));
    await tester.pumpAndSettle();

    // Detail pane is collapsed, and expand detail icon should appear
    expect(find.byIcon(LucideIcons.panelRightOpen), findsOneWidget);
    expect(LocalStore.setting<bool>('layout_detail_open', true), isFalse);

    // Tap expand detail icon
    await tester.tap(find.byIcon(LucideIcons.panelRightOpen));
    await tester.pumpAndSettle();

    expect(find.byIcon(LucideIcons.panelRightClose), findsOneWidget);
    expect(LocalStore.setting<bool>('layout_detail_open', false), isTrue);
  });
}
