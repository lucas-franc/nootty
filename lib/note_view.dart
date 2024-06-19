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
    int hashtagQuantity = 0;
    for (int i = 0; i < line.length; i++) {
      if (line[i] == '#') {
        hashtagQuantity++;
      } else {
        break;
      }
    }
    final cleanLine = line.substring(hashtagQuantity + 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fullText = controller.document.toPlainText();
      final position = fullText.indexOf(line);
      if (position != -1) {
        switch (hashtagQuantity) {
          case 1:
            attribute = quill.Attribute.h1;
            break;
          case 2:
            attribute = quill.Attribute.h2;
            break;
          case 3:
            attribute = quill.Attribute.h3;
            break;
          case 4:
            attribute = quill.Attribute.h4;
            break;
          case 5:
            attribute = quill.Attribute.h5;
            break;
          case 6:
            attribute = quill.Attribute.h6;
            break;
          default:
            return;
        }
        controller.replaceText(position, hashtagQuantity + 1, '',
            TextSelection.collapsed(offset: position),
            shouldNotifyListeners: false);
        controller.formatText(position, cleanLine.length, attribute);
      }
    });
  }

  void _convertToBold(String text) {
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');

    String fullText = controller.document.toPlainText();

    final Iterable<RegExpMatch> matches = regex.allMatches(text);
    for (RegExpMatch match in matches) {
      final String boldText = match.group(1)!;
      final int matchStart = match.start;
      final int matchEnd = match.end;
      int start = fullText.indexOf(match.group(0)!, matchStart);
      int end = start + match.group(0)!.length;
      fullText = fullText.replaceRange(start, end, boldText);
      controller.replaceText(start, end - start, boldText,
          TextSelection.collapsed(offset: start + boldText.length),
          shouldNotifyListeners: false);
      controller.formatText(start, boldText.length, Attribute.bold);
      if (matchStart + boldText.length < controller.document.length) {
        controller.formatText(matchStart + boldText.length, 0,
            Attribute.clone(Attribute.bold, null));
      }
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
