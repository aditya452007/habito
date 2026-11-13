import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:streak/app/theme/app_tokens.dart';
import 'package:streak/features/statistics/widgets/stat_kit.dart';
import 'package:streak/services/laptop_activity_store.dart';
import 'package:streak/services/windows_activity_tracker.dart';

Color _categoryColor(AppCategory category) => switch (category) {
      AppCategory.development => const Color(0xFF5CCFE6), // Antigravity Cyan
      AppCategory.browsing => const Color(0xFF5E81AC), // Slate Blue
      AppCategory.productivity => const Color(0xFFD97757), // Warm Terracotta
      AppCategory.entertainment => const Color(0xFFB48EAD), // Soft Violet
      AppCategory.system => const Color(0xFF8F93A3), // Steel Grey
      AppCategory.other => const Color(0xFF6C7086), // Muted Grey
    };

String _categoryLabel(AppCategory category) => switch (category) {
      AppCategory.development => 'Development',
      AppCategory.browsing => 'Browsing',
      AppCategory.productivity => 'Productivity',
      AppCategory.entertainment => 'Entertainment',
      AppCategory.system => 'System',
      AppCategory.other => 'Other',
    };

IconData _categoryIcon(AppCategory category) => switch (category) {
      AppCategory.development => LucideIcons.code,
      AppCategory.browsing => LucideIcons.globe,
      AppCategory.productivity => LucideIcons.checkCheck,
      AppCategory.entertainment => LucideIcons.gamepad2,
      AppCategory.system => LucideIcons.cpu,
      AppCategory.other => LucideIcons.appWindow,
    };

class LaptopActivityCard extends StatelessWidget {
  const LaptopActivityCard({
    super.key,
    required this.accent,
  });

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: LaptopActivityStore.changeNotifier,
      builder: (context, _, __) {
        final activity = LaptopActivityStore.getTodayActivity();
        final enabled = LaptopActivityStore.isEnabled();

        return StatCard(
          title: 'Laptop & Screen Activity',
          icon: LucideIcons.laptop,
          color: accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HeaderSummary(
                activity: activity,
                enabled: enabled,
                accent: accent,
              ),
              const SizedBox(height: 16),
              if (activity.totalActiveSeconds > 0) ...[
                _CategoryDistributionBar(activity: activity),
                const SizedBox(height: 16),
                _TopAppsList(activity: activity),
                const SizedBox(height: 16),
              ] else
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.activity,
                          size: 32,
                          color: context.tokens.muted.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          enabled
                              ? 'Active computer time will appear here automatically'
                              : 'Background tracking is currently paused',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.tokens.muted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              _TrackingSettingsFooter(
                enabled: enabled,
                accent: accent,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  const _HeaderSummary({
    required this.activity,
    required this.enabled,
    required this.accent,
  });

  final DayLaptopActivity activity;
  final bool enabled;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final muted = context.tokens.muted;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Today',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: muted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    activity.formattedActiveTime,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: scheme.onSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (activity.totalIdleSeconds > 0) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        '(${activity.formattedIdleTime} idle)',
                        style: TextStyle(
                          fontSize: 12,
                          color: muted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: (enabled ? accent : muted).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (enabled ? accent : muted).withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: enabled ? accent : muted,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                enabled ? 'Tracking' : 'Paused',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: enabled ? accent : muted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryDistributionBar extends StatelessWidget {
  const _CategoryDistributionBar({required this.activity});

  final DayLaptopActivity activity;

  @override
  Widget build(BuildContext context) {
    final total = activity.totalActiveSeconds;
    if (total <= 0) return const SizedBox.shrink();

    final catMap = activity.categorySeconds;
    final entries = catMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: SizedBox(
            height: 10,
            child: Row(
              children: [
                for (final e in entries)
                  Expanded(
                    flex: e.value,
                    child: Container(
                      color: _categoryColor(e.key),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (final e in entries)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: _categoryColor(e.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '${_categoryLabel(e.key)} ${(e.value * 100 / total).round()}%',
                    style: TextStyle(
                      fontSize: 11,
                      color: context.tokens.muted,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _TopAppsList extends StatelessWidget {
  const _TopAppsList({required this.activity});

  final DayLaptopActivity activity;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final total = activity.totalActiveSeconds;
    final topApps = activity.apps.take(7).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Top Applications',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.tokens.muted,
          ),
        ),
        const SizedBox(height: 8),
        for (var i = 0; i < topApps.length; i++) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: _categoryColor(topApps[i].category).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    _categoryIcon(topApps[i].category),
                    size: 14,
                    color: _categoryColor(topApps[i].category),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topApps[i].displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: total > 0 ? (topApps[i].seconds / total) : 0,
                          minHeight: 3,
                          backgroundColor: scheme.outlineVariant.withValues(alpha: 0.15),
                          color: _categoryColor(topApps[i].category),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  topApps[i].formattedDuration,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: scheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _TrackingSettingsFooter extends StatelessWidget {
  const _TrackingSettingsFooter({
    required this.enabled,
    required this.accent,
  });

  final bool enabled;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final idleMin = LaptopActivityStore.idleThresholdMinutes();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: scheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  LucideIcons.shieldCheck,
                  size: 14,
                  color: accent,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Idle pause: ${idleMin}m • Low-RAM mode',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: context.tokens.muted,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              final next = !enabled;
              LaptopActivityStore.setEnabled(next);
              if (next) {
                WindowsActivityTracker.start();
              } else {
                WindowsActivityTracker.stop();
              }
            },
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                enabled ? 'Pause' : 'Resume',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: enabled ? scheme.error : accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
