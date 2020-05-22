import 'package:flutter/material.dart';

import 'passwordgen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final String _title = 'Password Generator';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
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
            Text(
              '$_pwd',
            ),
            Slider.adaptive(
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
          ],
        ),
      ),
    );
  }
}
