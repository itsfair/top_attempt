import 'package:flutter/foundation.dart';
// Imported with a prefix because importing it plainly would make the
// `ClientAuthSessionManagerExtension` conflict with the `auth` shortcut
// used elsewhere in the app.
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth_core;
import 'package:top_attempt_global_client/top_attempt_client.dart';

/// Holds the profile data of the signed-in user and knows whether the
/// mandatory profile fields are filled in yet.
///
/// Email, user id and profile image come from the built-in
/// [auth_core.UserProfileModel]; first/last name and birthday are stored in
/// our own [ProfileDetails] model on the server.
class ProfileState extends ChangeNotifier {
  final Client _client;

  ProfileState(this._client);

  /// Basic account info of the signed-in user (email, user id, image url).
  auth_core.UserProfileModel? _profile;

  /// Our own extended profile data (first name, last name, birthday).
  ProfileDetails? _details;
  bool _loaded = false;

  /// Basic account info of the signed-in user (email, user id, image url).
  auth_core.UserProfileModel? get profile => _profile;

  /// Our own extended profile data (first name, last name, birthday).
  ProfileDetails? get details => _details;

  /// True once the data has been fetched from the server after signing in.
  bool get loaded => _loaded;

  /// True when all mandatory fields (first name, last name, birthday) are
  /// set. The profile image is optional.
  bool get isComplete {
    final details = _details;
    return details != null &&
        details.firstName != null &&
        details.lastName != null &&
        details.birthday != null;
  }

  /// Loads both profile parts from the server.
  /// Auth is enforced by the server (requireLogin); this method is only
  /// triggered by the auth listener while signed in.
  Future<void> load() async {
    final detailsFuture = _client.profileDetails.get();
    final profileFuture = _client.userProfileEdit.get();

    _details = await detailsFuture;
    _profile = await profileFuture;
    _loaded = true;
    notifyListeners();
  }

  /// Replaces locally known parts of the state after a successful save,
  /// so the UI updates without another round trip.
  void update({auth_core.UserProfileModel? profile, ProfileDetails? details}) {
    if (profile != null) _profile = profile;
    if (details != null) _details = details;
    notifyListeners();
  }

  /// Clears all state after sign-out.
  void reset() {
    _profile = null;
    _details = null;
    _loaded = false;
    notifyListeners();
  }
}
