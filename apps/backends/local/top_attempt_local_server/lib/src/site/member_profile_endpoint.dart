import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Own person/profile endpoints of the local instance — mirror of the
/// global `memberProfile` endpoint (same model shape, see AGENTS.md).
///
/// The `member_profile` table is the local person directory; rows exist
/// for every person of the site, and persons WITH a local login
/// (site admin / staff) carry the `authUserId` link. Profiles are edited
/// globally only (sync rule) — these endpoints exist for locally
/// logged-in persons to READ their mirrored data (and, if ever desired,
/// write — same conventions as global: deterministic image name,
/// JPEG-only, UTC-midnight birthday sentinels).
class MemberProfileEndpoint extends Endpoint {
  static const String _storageId = 'public';
  static const String _memberImagesFolder = 'member_images';

  @override
  bool get requireLogin => true;

  /// Returns the signed-in person's profile (lookup via the local login →
  /// `authUserId` link).
  ///
  /// Self-heals a missing sparse row using the local email account's
  /// address (enrollment normally creates the copy including the email).
  Future<MemberProfile> get(final Session session) async {
    final authUserId = session.authenticated!.authUserId;
    return _ownRow(session, authUserId);
  }

  /// Validates and saves the locally mirrored profile data of the
  /// signed-in person. NOTE: profiles are meant to be edited globally
  /// only (sync rule) — local writes overwrite the mirror until the next
  /// sync brings global state back.
  Future<MemberProfile> save(
    final Session session, {
    required final String firstName,
    required final String lastName,
    required final DateTime birthday,
  }) async {
    final authUserId = session.authenticated!.authUserId;
    final first = _validateName(firstName, 'firstName');
    final last = _validateName(lastName, 'lastName');
    _validateBirthday(birthday);

    final row = await _ownRow(session, authUserId);
    return MemberProfile.db.updateRow(
      session,
      row.copyWith(
        firstName: first,
        lastName: last,
        birthday: birthday,
      ),
    );
  }

  /// Stores the uploaded image at
  /// `member_images/<globalAuthUserId>.jpg` — the deterministic name
  /// shared with the global instance (same person id; parity by
  /// construction).
  Future<MemberProfile> setUserImage(
    final Session session, {
    required final ByteData image,
  }) async {
    var row = await _ownRow(session, session.authenticated!.authUserId);

    // The image name is derived from the person's global id.
    final path = _imagePath(row.globalAuthUserId);
    await session.storage.storeFile(
      storageId: _storageId,
      path: path,
      byteData: image,
    );
    final url = await session.storage.publicDownloadUrl(
      storageId: _storageId,
      path: path,
    );

    return MemberProfile.db.updateRow(
      session,
      row.copyWith(imageUrl: url.toString()),
    );
  }

  /// Deletes the locally stored object and clears `imageUrl` (NOTE: the
  /// global image remains its source of truth; the next sync restores
  /// the mirror).
  Future<MemberProfile> removeUserImage(final Session session) async {
    var row = await _ownRow(session, session.authenticated!.authUserId);

    if (row.imageUrl case final imageUrl? when imageUrl.isNotEmpty) {
      await session.storage.deleteFile(
        storageId: _storageId,
        path: _imagePath(row.globalAuthUserId),
      );
    }

    return MemberProfile.db.updateRow(
      session,
      row.copyWith(imageUrl: null),
    );
  }

  // -- Private helpers

  Future<MemberProfile> _ownRow(
    final Session session,
    final UuidValue authUserId,
  ) async {
    final existing = await MemberProfile.db.findFirstRow(
      session,
      where: (t) => t.authUserId.equals(authUserId),
    );
    if (existing != null) {
      return existing;
    }

    // No guesswork: the exchange key (globalAuthUserId) cannot be derived
    // from a local login alone, and enrollment always creates the copy
    // with the correct global id. So a missing row here is a real error —
    // fail loudly instead of writing a wrong exchange key.
    throw SiteSetupException(
      message:
          'member_profile fehlt für diese Anmeldung — '
          'bitte Einrichtung (Setup) wiederholen.',
    );
  }

  String _imagePath(final UuidValue globalAuthUserId) =>
      '$_memberImagesFolder/$globalAuthUserId.jpg';

  String _validateName(final String value, final String field) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 60) {
      throw SiteSetupException(
        message: '$field muss zwischen 1 und 60 Zeichen lang sein.',
      );
    }
    return trimmed;
  }

  void _validateBirthday(final DateTime birthday) {
    // Calendar-day checks in UTC (sentinel convention, like global).
    final now = DateTime.timestamp();
    final today = DateTime.utc(now.year, now.month, now.day);
    if (!birthday.isBefore(today)) {
      throw SiteSetupException(
        message: 'Der Geburtstag muss in der Vergangenheit liegen.',
      );
    }
    if (birthday.isBefore(DateTime.utc(1900))) {
      throw SiteSetupException(
        message: 'Der Geburtstag ist unplausibel alt.',
      );
    }
  }
}
