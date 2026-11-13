import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:streak/core/database/local_store.dart';
import 'package:streak/core/extensions/date_extensions.dart';

enum AppCategory {
  development,
  browsing,
  productivity,
  entertainment,
  system,
  other,
}

class AppUsageEntry {
  const AppUsageEntry({
    required this.executable,
    required this.displayName,
    required this.category,
    required this.seconds,
  });

  final String executable;
  final String displayName;
  final AppCategory category;
  final int seconds;

  String get formattedDuration {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

class DayLaptopActivity {
  const DayLaptopActivity({
    required this.date,
    required this.totalActiveSeconds,
    required this.totalIdleSeconds,
    required this.apps,
  });

  final String date;
  final int totalActiveSeconds;
  final int totalIdleSeconds;
  final List<AppUsageEntry> apps;

  String get formattedActiveTime {
    final hours = totalActiveSeconds ~/ 3600;
    final minutes = (totalActiveSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedIdleTime {
    final hours = totalIdleSeconds ~/ 3600;
    final minutes = (totalIdleSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<AppCategory, int> get categorySeconds {
    final map = <AppCategory, int>{};
    for (final app in apps) {
      map[app.category] = (map[app.category] ?? 0) + app.seconds;
    }
    return map;
  }
}

class AppClassifier {
  const AppClassifier._();

  static ({String name, AppCategory category}) classify(String executable) {
    final exe = executable.toLowerCase().trim();
    if (exe.isEmpty) {
      return (name: 'Unknown', category: AppCategory.other);
    }

    // Development
    if (exe.contains('code') || exe == 'devenv.exe') {
      return (name: 'Visual Studio Code', category: AppCategory.development);
    }
    if (exe.contains('idea') || exe.contains('studio64')) {
      return (name: 'Android Studio / IntelliJ', category: AppCategory.development);
    }
    if (exe.contains('pycharm') ||
        exe.contains('webstorm') ||
        exe.contains('clion') ||
        exe.contains('rider')) {
      return (name: 'JetBrains IDE', category: AppCategory.development);
    }
    if (exe.contains('terminal') ||
        exe == 'cmd.exe' ||
        exe == 'powershell.exe' ||
        exe == 'pwsh.exe') {
      return (name: 'Terminal', category: AppCategory.development);
    }
    if (exe.contains('git') ||
        exe.contains('sublime') ||
        exe.contains('neovim') ||
        exe.contains('vim')) {
      return (name: 'Dev Tools', category: AppCategory.development);
    }

    // Browsing
    if (exe.contains('chrome')) {
      return (name: 'Google Chrome', category: AppCategory.browsing);
    }
    if (exe.contains('msedge') || exe.contains('edge')) {
      return (name: 'Microsoft Edge', category: AppCategory.browsing);
    }
    if (exe.contains('firefox')) {
      return (name: 'Mozilla Firefox', category: AppCategory.browsing);
    }
    if (exe.contains('brave')) {
      return (name: 'Brave Browser', category: AppCategory.browsing);
    }
    if (exe.contains('opera') || exe.contains('vivaldi') || exe.contains('arc')) {
      return (name: 'Web Browser', category: AppCategory.browsing);
    }

    // Productivity
    if (exe.contains('notion')) {
      return (name: 'Notion', category: AppCategory.productivity);
    }
    if (exe.contains('obsidian')) {
      return (name: 'Obsidian', category: AppCategory.productivity);
    }
    if (exe.contains('word') || exe == 'winword.exe') {
      return (name: 'Microsoft Word', category: AppCategory.productivity);
    }
    if (exe.contains('excel')) {
      return (name: 'Microsoft Excel', category: AppCategory.productivity);
    }
    if (exe.contains('powerpnt') || exe.contains('powerpoint')) {
      return (name: 'Microsoft PowerPoint', category: AppCategory.productivity);
    }
    if (exe.contains('slack')) {
      return (name: 'Slack', category: AppCategory.productivity);
    }
    if (exe.contains('teams')) {
      return (name: 'Microsoft Teams', category: AppCategory.productivity);
    }
    if (exe.contains('streak')) {
      return (name: 'Habito Habit Tracker', category: AppCategory.productivity);
    }

    // Entertainment & Media
    if (exe.contains('spotify')) {
      return (name: 'Spotify', category: AppCategory.entertainment);
    }
    if (exe.contains('discord')) {
      return (name: 'Discord', category: AppCategory.entertainment);
    }
    if (exe.contains('steam')) {
      return (name: 'Steam', category: AppCategory.entertainment);
    }
    if (exe.contains('vlc') || exe.contains('media') || exe.contains('netflix')) {
      return (name: 'Media Player', category: AppCategory.entertainment);
    }

    // System
    if (exe == 'explorer.exe') {
      return (name: 'Windows Explorer', category: AppCategory.system);
    }
    if (exe == 'taskmgr.exe') {
      return (name: 'Task Manager', category: AppCategory.system);
    }

    final clean =
        exe.replaceAll('.exe', '').replaceAll('_', ' ').replaceAll('-', ' ');
    final capitalized = clean
        .split(' ')
        .map((s) => s.isEmpty ? '' : '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
    return (name: capitalized, category: AppCategory.other);
  }
}

class LaptopActivityStore {
  const LaptopActivityStore._();

  static const _enabledKey = 'laptop_tracking_enabled';
  static const _idleMinutesKey = 'laptop_idle_threshold_minutes';

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  // In-memory buffer to minimize disk I/O
  static String? _cachedDate;
  static int _cachedActive = 0;
  static int _cachedIdle = 0;
  static final Map<String, int> _cachedApps = {};
  static bool _dirty = false;

  static bool isEnabled() => LocalStore.setting<bool>(_enabledKey, true);

  static Future<void> setEnabled(bool enabled) async {
    await LocalStore.writeSetting(_enabledKey, enabled);
    changeNotifier.value++;
  }

  static int idleThresholdMinutes() =>
      LocalStore.setting<int>(_idleMinutesKey, 5);

  static Future<void> setIdleThresholdMinutes(int minutes) async {
    await LocalStore.writeSetting(_idleMinutesKey, minutes);
    changeNotifier.value++;
  }

  static String _todayKey() => AppClock.today().dayKey;

  static void _ensureCacheLoaded(String dateKey) {
    if (_cachedDate == dateKey) return;
    if (_dirty && _cachedDate != null) {
      flushSync();
    }
    _cachedDate = dateKey;
    _cachedApps.clear();
    final raw = LocalStore.setting<String>('laptop_activity_$dateKey', '');
    if (raw.isNotEmpty) {
      try {
        final map = jsonDecode(raw) as Map<String, dynamic>;
        _cachedActive = (map['active'] as num?)?.toInt() ?? 0;
        _cachedIdle = (map['idle'] as num?)?.toInt() ?? 0;
        final appsMap = map['apps'] as Map<String, dynamic>? ?? {};
        for (final entry in appsMap.entries) {
          if (entry.value is num) {
            _cachedApps[entry.key] = (entry.value as num).toInt();
          }
        }
      } catch (_) {
        _cachedActive = 0;
        _cachedIdle = 0;
      }
    } else {
      _cachedActive = 0;
      _cachedIdle = 0;
    }
    _dirty = false;
  }

  static void recordActiveUsage(String executable, int seconds) {
    if (!isEnabled() || seconds <= 0) return;
    final today = _todayKey();
    _ensureCacheLoaded(today);

    final exe = executable.toLowerCase().trim();
    _cachedActive += seconds;
    _cachedApps[exe] = (_cachedApps[exe] ?? 0) + seconds;
    _dirty = true;
    changeNotifier.value++;
  }

  static void recordIdle(int seconds) {
    if (!isEnabled() || seconds <= 0) return;
    final today = _todayKey();
    _ensureCacheLoaded(today);

    _cachedIdle += seconds;
    _dirty = true;
    changeNotifier.value++;
  }

  static void flushSync() {
    if (!_dirty || _cachedDate == null) return;
    final data = jsonEncode({
      'active': _cachedActive,
      'idle': _cachedIdle,
      'apps': _cachedApps,
    });
    LocalStore.writeSetting('laptop_activity_$_cachedDate', data);
    _dirty = false;
  }

  static DayLaptopActivity getTodayActivity() {
    final today = _todayKey();
    _ensureCacheLoaded(today);

    final entries = <AppUsageEntry>[];
    for (final entry in _cachedApps.entries) {
      final classified = AppClassifier.classify(entry.key);
      entries.add(AppUsageEntry(
        executable: entry.key,
        displayName: classified.name,
        category: classified.category,
        seconds: entry.value,
      ));
    }

    entries.sort((a, b) => b.seconds.compareTo(a.seconds));

    return DayLaptopActivity(
      date: today,
      totalActiveSeconds: _cachedActive,
      totalIdleSeconds: _cachedIdle,
      apps: entries,
    );
  }
}
