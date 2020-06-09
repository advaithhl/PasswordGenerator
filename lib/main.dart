import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';

import 'passwordgen.dart';

void main() => runApp(MyApp());

/// Main [StatelessWidget] corresponding to the entire app.
///
/// Build a [MaterialApp] with home described as StatefulWidget [MyHomePage].
class MyApp extends StatelessWidget {
  final String _title = 'Password Generator';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
          brightness: Brightness.dark,
          textTheme: TextTheme(
            subtitle2: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Source Code Pro',
              fontWeight: FontWeight.bold,
            ),
          )),
      home: MyHomePage(title: _title),
    );
  }
}

/// Main StatefulWidget with state [_MyHomePageState].
class MyHomePage extends StatefulWidget {
  /// Accept title and set it as [AppBar] title in constructor.
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  /// Generate new passwords with this instance of [PasswordGenerator].
  final PasswordGenerator _pwdGen = new PasswordGenerator();

  /// Temporarily, but securely store one password with this instance of
  /// [EncryptedSharedPreferences].
  final EncryptedSharedPreferences _eSharedPref = EncryptedSharedPreferences();

  /// Create a state for this StatefulWidget.
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

/// Maintain [State] of [MyHomePage].
///
/// Contain methods for storing/clearing passwords, and build almost all of
/// the main UI.
class _MyHomePageState extends State<MyHomePage> {
  /// Length of the password. Used as [Slider] value. (default: 30)
  int passLength = 30;

  /// Current value of password. Default set to avoid displaying "null" in UI.
  String _pwd = "loading...";

  /// Store current password in [EncryptedSharedPreferences] with key
  /// 'copiedPass'. Return a [Future] of [bool] which indicated success/failure
  /// of storing.
  Future<bool> storePassword() {
    return widget._eSharedPref.setString('copiedPass', this._pwd);
  }

  /// Set a password.
  ///
  /// Look if there exists a value for key 'copiedPass'. If there is, set state
  /// of [_pwd] update [passLength] accordingly, else call [setNewPassword()].
  void setPassword() {
    widget._eSharedPref.getString('copiedPass').then((sharedPrefValue) {
      if (sharedPrefValue != '') {
        setState(() {
          this._pwd = sharedPrefValue;
          this.passLength = sharedPrefValue.length;
        });
      } else {
        setNewPassword();
      }
    });
  }

  /// Generate a new password of length [passLength].
  void setNewPassword() {
    widget._pwdGen.generatePassword(passLength).then((value) {
      setState(() {
        this._pwd = value;
      });
    });
  }

  /// Clear stored password.
  ///
  /// Note: this clears the values of ALL keys of [widget._eSharedPref].
  /// This behaviour maybe changed in the future.
  Future<bool> clearStoredPassword() {
    return widget._eSharedPref.clear();
  }

  /// Call super's [initState()] and [setPassword()]. This makes sure that a
  /// password will always be set initially.
  @override
  void initState() {
    super.initState();
    setPassword();
  }

  /// Build components corresponding to state values.
  ///
  /// Return a [Scaffold] comprise an app bar, body and a floating action
  /// button. The body contains a centered Column, basically has 2 [Container]s.
  ///
  /// The first [Container] displays the current value of [_pwd], with each
  /// type of character (uppercase, lowercase, digit and special) parsed out
  /// and given different colors. This [Container] is also wrapped in an
  /// [InkWell] to provide visual effects on double tap and long press.
  /// Double tapping the [Container] copies the current value of [_pwd] into
  /// the clipboard and displays a [SnackBar]. Long pressing clears the stored
  /// value, sets a new password, and displays a [SnackBar].
  ///
  /// The second [Container] wraps the [Slider] and constrains the height of
  /// itself to 100. This is done so as to deliberately limit the touch area
  /// of the [Slider] to regions moderately close to the [Slider].
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Center(
                child: Builder(
                  builder: (BuildContext context) {
                    return InkWell(
                      child: Container(
                        child: ParsedText(
                          text: '$_pwd',
                          alignment: TextAlign.center,
                          parse: <MatchText>[
                            MatchText(
                              pattern: r'[A-Z]',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color: Colors.purple,
                                  ),
                              onTap: (letter) {},
                            ),
                            MatchText(
                              pattern: r'[a-z]',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color: Colors.green,
                                  ),
                              onTap: (letter) {},
                            ),
                            MatchText(
                              pattern: r'[0-9]',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color: Colors.red,
                                  ),
                              onTap: (letter) {},
                            ),
                            MatchText(
                              pattern: r'\W|_',
                              style: Theme.of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                    color: Colors.white,
                                  ),
                              onTap: (letter) {},
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(20.0),
                        constraints: BoxConstraints.tightFor(
                          height: 200,
                          width: MediaQuery.of(context).size.width - 60,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          shape: BoxShape.rectangle,
                        ),
                      ),
                      onDoubleTap: () {
                        var clipBoardData = ClipboardData(text: _pwd);
                        Clipboard.setData(clipBoardData).then((result) {
                          storePassword().then((storeResult) {
                            var snackBar;
                            if (storeResult) {
                              snackBar = SnackBar(
                                content: Text('Password copied!'),
                              );
                            } else {
                              snackBar = SnackBar(
                                content: Text('Something went wrong!'),
                              );
                            }
                            Scaffold.of(context).showSnackBar(snackBar);
                          });
                        });
                      },
                      onLongPress: () {
                        clearStoredPassword().then((deletionSuccess) {
                          var snackBar;
                          if (deletionSuccess) {
                            setNewPassword();
                            snackBar = SnackBar(
                              content: Text('Cleared stored password!'),
                            );
                          } else {
                            snackBar = SnackBar(
                              content: Text(
                                  'Something went wrong! Password not deleted!'),
                            );
                          }
                          Scaffold.of(context).showSnackBar(snackBar);
                        });
                      },
                    );
                  },
                ),
              ),
            ),
            Flexible(
              flex: 2,
              child: Container(
                child: Slider.adaptive(
                  value: passLength.toDouble(),
                  min: 10,
                  max: 50,
                  divisions: 40,
                  label: '$passLength',
                  onChanged: (double value) {
                    setState(() {
                      this.passLength = value.round();
                    });
                    setNewPassword();
                  },
                ),
                constraints: BoxConstraints.tightFor(
                  height: 100,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: setNewPassword,
        tooltip: 'New Password',
        child: Icon(Icons.refresh),
      ),
    );
  }
}
