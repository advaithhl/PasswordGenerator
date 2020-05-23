import 'package:flutter/material.dart';
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
            subtitle: TextStyle(
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

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int passLength = 30;
  PasswordGenerator _passwordGenerator = new PasswordGenerator();
  String _pwd;

  void setNewPassword() {
    setState(() {
      _pwd = _passwordGenerator.generatePassword(passLength);
    });
  }

  @override
  Widget build(BuildContext context) {
    _pwd = _passwordGenerator.generatePassword(passLength);
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
              child: Container(
                child: Container(
                  child: ParsedText(
                    text: '$_pwd',
                    alignment: TextAlign.center,
                    parse: <MatchText>[
                      MatchText(
                        pattern: r'[A-Z]',
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                              color: Colors.purple,
                            ),
                      ),
                      MatchText(
                        pattern: r'[a-z]',
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                              color: Colors.green,
                            ),
                      ),
                      MatchText(
                        pattern: r'[0-9]',
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                              color: Colors.red,
                            ),
                      ),
                      MatchText(
                        pattern: r'\W|_',
                        style: Theme.of(context).textTheme.subtitle.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(20.0),
                  margin: EdgeInsets.all(30.0),
                  constraints: BoxConstraints.tightFor(
                    height: 200,
                  ),
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      )),
                ),
                alignment: Alignment.center,
              ),
            ),
            Flexible(
              flex: 1,
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
                },
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
