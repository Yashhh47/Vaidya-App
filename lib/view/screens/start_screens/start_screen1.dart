import 'package:flutter/material.dart';

class StartScreen1 extends StatelessWidget {
  const StartScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start Screen')),
      body: const Center(child: Text('Welcome to StartScreen1')),
    );
  }
}
