import 'package:flutter/material.dart';

class SenaLogo extends StatelessWidget {
  const SenaLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.network(
          'https://www.sena.edu.co/Style%20Library/alayout/images/logoSena.png',
          height: 90,
        ),
        const SizedBox(height: 10),
        const Text(
          'FIMACOR',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}