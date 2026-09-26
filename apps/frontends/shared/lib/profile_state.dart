import 'package:flutter/foundation.dart';
// Imported with a prefix; the plain import would clash with extensions
// provided by the host apps.
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as auth_core;
import 'package:top_attempt_global_client/top_attempt_client.dart';

/// Holds the profile data of the signed-in user.
///
/// Email, user id and profile image come from the built-in
/// [auth_core.UserProfileModel]; the extended data (first/last name,
/// birthday) lives in the own [ProfileDetails] model on the server.
///
/// Lives in `apps/frontends/shared` and is consumed by the end-user app
/// and the global admin app identically — changes here apply to both.
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
  ///
  /// The end-user app uses this to force profile completion; admin apps
  /// deliberately ignore it (admins may sign in without a completed
  /// profile).
  bool get isComplete {
    final details = _details;
    return details != null &&
        details.firstName != null &&
        details.lastName != null &&
        details.birthday != null;
  }

  /// Loads both profile parts from the server.
  /// Auth is enforced by the server (requireLogin); this method is only
  /// triggered by the auth listener while signed in. Admin apps must not
  /// force profile completion (see consumer).
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
