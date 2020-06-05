import 'package:clipboard_manager/clipboard_manager.dart';
import 'package:encrypted_shared_preferences/encrypted_shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_parsed_text/flutter_parsed_text.dart';

import 'passwordgen.dart';

void main() => runApp(MyApp());

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

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  final PasswordGenerator _pwdGen = new PasswordGenerator();
  final EncryptedSharedPreferences _eSharedPref = EncryptedSharedPreferences();

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int passLength = 30;
  String _pwd = "loading...";

  Future<bool> storePassword() {
    return widget._eSharedPref.setString('copiedPass', this._pwd);
  }

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

  void setNewPassword() {
    widget._pwdGen.generatePassword(passLength).then((value) {
      setState(() {
        this._pwd = value;
      });
    });
  }

  Future<bool> clearStoredPassword() {
    return widget._eSharedPref.clear();
  }

  @override
  void initState() {
    super.initState();
    setPassword();
  }

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
                              style: Theme
                                  .of(context)
                                  .textTheme
                                  .subtitle2
                                  .copyWith(
                                color: Colors.red,
                              ),
                              onTap: (letter) {},
                            ),
                            MatchText(
                              pattern: r'\W|_',
                              style: Theme
                                  .of(context)
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
                        ClipboardManager.copyToClipBoard(_pwd).then((result) {
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
