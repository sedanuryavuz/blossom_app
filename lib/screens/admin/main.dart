import 'package:flutter/material.dart';
import 'package:blossom_app/screens/admin/menu.dart';

void main() {
  runApp(const AdminScreen());
}

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'asdas',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const HomeScreen(),
    );
  }
}
