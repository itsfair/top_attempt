import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_cloud_storage_rustfs/serverpod_cloud_storage_rustfs.dart';
import 'package:yaml/yaml.dart';

import 'src/generated/endpoints.dart';
import 'src/generated/protocol.dart';
import 'src/site/global_site_connection.dart';
import 'src/web/routes/app_config_route.dart';
import 'src/web/routes/root.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Initialize authentication services for the server.
  // Token managers will be used to validate and issue authentication keys,
  // and the identity providers will be the authentication options available for users.
  pod.initializeAuthServices(
    tokenManagerBuilders: [
      // Use JWT for authentication keys towards the server.
      JwtConfigFromPasswords(),
    ],
    identityProviderBuilders: [
      // Configure the email identity provider for email/password authentication.
      EmailIdpConfigFromPasswords(
        sendRegistrationVerificationCode: _sendRegistrationCode,
        sendPasswordResetVerificationCode: _sendPasswordResetCode,
      ),
    ],
  );

  // Register the RustFS cloud storage (S3-compatible) as the 'public' file
  // storage, replacing the database-backed default. The endpoint is read
  // from the stage specific config file (`rustFS` block, see
  // config/development.yaml). Do not set `publicHost` - the adapter v1.0.0
  // builds broken URLs in that case (see AGENTS.md).
  pod.addCloudStorage(
    RustFsCloudStorage(
      serverpod: pod,
      storageId: 'public',
      public: true,
      bucket: 'top-attempt',
      baseUri: _rustFsBaseUri(pod),
    ),
  );

  // Setup a default page at the web root.
  // These are used by the default page.
  pod.webServer.addRoute(RootRoute(), '/');
  pod.webServer.addRoute(RootRoute(), '/index.html');

  // Serve all files in the web/static relative directory under /.
  // These are used by the default web page.
  final root = Directory(Uri(path: 'web/static').toFilePath());
  pod.webServer.addRoute(StaticRoute.directory(root));

  // Setup the app config route.
  // We build this configuration based on the servers api url and serve it to
  // the flutter app.
  pod.webServer.addRoute(
    AppConfigRoute(apiConfig: pod.config.apiServer),
    '/app/assets/assets/config.json',
  );

  // Checks if the flutter web app has been built and serves it if it has.
  final appDir = Directory(Uri(path: 'web/app').toFilePath());
  if (appDir.existsSync()) {
    // Serve the flutter web app under the /app path.
    pod.webServer.addRoute(
      FlutterRoute(
        Directory(
          Uri(path: 'web/app').toFilePath(),
        ),
      ),
      '/app',
    );
  } else {
    // If the flutter web app has not been built, serve the build app page.
    pod.webServer.addRoute(
      StaticRoute.file(
        File(
          Uri(path: 'web/pages/build_flutter_app.html').toFilePath(),
        ),
      ),
      '/app/**',
    );
  }

  // Start the server.
  await pod.start();

  // Start the site connection worker (no-op until the local instance is
  // enrolled at a global instance; the worker then connects on every start).
  await GlobalSiteConnection.instance.start();
}

/// Reads the RustFS endpoint (scheme/host/port) from the stage specific
/// config file (top level `rustFS` block). Falls back to the local
/// docker-compose default when the file or block is missing.
Uri _rustFsBaseUri(Serverpod pod) {
  const defaultUri = 'http://localhost:9001';

  final file = File('config/${pod.config.runMode}.yaml');
  if (!file.existsSync()) return Uri.parse(defaultUri);

  final doc = loadYaml(file.readAsStringSync());
  final rustFs = doc is YamlMap ? doc['rustFS'] : null;
  if (rustFs is! YamlMap) return Uri.parse(defaultUri);

  return Uri(
    scheme: rustFs['scheme']?.toString() ?? 'http',
    host: rustFs['host']?.toString() ?? 'localhost',
    port: int.tryParse(rustFs['port']?.toString() ?? '') ?? 9001,
  );
}

void _sendRegistrationCode(
  Session session, {
  required String email,
  required UuidValue accountRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Registration code ($email): $verificationCode');
}

void _sendPasswordResetCode(
  Session session, {
  required String email,
  required UuidValue passwordResetRequestId,
  required String verificationCode,
  required Transaction? transaction,
}) {
  // NOTE: Here you call your mail service to send the verification code to
  // the user. For testing, we will just log the verification code.
  session.log('[EmailIdp] Password reset code ($email): $verificationCode');
}
