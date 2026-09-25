import 'dart:convert' as convert;

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:serverpod/serverpod.dart';

/// Crypto helpers for site setup secrets.
///
/// The one time password is stored as a SHA-256 hash (sufficient preimage
/// strength for a high-entropy random token). The local admin's initial
/// password is stored encrypted at rest (AES-GCM, key derived from a secret
/// in `passwords.yaml`) and remains readable until the first successful
/// connection of the local instance transfers it to the site; after that it
/// must be cleared (`Site.initialAdminPasswordEncrypted = null`).
class SiteSetupCrypto {
  /// Key under `config/passwords.yaml` (development stage) whose value seeds
  /// the AES key. The file is not version controlled.
  static const String _encryptionKeySecretName = 'siteSetupEncryptionKey';

  static const String _cipherPayloadVersionPrefix = 'v1';

  /// SHA-256 hex digest of the one-time password for verification during
  /// enrollment.
  static String oneTimePasswordHash(final String oneTimePassword) {
    return crypto.sha256
        .convert(convert.utf8.encode(oneTimePassword))
        .toString();
  }

  /// Encrypts [plaintext] with AES-GCM (256 bit), payload format:
  /// `v1:<base64(nonce)>.<base64(cipherText)>.<base64(mac)>`.
  static Future<String> encrypt({
    required final Session session,
    required final String plaintext,
  }) async {
    final algorithm = AesGcm.with256bits();
    final nonce = algorithm.newNonce();
    final secretBox = await algorithm.encrypt(
      convert.utf8.encode(plaintext),
      secretKey: _secretKey(session),
      nonce: nonce,
    );

    return [
      _cipherPayloadVersionPrefix,
      convert.base64.encode(secretBox.nonce),
      convert.base64.encode(secretBox.cipherText),
      convert.base64.encode(secretBox.mac.bytes),
    ].join('.');
  }

  /// Decrypts a payload as produced by [encrypt].
  static Future<String> decrypt({
    required final Session session,
    required final String ciphertext,
  }) async {
    final parts = ciphertext.split('.');
    if (parts.length != 4 || parts[0] != _cipherPayloadVersionPrefix) {
      throw ArgumentError.value(
        ciphertext,
        'ciphertext',
        'Unexpected payload format '
            '(expected "$_cipherPayloadVersionPrefix:<nonce>.<cipher>.<mac>")',
      );
    }

    final algorithm = AesGcm.with256bits();
    final secretBox = SecretBox(
      convert.base64.decode(parts[2]),
      nonce: convert.base64.decode(parts[1]),
      mac: Mac(convert.base64.decode(parts[3])),
    );

    final clearText = await algorithm.decrypt(
      secretBox,
      secretKey: _secretKey(session),
    );
    return convert.utf8.decode(clearText);
  }

  static SecretKeyData _secretKey(final Session session) {
    final secret = session.passwords[_encryptionKeySecretName];
    if (secret == null || secret.isEmpty) {
      throw StateError(
        'Missing password key "$_encryptionKeySecretName" in '
        'config/passwords.yaml (SiteSetupCrypto requires it to encrypt the '
        'initial admin password).',
      );
    }

    final secretBytes = convert.utf8.encode(secret);
    final hashBytes = crypto.sha256.convert(secretBytes).bytes;
    return SecretKeyData(hashBytes);
  }
}
