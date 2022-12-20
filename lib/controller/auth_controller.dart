// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/controller/local_storage_repo.dart';
import 'package:google_docs/models/error_model.dart';
import 'package:google_docs/models/user_account.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';

final authRepositoryProvider = Provider((ref) => AuthController(
      googleSignIn: GoogleSignIn(),
      client: Client(),
      localStorageRepp: LocalStorageReop(), //
    ));

final userProvider = StateProvider<UserModel?>((ref) => null);

class AuthController {
  final GoogleSignIn _googleSignIn;
  final Client _client;
  final LocalStorageReop _localStorageRepp;
  AuthController({
    required GoogleSignIn googleSignIn,
    required Client client,
    required LocalStorageReop localStorageRepp,
  })  : _googleSignIn = googleSignIn,
        _client = client,
        _localStorageRepp = localStorageRepp;

  Future<ErrorModel> signInWithGoogle() async {
    ErrorModel error =
        ErrorModel(error: 'Something unexpected Happens', data: null);
    try {
      final user = await _googleSignIn.signIn();
      if (user != null) {
        final accUser = UserModel(
            email: user.email,
            name: user.displayName ?? "",
            photoUrl: user.photoUrl ?? "",
            uid: "",
            token: "");

        var res = await _client.post(Uri.parse('$host/api/signup'),
            body: accUser.toJson(),
            headers: {
              'Content-Type': 'application/json; charset=utf-8',
            });
        print(res.statusCode);
        switch (res.statusCode) {
          case 200:
            final newUSer = accUser.copyWith(
              uid: jsonDecode(res.body)['user']['_id'],
              token: jsonDecode(res.body)['token'],
            );
            _localStorageRepp.setTotken(newUSer.token);
            error = ErrorModel(error: null, data: newUSer);
            break;
          default:
            print('error2');
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getUserData() async {
    ErrorModel error =
        ErrorModel(error: 'Something unexpected Happens', data: null);
    try {
      String? token = await _localStorageRepp.getTotken();
      if (token != null && token != '') {
        var res = await _client.get(Uri.parse('$host/'), headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'x-auth-token': token,
        });
        // print(res.statusCode);
        switch (res.statusCode) {
          case 200:
            final newUser = UserModel(
                    email: jsonDecode(res.body)['user']['email'],
                    name: jsonDecode(res.body)['user']['name'],
                    photoUrl: jsonDecode(res.body)['user']['profilePic'],
                    uid: jsonDecode(res.body)['user']['_id'],
                    token: '')
                .copyWith(token: token);

            error = ErrorModel(error: null, data: newUser);
            break;
          default:
            print('error3');
        }
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  void signOut() async {
    await _googleSignIn.signOut();
    _localStorageRepp.setTotken('');
  }
}
