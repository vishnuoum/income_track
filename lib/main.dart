import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:income_track/pages/addIncome.dart';
import 'package:income_track/pages/addSpend.dart';
import 'package:income_track/pages/home.dart';
import 'package:income_track/pages/init.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Income Tracker',
      theme: FlexThemeData.dark(
        primary: Colors.white,
        secondary: Colors.white
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        "/home" : (context) => Home(args: ModalRoute.of(context)!.settings.arguments as Map),
        "/addIncome" : (context) => const AddIncome(),
        "/addSpend" : (context) => AddSpend(args: ModalRoute.of(context)!.settings.arguments as Map),
        "/" : (context) => const Init()
      },
      initialRoute: "/",
    );
  }
}
