import 'package:flutter/material.dart';
import 'package:flutter_application/features/dashboard/ui/dashboard_page.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyDmOxTF0aB8z0DHb0JsTR1TRMiwzMumGI4');
  // final gemini = Gemini.instance;
  //string story = "story"
  // gemini.text("Write a $story about a magic backpack.")
  // .then((value) => print( value?.output )) /// or value?.content?.parts?.last.text
  // .catchError((e) => print(e));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DashboardPage(),
    );
  }
}