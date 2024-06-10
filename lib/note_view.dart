import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class NoteView extends StatefulWidget {
  const NoteView({super.key});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  final quill.QuillController _controller = quill.QuillController.basic();
  String _markdownText = '';

  void _onTextChanged() {
    setState(() {
      _markdownText = _controller.document.toPlainText();
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Markdown Editor'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: quill.QuillEditor.basic(
              configurations:
                  quill.QuillEditorConfigurations(controller: _controller),
            ),
          ),
          Divider(),
          Expanded(
            flex: 1,
            child: Markdown(
              data: _markdownText,
            ),
          ),
        ],
      ),
    );
  }
}
