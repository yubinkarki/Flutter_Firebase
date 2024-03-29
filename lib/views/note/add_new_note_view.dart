import 'package:flutter/material.dart';

import 'package:okaychata/services/cloud/cloud_note.dart' show CloudNote;
import 'package:okaychata/services/auth/auth_service.dart' show AuthService;
import 'package:okaychata/services/cloud/cloud_service.dart' show CloudService;
import 'package:okaychata/utilities/generics/get_arguments.dart' show GetArgument;
import 'package:okaychata/utilities/dialogs/show_generic_dialog.dart' show showGenericDialog;

class AddNewNoteView extends StatefulWidget {
  const AddNewNoteView({Key? key}) : super(key: key);

  @override
  State<AddNewNoteView> createState() => _AddNewNoteViewState();
}

class _AddNewNoteViewState extends State<AddNewNoteView> {
  CloudNote? _note;
  late final CloudService _noteService;
  late final TextEditingController _textController;

  @override
  void initState() {
    _noteService = CloudService();
    _textController = TextEditingController();
    super.initState();
  }

  Future<CloudNote?> populateTextField(BuildContext context) async {
    final widgetNote = context.getArgument<CloudNote>();

    _note = widgetNote;

    _textController.text = widgetNote?.text ?? "";

    return widgetNote;
  }

  void _handleAddButton() async {
    final text = _textController.text;

    FocusManager.instance.primaryFocus?.unfocus();

    if (text.isEmpty) {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => showGenericDialog(
          context: context,
          title: "Error",
          content: "Please write something to add",
          optionsBuilder: () => {"Got It": null},
        ),
      );
    } else {
      final existingUser = AuthService.factoryFirebase().currentUser!;
      final userId = existingUser.id;

      await _noteService.createNewNote(ownerUserId: userId, text: text);

      Future.delayed(
        const Duration(milliseconds: 200),
        () => showGenericDialog(
          context: context,
          title: "Success",
          content: "Note added successfully",
          optionsBuilder: () => {"Great": null},
        ),
      );
    }
  }

  void _handleUpdateButton() async {
    final note = _note;
    final text = _textController.text;

    FocusManager.instance.primaryFocus?.unfocus();

    if (text.isNotEmpty && note != null) {
      await _noteService.updateNote(documentId: note.documentId, text: text);

      Future.delayed(
        const Duration(milliseconds: 200),
        () => showGenericDialog(
          context: context,
          title: "Success",
          content: "Note updated successfully",
          optionsBuilder: () => {"Great": null},
        ),
      );
    } else {
      Future.delayed(
        const Duration(milliseconds: 200),
        () => showGenericDialog(
          context: context,
          title: "Error",
          content: "Please write something to update",
          optionsBuilder: () => {"Got It": null},
        ),
      );
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final widgetNote = context.getArgument<CloudNote>();
    final inputTextValue = widgetNote?.text;

    return Scaffold(
      appBar: AppBar(
        title: Text("New Note", style: textTheme.titleLarge),
      ),
      body: FutureBuilder(
        future: populateTextField(context),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: TextField(
                        controller: _textController,
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: null,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          constraints: BoxConstraints(maxHeight: 250.0),
                          border: OutlineInputBorder(),
                          hintText: "Write your note here...",
                        ),
                      ),
                    ),
                    Container(
                      width: 120.0,
                      height: 45.0,
                      margin: const EdgeInsets.only(top: 10, bottom: 50),
                      child: inputTextValue != null
                          ? OutlinedButton(
                              onPressed: _handleUpdateButton,
                              child: Text("Update", style: textTheme.labelMedium),
                            )
                          : OutlinedButton(
                              onPressed: _handleAddButton,
                              child: Text("Add", style: textTheme.labelMedium),
                            ),
                    ),
                  ],
                ),
              );

            default:
              return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
