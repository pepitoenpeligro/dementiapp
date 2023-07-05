import 'package:flutter/material.dart';
import 'dart:math';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[300],
        elevation: 0,
        title: Text(
          'Pagina de prueba para el navigation drawer',
          style: TextStyle(color: Colors.grey[800]),
        ),
      ),
      body: Center(
          child: Text(
              'Layout de prueba para el navigation drawer ${Random().nextInt(100)}')),
    );
  }
}
