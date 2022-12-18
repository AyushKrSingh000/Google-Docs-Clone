// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/models/user_account.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) => AuthController(
      googleSignIn: GoogleSignIn(),
      client: Client(),
    ));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthController {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  AuthController({
    required GoogleSignIn googleSignIn,
    required Client client,
  })  : _googleSignIn = googleSignIn,
        _client = client;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(error: 'Someinf unexpected Happens', data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final accUser = UserModel(
            email: user.email,
            name: user.displayName!,
            photoUrl: user.photoUrl!,
            uid: "",
            token: "");
        var res = await _client.post(Uri.parse("$host/api/signup"),
            body: accUser.toJson(),
            headers: {
              'Content-Type': 'application/json; charset=UTF-8',
            });
        switch (res.statusCode) {
          case 200:
            final newUSer = accUser.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
            );
            error = ErrorModel(error: null, data: newUSer);
            break;
          default:
            print('error');
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
