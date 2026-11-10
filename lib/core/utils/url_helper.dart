import 'package:url_launcher/url_launcher.dart';

Future<void> openUrl(String raw) async {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return;
  final uri = Uri.tryParse(
    trimmed.startsWith('http://') || trimmed.startsWith('https://')
        ? trimmed
        : 'https://$trimmed',
  );
  if (uri != null) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
