import 'package:flutter/material.dart';
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
      if (isTitleMarkdown(line)) {
        _convertToHeader(line, quill.Attribute.h1);
      }
      if (isBoldMarkdown(line)) {
        _convertToBold(line);
      }
    }
  }

  RegExp boldRegex = RegExp(r'(\*\*.*?\*\*)|(__.*?__)');
  RegExp titleRegex = RegExp(r'^\#{1,6}\s');

  bool isBoldMarkdown(String text) {
    return boldRegex.hasMatch(text);
  }

  bool isTitleMarkdown(String text) {
    return titleRegex.hasMatch(text);
  }

  void _convertToHeader(String line, quill.Attribute attribute) {
    final cleanLine = line.substring(2);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fullText = controller.document.toPlainText();
      final position = fullText.indexOf(line);
      if (position != -1) {
        controller.replaceText(
            position, 2, '', TextSelection.collapsed(offset: position),
            shouldNotifyListeners: false);
        controller.formatText(position, cleanLine.length, attribute);
      }
    });
  }

  void _convertToBold(String text) {
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');

    final Iterable<RegExpMatch> matches = regex.allMatches(text);
    for (RegExpMatch match in matches) {
      final String boldText = match.group(1)!;
      final int start = match.start;
      final int end = match.end;
      controller.replaceText(
          start, end - start, '', TextSelection.collapsed(offset: start),
          shouldNotifyListeners: false);
      controller.replaceText(start, 0, boldText,
          TextSelection.collapsed(offset: start + boldText.length),
          shouldNotifyListeners: false);
      controller.formatText(start, boldText.length, Attribute.bold,
          shouldNotifyListeners: false);
      controller.updateSelection(
          TextSelection.collapsed(offset: start + boldText.length),
          ChangeSource.local);
      controller.formatText(
          start + boldText.length, 0, Attribute.clone(Attribute.bold, null),
          shouldNotifyListeners: false);
    }
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
