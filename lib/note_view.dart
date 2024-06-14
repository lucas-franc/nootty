import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:flutter_quill/flutter_quill.dart';

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  QuillController controller = QuillController.basic();
  @override
  void initState() {
    super.initState();
    controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = controller.document.toPlainText();
    final lines = text.split('\n');
    for (var line in lines) {
      if (line.startsWith('# ')) {
        _convertToHeader(line, quill.Attribute.h1);
      }
    }
  }

  void _convertToHeader(String line, quill.Attribute attribute) {
    // Evitar alterações durante o listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final position = controller.document.toPlainText().indexOf(line);
      if (position != -1) {
        controller.formatText(position, line.length, attribute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: QuillEditor(
                  focusNode: FocusNode(),
                  scrollController: ScrollController(),
                  configurations: QuillEditorConfigurations(
                    controller: controller,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('de'),
                    ),
                  ),
                ),
              ),
              QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
