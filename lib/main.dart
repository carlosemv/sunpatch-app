import 'package:flutter/material.dart';
import 'package:sunpatch/home_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget {
	final String title = 'Sunpatch';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primaryColor: Colors.deepOrange,
        accentColor: Colors.deepOrange,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepOrange,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      home: Home(title: title),
    );
  }
}