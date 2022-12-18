// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_docs/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton.icon(
      onPressed: () {},
      icon: Image(
        image: AssetImage("assets/images/glogo.png"),
        height: 40,
        // width: 50,
      ),
      label: const Text(
        "Sign in With Google",
        style: TextStyle(color: kBlackColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: kWhiteColor,
        minimumSize: const Size(150, 50),
      ),
    )));
  }
}
