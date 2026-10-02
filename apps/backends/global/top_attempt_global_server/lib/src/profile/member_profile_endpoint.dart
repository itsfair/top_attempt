import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Own person/profile endpoints of the global instance (replacing the
/// built-in Serverpod UserProfile feature, which is bypassed on purpose).
///
/// Data lives in the `member_profile` table; profile images are stored in
/// the RustFS bucket at `member_images/<authUserId>.jpg` (deterministic
/// name, one object per person, overwrite on change).
///
/// Birthday convention: values travel as UTC-midnight date sentinels (the
/// shared frontend sends `DateTime.utc(y, m, d)` explicitly); validation
/// is done against UTC calendar days.
class MemberProfileEndpoint extends Endpoint {
  static const String _storageId = 'public';
  static const String _memberImagesFolder = 'member_images';

  @override
  bool get requireLogin => true;

  /// Returns the signed-in user's own profile.
  ///
  /// Self-heals the sparse row if the registration hook missed it (this
  /// should not happen; the hook fires at registration).
  Future<MemberProfile> get(final Session session) async {
    final authUserId = session.authenticated!.authUserId;
    return _ownRow(session, authUserId);
  }

  /// Validates and saves the profile data of the signed-in user.
  ///
  /// Unlike the old flow there is no name mirror into the Serverpod
  /// UserProfile module — everything lives in `member_profile`.
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

  /// Stores the uploaded image at `member_images/<authUserId>.jpg`
  /// (deterministic, overwrites the previous object since every person
  /// owns exactly one image) and updates the profile's `imageUrl`.
  ///
  /// Uploads are expected to be JPEG (the shared frontend's image picker
  /// produces JPEG bytes only); no magic-byte detection — format
  /// extensions are a deliberate later extension (TODO).
  Future<MemberProfile> setUserImage(
    final Session session, {
    required final ByteData image,
  }) async {
    final authUserId = session.authenticated!.authUserId;
    final row = await _ownRow(session, authUserId);

    final path = _imagePath(authUserId);
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

  /// Deletes the stored object and clears the profile's `imageUrl`.
  Future<MemberProfile> removeUserImage(final Session session) async {
    final authUserId = session.authenticated!.authUserId;
    final row = await _ownRow(session, authUserId);

    if (row.imageUrl case final imageUrl? when imageUrl.isNotEmpty) {
      await session.storage.deleteFile(
        storageId: _storageId,
        path: _imagePath(authUserId),
      );
    }

    return MemberProfile.db.updateRow(
      session,
      row.copyWith(imageUrl: null),
    );
  }

  // -- Private helpers

  /// Row lookup by authUserId; inserts a sparse row (null data) if the
  /// hook missed it, using the built-in module profile's email when
  /// possible.
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

    final moduleProfile = await AuthServices.instance.userProfiles
        .maybeFindUserProfileByUserId(session, authUserId);
    final email = moduleProfile?.email;
    if (email == null || email.isEmpty) {
      throw UserAdminException(
        message: 'Kein Profil bzw. keine E-Mail für diesen Nutzer.',
      );
    }

    return MemberProfile.db.insertRow(
      session,
      MemberProfile(
        authUserId: authUserId,
        email: email,
      ),
    );
  }

  String _imagePath(final UuidValue authUserId) =>
      '$_memberImagesFolder/$authUserId.jpg';

  String _validateName(final String value, final String field) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 60) {
      throw UserAdminException(
        message: '$field muss zwischen 1 und 60 Zeichen lang sein.',
      );
    }
    return trimmed;
  }

  void _validateBirthday(final DateTime birthday) {
    // Calendar-day checks in UTC (birthdays arrive as UTC-midnight
    // sentinels; see AGENTS.md).
    final now = DateTime.timestamp();
    final today = DateTime.utc(now.year, now.month, now.day);
    if (!birthday.isBefore(today)) {
      throw UserAdminException(
        message: 'Der Geburtstag muss in der Vergangenheit liegen.',
      );
    }
    if (birthday.isBefore(DateTime.utc(1900))) {
      throw UserAdminException(
        message: 'Der Geburtstag ist unplausibel alt.',
      );
    }
  }
}
