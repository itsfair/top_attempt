import 'dart:io';

import 'package:yaml/yaml.dart';

/// Reads the `siteConnection:` block of the local backend's
/// `config/<runMode>.yaml`.
///
/// Dev example:
/// ```yaml
/// siteConnection:
///   globalApiUrl: http://localhost:8080
/// ```
/// (Use the LAN IP instead of localhost when the setup mask runs on a
/// device.)
class SiteConnectionConfig {
  /// Reads the global API URL for the given run mode directly from the
  /// config file (mirrors the `rustFS:` reader in `lib/server.dart`).
  static String? globalApiUrlFor(final String runMode) {
    final file = File('config/$runMode.yaml');
    if (!file.existsSync()) return null;
    final doc = loadYaml(file.readAsStringSync());
    final block = doc is YamlMap ? doc['siteConnection'] : null;
    if (block is! YamlMap) return null;
    final url = block['globalApiUrl']?.toString();
    if (url == null || url.isEmpty) return null;
    return url;
  }
}
