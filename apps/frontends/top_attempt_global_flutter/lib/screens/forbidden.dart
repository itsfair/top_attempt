import 'package:flutter/material.dart';

class Forbidden extends StatelessWidget {
  const Forbidden({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Zugriff verweigert. Sie haben nicht die erforderlichen Berechtigungen, um auf diese Seite zuzugreifen.',
        style: Theme.of(context).textTheme.headlineLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
