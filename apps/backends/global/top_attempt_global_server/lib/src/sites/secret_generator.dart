import 'dart:math';

/// Random secret generator for setup tokens (alphanumeric, URL/QR friendly)
/// and initial passwords (satisfying the default password requirements).
class SecretGenerator {
  static const String _urlFriendlyAlphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  static const String _passwordAlphabet =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
      r'!"#$%&()*+,-./:;<=>?@[]^_`{|}~';

  static final RegExp _specialCharacterRegExp = RegExp(
    r'''[ !"#$%&'()*+,\-./:;<=>?@\[\\\]^_ `{|}~]''',
  );

  /// Cryptographically strong one time password for site enrollment
  /// (alphanumeric, ~190 bits entropy).
  static String generateOneTimePassword() {
    return _randomString(32, alphabet: _urlFriendlyAlphabet);
  }

  /// Cryptographically strong initial password for the local admin,
  /// satisfying the default password requirements shown in the login widget
  /// (min 12 chars, >= 1 upper, >= 1 lower, >= 1 number, >= 1 special
  /// character).
  static String generateInitialAdminPassword() {
    final password = _randomString(16, alphabet: _passwordAlphabet);

    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(_specialCharacterRegExp);

    if (hasUpper && hasLower && hasNumber && hasSpecial) {
      return password;
    }

    // The probability of a miss with 16 characters is tiny; regenerate to
    // never hand out a password the login policy would reject.
    return generateInitialAdminPassword();
  }

  static String _randomString(
    final int length, {
    required final String alphabet,
  }) {
    final random = Random.secure();
    return [
      for (var i = 0; i < length; i++)
        alphabet[random.nextInt(alphabet.length)],
    ].join();
  }
}
