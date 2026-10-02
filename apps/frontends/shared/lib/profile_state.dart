import 'package:flutter/foundation.dart';
import 'package:top_attempt_global_client/top_attempt_client.dart';

/// Holds the profile data of the signed-in user, read/written via the own
/// `memberProfile` endpoint of the global instance (the built-in Serverpod
/// UserProfile feature is bypassed by design — `member_profile` is the
/// single person/profile store; see the backend AGENTS.md).
///
/// Lives in `apps/frontends/shared` and is consumed by the end-user app
/// and the global admin app identically — changes here apply to both.
class ProfileState extends ChangeNotifier {
  final Client _client;

  ProfileState(this._client);

  MemberProfile? _memberProfile;
  bool _loaded = false;

  /// The signed-in user's own member profile (email, person id, names,
  /// birthday, image url).
  MemberProfile? get memberProfile => _memberProfile;

  /// Composed full name (firstName + lastName), for display/avatar.
  String? get fullName {
    final parts = [
      _memberProfile?.firstName,
      _memberProfile?.lastName,
    ].whereType<String>().where((part) => part.isNotEmpty);
    final joined = parts.join(' ').trim();
    return joined.isEmpty ? null : joined;
  }

  /// Public image URL of the profile image (string form for the shared
  /// widgets).
  String? get imageUrl {
    final url = _memberProfile?.imageUrl;
    return url == null || url.isEmpty ? null : url;
  }

  /// True once the data has been fetched from the server after signing in.
  bool get loaded => _loaded;

  /// True when all mandatory fields (first name, last name, birthday) are
  /// set. The profile image is optional.
  ///
  /// The end-user app uses this to force profile completion; admin apps
  /// deliberately ignore it (admins may sign in without a completed
  /// profile).
  bool get isComplete {
    final profile = _memberProfile;
    return profile != null &&
        profile.firstName != null &&
        profile.lastName != null &&
        profile.birthday != null;
  }

  /// Loads the profile from the server.
  /// Auth is enforced by the server (requireLogin); this method is only
  /// triggered by the auth listener while signed in. Admin apps must not
  /// force profile completion (see consumer).
  Future<void> load() async {
    _memberProfile = await _client.memberProfile.get();
    _loaded = true;
    notifyListeners();
  }

  /// Replaces locally known parts of the state after a successful save,
  /// so the UI updates without another round trip.
  void update({MemberProfile? memberProfile}) {
    if (memberProfile != null) _memberProfile = memberProfile;
    notifyListeners();
  }

  /// Clears all state after sign-out.
  void reset() {
    _memberProfile = null;
    _loaded = false;
    notifyListeners();
  }
}
