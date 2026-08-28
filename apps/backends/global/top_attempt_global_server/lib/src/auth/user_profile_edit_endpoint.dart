import 'dart:typed_data';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/core.dart';

/// Exposes the built-in user profile management endpoints of the
/// authentication module to the app (get, set/remove image, change names).
class UserProfileEditEndpoint extends UserProfileEditBaseEndpoint {
  /// Replaces the profile image. The previous image (database row + file in
  /// storage) is removed first, so replacing an image does not pile up old
  /// files. This is a no-op if the user has no image yet.
  @override
  Future<UserProfileModel> setUserImage(
    final Session session,
    final ByteData image,
  ) async {
    final authUserId = session.authenticated!.authUserId;

    await userProfiles.removeUserImage(session, authUserId);

    return super.setUserImage(session, image);
  }
}
