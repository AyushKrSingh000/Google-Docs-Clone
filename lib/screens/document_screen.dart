import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_docs/colors.dart';
import 'package:google_docs/controller/auth_controller.dart';
import 'package:google_docs/controller/document_controller.dart';
import 'package:google_docs/controller/socket_controller.dart';
import 'package:google_docs/models/document_model.dart';
import 'package:google_docs/widgets/loader.dart';
import 'package:routemaster/routemaster.dart';

import '../models/error_model.dart';

class DocumentScreen extends ConsumerStatefulWidget {
  final String id;
  const DocumentScreen({super.key, required this.id});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends ConsumerState<DocumentScreen> {
  TextEditingController controller =
      TextEditingController(text: "Untitled Document");
  quill.QuillController? _controller;
  ErrorModel? errorModel;
  SocketRepo socketRepo = SocketRepo();
  @override
  void dispose() {
    super.dispose();

    controller.dispose();
  }

  Timer? timer;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    socketRepo.joinRoom(widget.id);
    fetchDocumentData();
    socketRepo.changeListener((data) {
      // print(data['Delta']);
      _controller?.compose(
          quill.Delta.fromJson(data['Delta']),
          _controller?.selection ?? const TextSelection.collapsed(offset: 0),
          quill.ChangeSource.REMOTE);
    });
    timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      socketRepo.autoSave(<String, dynamic>{
        'Delta': _controller!.document.toDelta(),
        'room': widget.id,
      });
    });
    timer?.isActive;
  }

  void fetchDocumentData() async {
    errorModel = await ref.read(documentRepositoryProvider).getDocumentById(
          ref.read(userProvider)!.token,
          widget.id,
        );
    if (errorModel!.data != null) {
      controller.text = (errorModel!.data as DocumentModel).title;
      print(controller.text);
      _controller = quill.QuillController(
          document: errorModel!.data.content.isEmpty
              ? quill.Document()
              : quill.Document.fromDelta(
                  quill.Delta.fromJson(errorModel!.data.content)),
          selection: const TextSelection.collapsed(offset: 0));
      setState(() {});
    }
    _controller!.document.changes.listen((event) {
      if (event.item3 == quill.ChangeSource.LOCAL) {
        Map<String, dynamic> map = {
          'Delta': event.item2,
          'room': widget.id,
        };
        socketRepo.typing(map);
      }
    });
  }

  void updateTitle(String title) async {
    ref.read(documentRepositoryProvider).updateTitle(
        token: ref.read(userProvider)!.token, id: widget.id, title: title);
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const Scaffold(
        body: Loader(),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kWhiteColor,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: kBlueColor),
                onPressed: () {},
                icon: const Icon(
                  Icons.lock,
                  size: 16,
                  color: kWhiteColor,
                ),
                label: const Text(
                  'Share',
                  style: TextStyle(color: kWhiteColor),
                )),
          )
        ],
        // ignore: prefer_const_literals_to_create_immutables
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9.0),
          child: Row(children: [
            GestureDetector(
              onTap: () {
                // socketRepo.close();
                timer?.cancel();
                Routemaster.of(context).replace('/');
              },
              child: const Image(
                image: AssetImage('assets/images/google_docs.png'),
                height: 40,
                width: 40,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: 200,
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kBlueColor,
                      ),
                    ),
                    contentPadding: EdgeInsets.only(
                      left: 10,
                    )),
                onSubmitted: (value) => updateTitle(value),
              ),
            )
          ]),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              decoration: BoxDecoration(
            border: Border.all(
              color: kGreyColor,
              width: 0.1,
            ),
          )),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            quill.QuillToolbar.basic(controller: _controller!),
            const SizedBox(
              height: 5,
            ),
            Expanded(
              child: SizedBox(
                width: 750,
                child: Card(
                  color: kWhiteColor,
                  elevation: 5.0,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: quill.QuillEditor.basic(
                      controller: _controller!,
                      readOnly: false, // true for view only mode
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
