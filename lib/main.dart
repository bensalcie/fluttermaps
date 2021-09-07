import 'package:flutter/material.dart';

import 'modules/homepage.dart';
void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Maps Example",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white
      ),
      home: HomePage(),
    );
  }
}


