import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

import '../generated/protocol.dart';

/// Endpoint for the user's own profile details (first name, last name and
/// birthday). Email, user id and the profile image are mirrored from the
/// global instance (enrollment/sync) and not editable here.
class ProfileDetailsEndpoint extends Endpoint {
  @override
  bool get requireLogin => true;

  /// Returns the profile details of the signed-in user, or null if they have
  /// never been saved yet.
  Future<ProfileDetails?> get(Session session) async {
    return _detailsForAuthenticatedUser(session);
  }

  /// Validates and saves the profile details of the signed-in user.
  /// The name is also written to the built-in user profile so that other
  /// parts of the system see a consistent full name.
  Future<ProfileDetails> save(
    Session session, {
    required String firstName,
    required String lastName,
    required DateTime birthday,
  }) async {
    final membership = await _membershipForAuthenticatedUser(session);
    if (membership == null) {
      throw ArgumentError('The signed-in user has no membership row.');
    }

    final first = _validateName(firstName, 'firstName');
    final last = _validateName(lastName, 'lastName');
    // Birthdays are date-only values: normalize to UTC midnight so that
    // no timezone offset (client local -> wire UTC -> DB) can shift the
    // calendar day. See AGENTS.md ("Birthday as UTC-midnight date
    // sentinel").
    final normalizedBirthday = DateTime.utc(
      birthday.year,
      birthday.month,
      birthday.day,
    );
    _validateBirthday(normalizedBirthday);

    await AuthServices.instance.userProfiles.changeFullName(
      session,
      membership.localAuthUserId!,
      '$first $last',
    );

    final existing = await ProfileDetails.db.findFirstRow(
      session,
      where: (t) => t.membershipId.equals(membership.id!),
    );

    if (existing != null) {
      existing
        ..firstName = first
        ..lastName = last
        ..birthday = normalizedBirthday;
      return ProfileDetails.db.updateRow(session, existing);
    }

    return ProfileDetails.db.insertRow(
      session,
      ProfileDetails(
        firstName: first,
        lastName: last,
        birthday: normalizedBirthday,
        membershipId: membership.id!,
      ),
    );
  }

  /// The signed-in user (local login) can only be a staff/siteAdmin —
  /// plain members have no local login. The person data is resolved via
  /// the membership row; null when no membership exists (yet).
  Future<Membership?> _membershipForAuthenticatedUser(Session session) async {
    final authUserId = session.authenticated!.authUserId;
    return Membership.db.findFirstRow(
      session,
      where: (t) => t.localAuthUserId.equals(authUserId),
    );
  }

  Future<ProfileDetails?> _detailsForAuthenticatedUser(Session session) async {
    final membership = await _membershipForAuthenticatedUser(session);
    if (membership == null) return null;

    return ProfileDetails.db.findFirstRow(
      session,
      where: (t) => t.membershipId.equals(membership.id!),
    );
  }

  String _validateName(String value, String field) {
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > 60) {
      throw ArgumentError.value(value, field, 'must be 1-60 characters');
    }
    return trimmed;
  }

  void _validateBirthday(DateTime birthday) {
    // Calendar-day checks in UTC, matching the UTC-midnight sentinel date.
    final now = DateTime.timestamp();
    final today = DateTime.utc(now.year, now.month, now.day);
    if (!birthday.isBefore(today)) {
      throw ArgumentError.value(birthday, 'birthday', 'must be in the past');
    }
    if (birthday.isBefore(DateTime.utc(1900))) {
      throw ArgumentError.value(birthday, 'birthday', 'is implausibly old');
    }
  }
}
