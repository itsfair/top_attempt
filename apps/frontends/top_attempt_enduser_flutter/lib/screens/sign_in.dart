import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import '../main.dart';
import 'package:go_router/go_router.dart';

class SignIn extends StatelessWidget {
  const SignIn({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SignInWidget(
        client: client,
        onAuthenticated: () {
          context.go('/');
        },
        onError: (error) {
          // Handle errors
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      ),
    );
  }
}
