// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/controller/auth_controller.dart';
import 'package:google_docs/screens/home_screen.dart';
import 'package:routemaster/routemaster.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  void signInWithGoogle(WidgetRef ref, BuildContext context) async {
    final sMessenger = ScaffoldMessenger.of(context);
    final navigator = Routemaster.of(context);
    final errorModel =
        await ref.read(authRepositoryProvider).signInWithGoogle();
    if (errorModel.error == null) {
      ref.read(userProvider.notifier).update((state) => errorModel.data);
      navigator.push('/');
    } else {
      sMessenger.showSnackBar(SnackBar(
        content: Text(errorModel.error!),
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        body: Center(
            child: ElevatedButton.icon(
      onPressed: () => signInWithGoogle(ref, context),
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
