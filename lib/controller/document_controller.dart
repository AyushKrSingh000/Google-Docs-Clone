// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/constants.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:http/http.dart';

import '../models/error_model.dart';

final documentRepositoryProvider =
    Provider((ref) => DocumentRepo(client: Client()));

class DocumentRepo {
  final Client _client;
  DocumentRepo({
    required Client client,
  }) : _client = client;

  Future<ErrorModel> createDocument(String token) async {
    ErrorModel error = ErrorModel(error: 'Something went wrong', data: null);
    try {
      var res = await _client.post(Uri.parse('$host/doc/create'),
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'x-auth-token': token,
          },
          body: jsonEncode({
            'createdAt': DateTime.now().millisecondsSinceEpoch,
          }));
      // print(res.statusCode);

      switch (res.statusCode) {
        case 200:
          error =
              ErrorModel(error: null, data: DocumentModel.fromJson(res.body));
          break;
        default:
          print('error in docurt');
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }

  Future<ErrorModel> getDocument(String token) async {
    ErrorModel error = ErrorModel(error: 'Something went wrong', data: null);
    try {
      var res = await _client.get(
        Uri.parse('$host/doc/me'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'x-auth-token': token,
        },
      );
      // print(res.statusCode);

      switch (res.statusCode) {
        case 200:
          List<DocumentModel> document = [];
          // print(res.body);
          for (int i = 0; i < jsonDecode(res.body).length; i++) {
            document.add(
                DocumentModel.fromJson(jsonEncode(jsonDecode(res.body)[i])));
          }
          // print(document);
          error = ErrorModel(error: null, data: document);
          break;
        default:
          print('error in document2');
      }
    } catch (e) {
      error = ErrorModel(error: e.toString(), data: null);
    }
    return error;
  }
}
