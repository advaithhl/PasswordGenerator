import 'dart:math';

class PasswordGenerator {
  static const String _printables = '0123456789abcdefghijklmnopqrstuvwxyz'
      'ABCDEFGHIJKLMNOPQRSTUVWXYZ!"#\$%&\'()*+,-./:;<=>?@[\\]^_`{|}~';

  bool passwordOkay(String pwd) {
    return pwd.contains(new RegExp(r'[A-Z]')) &&
        pwd.contains(new RegExp(r'[a-z]')) &&
        pwd.contains(new RegExp(r'[0-9]')) &&
        pwd.contains(new RegExp(r'\W|_'));
  }

  String utilPass(int length) {
    var secureRNG = Random.secure();
    StringBuffer pwd = new StringBuffer();
    var p = PasswordGenerator._printables;
    while (length-- != 0) {
      pwd.write(p[secureRNG.nextInt(p.length)]);
    }
    return pwd.toString();
  }

  String generatePassword(int length) {
    while (true) {
      String pwd = utilPass(length);
      if (passwordOkay(pwd)) {
        return pwd;
      }
    }
  }
}
