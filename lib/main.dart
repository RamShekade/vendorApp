import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/createProfile.dart';
import 'package:flutter_application_1/screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Raksha App',
      theme: ThemeData(primarySwatch: Colors.purple),
      // home: LoginPage(),
      home: CreateProfilePage(),
    );
  }
}
