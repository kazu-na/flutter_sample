import 'package:flutter/material.dart';
import 'package:flutter_app/first_page.dart';
import 'package:flutter_app/my_home_page.dart';
import 'package:flutter_app/second_page.dart';
import 'package:flutter_app/text_field_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => const FirstPage(),
        '/second': (BuildContext context) => const SecondPage(),
      },
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      // home: const TextFieldPage(),
      // home: const FirstPage(),
    );
  }
}
