/// Package-level switches for the shared frontend components.
///
/// `kProfileEditingEnabled` (decision 2026-09-25: disabled until the
/// profile/membership sync model is agreed) was re-enabled on 2026-09-26
/// temporarily to test the profile-image transfer to the local instance
/// (photo → member row). Flip back to `false` once the sync design is
/// settled.
const bool kProfileEditingEnabled = true;
