import 'dart:math';

/// A password generator which generates secure passwords containing ASCII
/// printable characters. Each of the generated password will necessarily
/// contain at least 1 uppercase, 1 lowercase, 1 digit, and 1 special character.
class PasswordGenerator {
  /// [String] of all the possible characters from which a password will be
  /// generated.
  static const String _printables = '0123456789abcdefghijklmnopqrstuvwxyz'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';

  /// Check if password satisfies certain conditions.
  ///
  /// Utility function to check if a [String] password, accepted as argument
  /// has at least 1 uppercase, 1 lowercase, 1 digit, and 1 special character.
  /// Return a [bool] if password does satisfy the conditions.
  bool passwordOkay(String pwd) {
    return pwd.contains(new RegExp(r'[A-Z]')) &&
        pwd.contains(new RegExp(r'[a-z]')) &&
        pwd.contains(new RegExp(r'[0-9]')) &&
        pwd.contains(new RegExp(r'\W|_'));
  }

  /// Generate a password of a given length; might not have all character types.
  ///
  /// Utility function to generate a password of given length. Use a secure
  /// random number generator to create random integers in range
  /// 0-[_printables.length]. Use this generated random number as an index to
  /// fetch one single character from [_printables], and append to a
  /// [StringBuffer] object. Repeat this process [length] times to generate a
  /// password of length [length].
  ///
  /// Note: the generated password may not necessarily contain an uppercase,
  /// lowercase, digit, and a special character. For most cases, use
  /// [generatePassword()].
  String utilPass(int length) {
    var secureRNG = Random.secure();
    StringBuffer pwd = new StringBuffer();
    var p = PasswordGenerator._printables;
    while (length-- != 0) {
      pwd.write(p[secureRNG.nextInt(p.length)]);
    }
    return pwd.toString();
  }

  /// Generate a password of a given length.
  ///
  /// Return a [Future] of [String]. Continuously call [utilPass()] and check
  /// if the password obtained as result satisfies the conditions dictated
  /// by [passwordOkay()]. This way, passwords returned by this method is
  /// guaranteed to contain at least 1 uppercase, 1 lowercase, 1 digit, and 1
  /// special character.
  Future<String> generatePassword(int length) {
    return Future(
      () {
        String pwd;
        while (true) {
          pwd = utilPass(length);
          if (passwordOkay(pwd)) {
            return pwd;
          }
        }
      },
    );
  }
}
