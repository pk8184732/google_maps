
import 'package:flutter/material.dart';

import 'google/google_map_screen.dart';
void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Product Link',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home:  GoogleMapScreen(),
    );
  }
}

