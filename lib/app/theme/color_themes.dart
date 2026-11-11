import 'package:flutter/material.dart';

class ThemeColors {
  const ThemeColors({
    required this.background,
    required this.card,
    required this.high,
    required this.highest,
    required this.outline,
    required this.text,
    required this.muted,
    required this.accent,
    required this.success,
    required this.warning,
    required this.danger,
    required this.info,
  });

  final Color background;
  final Color card;
  final Color high;
  final Color highest;
  final Color outline;
  final Color text;
  final Color muted;
  final Color accent;
  final Color success;
  final Color warning;
  final Color danger;
  final Color info;

  static const keys = [
    'background',
    'card',
    'text',
    'accent',
    'success',
    'warning',
    'danger',
    'info',
  ];

  Color operator [](String key) => switch (key) {
        'background' => background,
        'card' => card,
        'text' => text,
        'accent' => accent,
        'success' => success,
        'warning' => warning,
        'danger' => danger,
        _ => info,
      };

  Map<String, int> toMap() => {
        for (final key in keys) key: this[key].toARGB32(),
      };

  factory ThemeColors.fromMap(Map<String, dynamic> map, ThemeColors base) {
    Color pick(String key) =>
        map[key] is int ? Color(map[key] as int) : base[key];
    final card = pick('card');
    final text = pick('text');
    return ThemeColors(
      background: pick('background'),
      card: card,
      high: Color.lerp(card, text, 0.08)!,
      highest: Color.lerp(card, text, 0.18)!,
      outline: Color.lerp(card, text, 0.24)!,
      text: text,
      muted: Color.lerp(text, card, 0.38)!,
      accent: pick('accent'),
      success: pick('success'),
      warning: pick('warning'),
      danger: pick('danger'),
      info: pick('info'),
    );
  }
}

class ColorTheme {
  const ColorTheme({
    required this.id,
    required this.name,
    required this.light,
    required this.dark,
  });

  final String id;
  final String name;
  final ThemeColors light;
  final ThemeColors dark;

  ThemeColors of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  static ColorTheme? byId(String id) {
    for (final theme in all) {
      if (theme.id == id) return theme;
    }
    return null;
  }

  static const customId = 'custom';

  static ColorTheme? custom(Map<String, dynamic> saved) {
    if (saved.isEmpty) return null;
    ThemeColors side(String key, ThemeColors base) => ThemeColors.fromMap(
          saved[key] is Map
              ? Map<String, dynamic>.from(saved[key] as Map)
              : const {},
          base,
        );
    return ColorTheme(
      id: customId,
      name: '',
      light: side('light', catppuccin.light),
      dark: side('dark', catppuccin.dark),
    );
  }

  static const all = [
    antigravity,
    claude,
    retro,
    vivid,
    catppuccin,
    tokyoNight,
    nord,
    gruvbox,
    rosePine,
  ];

  static const antigravity = ColorTheme(
    id: 'antigravity',
    name: 'Antigravity Slate',
    light: ThemeColors(
      background: Color(0xFFEBECEF),
      card: Color(0xFFF7F8FA),
      high: Color(0xFFE2E4E9),
      highest: Color(0xFFD6D9E1),
      outline: Color(0xFFC7CBD6),
      text: Color(0xFF22252C),
      muted: Color(0xFF646876),
      accent: Color(0xFF7C3AED),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      danger: Color(0xFFEF4444),
      info: Color(0xFF3B82F6),
    ),
    dark: ThemeColors(
      background: Color(0xFF141519),
      card: Color(0xFF1C1D24),
      high: Color(0xFF252731),
      highest: Color(0xFF323542),
      outline: Color(0xFF2E313E),
      text: Color(0xFFE2E4EB),
      muted: Color(0xFF8F93A3),
      accent: Color(0xFF8B5CF6),
      success: Color(0xFF34D399),
      warning: Color(0xFFFBBF24),
      danger: Color(0xFFF87171),
      info: Color(0xFF60A5FA),
    ),
  );

  static const claude = ColorTheme(
    id: 'claude',
    name: 'Claude Warm',
    light: ThemeColors(
      background: Color(0xFFF4F0E8),
      card: Color(0xFFFAF7F2),
      high: Color(0xFFEBE6DC),
      highest: Color(0xFFDDD7CC),
      outline: Color(0xFFCFC8BB),
      text: Color(0xFF3A352F),
      muted: Color(0xFF7C746B),
      accent: Color(0xFFD97706),
      success: Color(0xFF65A30D),
      warning: Color(0xFFD97706),
      danger: Color(0xFFDC2626),
      info: Color(0xFF2563EB),
    ),
    dark: ThemeColors(
      background: Color(0xFF1D1B18),
      card: Color(0xFF262420),
      high: Color(0xFF322E29),
      highest: Color(0xFF403C35),
      outline: Color(0xFF3A352F),
      text: Color(0xFFEDE9E2),
      muted: Color(0xFF9E978E),
      accent: Color(0xFFF59E0B),
      success: Color(0xFFA3E635),
      warning: Color(0xFFFBBF24),
      danger: Color(0xFFF87171),
      info: Color(0xFF60A5FA),
    ),
  );

  static const retro = ColorTheme(
    id: 'retro',
    name: 'Retro Amber',
    light: ThemeColors(
      background: Color(0xFFECEBE6),
      card: Color(0xFFF5F4EE),
      high: Color(0xFFE1DFD7),
      highest: Color(0xFFD3D0C5),
      outline: Color(0xFFC4C0B3),
      text: Color(0xFF2D2B26),
      muted: Color(0xFF6E6B62),
      accent: Color(0xFFB45309),
      success: Color(0xFF4D7C0F),
      warning: Color(0xFFB45309),
      danger: Color(0xFFB91C1C),
      info: Color(0xFF0369A1),
    ),
    dark: ThemeColors(
      background: Color(0xFF151618),
      card: Color(0xFF1D1F23),
      high: Color(0xFF272A30),
      highest: Color(0xFF343840),
      outline: Color(0xFF30343C),
      text: Color(0xFFE0E2E8),
      muted: Color(0xFF8B8F9B),
      accent: Color(0xFFF59E0B),
      success: Color(0xFF84CC16),
      warning: Color(0xFFFBBF24),
      danger: Color(0xFFEF4444),
      info: Color(0xFF38BDF8),
    ),
  );

  static const vivid = ColorTheme(
    id: 'vivid',
    name: 'Vivid Night',
    light: ThemeColors(
      background: Color(0xFFE9ECF4),
      card: Color(0xFFF5F7FD),
      high: Color(0xFFDFE3EF),
      highest: Color(0xFFD1D6E6),
      outline: Color(0xFFC0C7DC),
      text: Color(0xFF1E2438),
      muted: Color(0xFF5D6580),
      accent: Color(0xFF4F46E5),
      success: Color(0xFF059669),
      warning: Color(0xFFD97706),
      danger: Color(0xFFDC2626),
      info: Color(0xFF0284C7),
    ),
    dark: ThemeColors(
      background: Color(0xFF0F111A),
      card: Color(0xFF171926),
      high: Color(0xFF202334),
      highest: Color(0xFF2C3047),
      outline: Color(0xFF2B2E44),
      text: Color(0xFFE6EAF8),
      muted: Color(0xFF8E96B5),
      accent: Color(0xFF6366F1),
      success: Color(0xFF10B981),
      warning: Color(0xFFF59E0B),
      danger: Color(0xFFF43F5E),
      info: Color(0xFF06B6D4),
    ),
  );

  static const catppuccin = ColorTheme(
    id: 'catppuccin',
    name: 'Catppuccin',
    light: ThemeColors(
      background: Color(0xFFE6E9EF),
      card: Color(0xFFEFF1F5),
      high: Color(0xFFDCE0E8),
      highest: Color(0xFFCCD0DA),
      outline: Color(0xFFBCC0CC),
      text: Color(0xFF4C4F69),
      muted: Color(0xFF6C6F85),
      accent: Color(0xFF8839EF),
      success: Color(0xFF40A02B),
      warning: Color(0xFFDF8E1D),
      danger: Color(0xFFD20F39),
      info: Color(0xFF1E66F5),
    ),
    dark: ThemeColors(
      background: Color(0xFF181825),
      card: Color(0xFF1E1E2E),
      high: Color(0xFF313244),
      highest: Color(0xFF45475A),
      outline: Color(0xFF45475A),
      text: Color(0xFFCDD6F4),
      muted: Color(0xFFA6ADC8),
      accent: Color(0xFFCBA6F7),
      success: Color(0xFFA6E3A1),
      warning: Color(0xFFF9E2AF),
      danger: Color(0xFFF38BA8),
      info: Color(0xFF89B4FA),
    ),
  );

  static const tokyoNight = ColorTheme(
    id: 'tokyo_night',
    name: 'Tokyo Night',
    light: ThemeColors(
      background: Color(0xFFD0D5E3),
      card: Color(0xFFE1E2E7),
      high: Color(0xFFC4C8DA),
      highest: Color(0xFFB7BCD3),
      outline: Color(0xFFA8AECB),
      text: Color(0xFF3760BF),
      muted: Color(0xFF6172B0),
      accent: Color(0xFF2E7DE9),
      success: Color(0xFF587539),
      warning: Color(0xFF8C6C3E),
      danger: Color(0xFFF52A65),
      info: Color(0xFF007197),
    ),
    dark: ThemeColors(
      background: Color(0xFF16161E),
      card: Color(0xFF1A1B26),
      high: Color(0xFF292E42),
      highest: Color(0xFF3B4261),
      outline: Color(0xFF3B4261),
      text: Color(0xFFC0CAF5),
      muted: Color(0xFF737AA2),
      accent: Color(0xFF7AA2F7),
      success: Color(0xFF9ECE6A),
      warning: Color(0xFFE0AF68),
      danger: Color(0xFFF7768E),
      info: Color(0xFF7DCFFF),
    ),
  );

  static const nord = ColorTheme(
    id: 'nord',
    name: 'Nord',
    light: ThemeColors(
      background: Color(0xFFD8DEE9),
      card: Color(0xFFECEFF4),
      high: Color(0xFFE5E9F0),
      highest: Color(0xFFC0C8D6),
      outline: Color(0xFFB4BED0),
      text: Color(0xFF2E3440),
      muted: Color(0xFF4C566A),
      accent: Color(0xFF4C6E9A),
      success: Color(0xFF6A8A50),
      warning: Color(0xFFD08770),
      danger: Color(0xFFBF616A),
      info: Color(0xFF5E81AC),
    ),
    dark: ThemeColors(
      background: Color(0xFF242933),
      card: Color(0xFF2E3440),
      high: Color(0xFF3B4252),
      highest: Color(0xFF4C566A),
      outline: Color(0xFF4C566A),
      text: Color(0xFFECEFF4),
      muted: Color(0xFFB4BCCB),
      accent: Color(0xFF88C0D0),
      success: Color(0xFFA3BE8C),
      warning: Color(0xFFEBCB8B),
      danger: Color(0xFFBF616A),
      info: Color(0xFF81A1C1),
    ),
  );

  static const gruvbox = ColorTheme(
    id: 'gruvbox',
    name: 'Gruvbox',
    light: ThemeColors(
      background: Color(0xFFF2E5BC),
      card: Color(0xFFFBF1C7),
      high: Color(0xFFEBDBB2),
      highest: Color(0xFFD5C4A1),
      outline: Color(0xFFD5C4A1),
      text: Color(0xFF3C3836),
      muted: Color(0xFF7C6F64),
      accent: Color(0xFFAF3A03),
      success: Color(0xFF79740E),
      warning: Color(0xFFB57614),
      danger: Color(0xFF9D0006),
      info: Color(0xFF076678),
    ),
    dark: ThemeColors(
      background: Color(0xFF1D2021),
      card: Color(0xFF282828),
      high: Color(0xFF3C3836),
      highest: Color(0xFF504945),
      outline: Color(0xFF504945),
      text: Color(0xFFEBDBB2),
      muted: Color(0xFFA89984),
      accent: Color(0xFFFE8019),
      success: Color(0xFFB8BB26),
      warning: Color(0xFFFABD2F),
      danger: Color(0xFFFB4934),
      info: Color(0xFF83A598),
    ),
  );

  static const rosePine = ColorTheme(
    id: 'rose_pine',
    name: 'Rosé Pine',
    light: ThemeColors(
      background: Color(0xFFFAF4ED),
      card: Color(0xFFFFFAF3),
      high: Color(0xFFF2E9E1),
      highest: Color(0xFFDFDAD9),
      outline: Color(0xFFDFDAD9),
      text: Color(0xFF575279),
      muted: Color(0xFF797593),
      accent: Color(0xFF907AA9),
      success: Color(0xFF56949F),
      warning: Color(0xFFEA9D34),
      danger: Color(0xFFB4637A),
      info: Color(0xFF286983),
    ),
    dark: ThemeColors(
      background: Color(0xFF191724),
      card: Color(0xFF1F1D2E),
      high: Color(0xFF26233A),
      highest: Color(0xFF403D52),
      outline: Color(0xFF403D52),
      text: Color(0xFFE0DEF4),
      muted: Color(0xFF908CAA),
      accent: Color(0xFFC4A7E7),
      success: Color(0xFF9CCFD8),
      warning: Color(0xFFF6C177),
      danger: Color(0xFFEB6F92),
      info: Color(0xFFEBBCBA),
    ),
  );
}
