import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CodeEditorController extends ChangeNotifier {
  final TextEditingController textController;
  int _activeLineIndex = 0;
  
  int get activeLineIndex => _activeLineIndex;

  CodeEditorController({String text = '\n\n'}) 
      : textController = TextEditingController(text: text) {
    textController.addListener(_onTextChanged);
  }

  String get text => textController.text;

  set text(String newText) {
    if (textController.text != newText) {
      textController.text = newText;
      notifyListeners();
    }
  }

  void _onTextChanged() {
    notifyListeners();
  }

  void setActiveLine(int index) {
    if (_activeLineIndex != index) {
      _activeLineIndex = index;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    textController.dispose();
    super.dispose();
  }
}

class WeSqlCodeEditor extends StatefulWidget {
  const WeSqlCodeEditor({
    super.key,
    required this.controller,
    this.keywords = const {},
    this.lineNumberColor = Colors.purpleAccent,
    this.activeLineColor = Colors.orangeAccent,
    this.textColor = Colors.greenAccent,
    this.keywordColor = Colors.pinkAccent,
    this.textStyle = const TextStyle(fontFamily: 'monospace', fontSize: 18, height: 1.5, color: Colors.greenAccent),
    this.onGetTextCallback,
  });

  final CodeEditorController controller;
  final Set<String> keywords;
  final Color lineNumberColor;
  final Color activeLineColor;
  final Color textColor;
  final Color keywordColor;
  final TextStyle textStyle;
  final ValueChanged<String>? onGetTextCallback;

  @override
  State<WeSqlCodeEditor> createState() => _WeSqlCodeEditorState();
}

class _WeSqlCodeEditorState extends State<WeSqlCodeEditor> {
  late final ScrollController _verticalScrollController;
  late final ScrollController _lineNumbersScrollController;
  final FocusNode _focusNode = FocusNode();
  late final ValueNotifier<List<TextSpan>> splitText;

  late final TextStyle highlightStyle;
  late final TextStyle normalStyle;

  void highlightKeywords({
  bool wholeWordsOnly = true,
}) {
  if (widget.controller.text.isEmpty) {
    splitText.value = [TextSpan(text: '', style: normalStyle)];
    return;
  }
  if (widget.keywords.isEmpty) {
    splitText.value = [TextSpan(text: widget.controller.text, style: normalStyle)];
    return;
  }

  final sorted = widget.keywords.toList()..sort((a, b) => b.length.compareTo(a.length));

  final pattern = sorted.map(RegExp.escape).join('|');

  final regex = RegExp(
    wholeWordsOnly ? '\\b(?:$pattern)\\b' : '(?:$pattern)',
    caseSensitive: false,
  );

  final spans = <TextSpan>[];
  int lastIndex = 0;

  for (final match in regex.allMatches(widget.controller.text)) {
    if (match.start > lastIndex) {
      spans.add(TextSpan(
        text: widget.controller.text.substring(lastIndex, match.start),
        style: normalStyle,
      ));
    }
    spans.add(TextSpan(
      text: match.group(0),
      style: highlightStyle,
    ));
    lastIndex = match.end;
  }

  if (lastIndex < widget.controller.text.length) {
    spans.add(TextSpan(
      text: widget.controller.text.substring(lastIndex),
      style: normalStyle,
    ));
  }

  splitText.value = spans;
}


  @override
  void initState() {
    super.initState();
    splitText = ValueNotifier<List<TextSpan>>([]);

    highlightStyle = widget.textStyle.copyWith(color: widget.keywordColor, letterSpacing: 0.5);
    normalStyle = widget.textStyle.copyWith(color: widget.textColor, letterSpacing: 0.5);

    _verticalScrollController = ScrollController();
    _lineNumbersScrollController = ScrollController();

    _verticalScrollController.addListener(_syncScrolls);
    widget.controller.addListener(_handleControllerChange);
    widget.controller.textController.addListener(_handleTextChange);
  }

  void _syncScrolls() {
    if (_lineNumbersScrollController.hasClients && _verticalScrollController.hasClients) {
      if (_lineNumbersScrollController.offset != _verticalScrollController.offset) {
        _lineNumbersScrollController.jumpTo(_verticalScrollController.offset);
      }
    }
  }

  @override
  void didUpdateWidget(covariant WeSqlCodeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    highlightKeywords();
  }

  @override
  void dispose() {
    _verticalScrollController.removeListener(_syncScrolls);
    _verticalScrollController.dispose();
    _lineNumbersScrollController.dispose();
    widget.controller.removeListener(_handleControllerChange);
    widget.controller.textController.removeListener(_handleTextChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _handleControllerChange() {
    if (mounted) {
      highlightKeywords();
      setState(() {});
    }
  }

  void _handleTextChange() {
    if (mounted) {
      _updateActiveLineByCursor();
      highlightKeywords();
      setState(() {});
    }
  }

  void _updateActiveLineByCursor() {
    final text = widget.controller.text;
    final selection = widget.controller.textController.selection;
    if (!selection.isValid) return;

    final cursorOffset = selection.baseOffset.clamp(0, text.length);
    final textBeforeCursor = text.substring(0, cursorOffset);
    final lineIndex = '\n'.allMatches(textBeforeCursor).length;

    widget.controller.setActiveLine(lineIndex);
  }

  void _moveCursorToLine(int lineIndex) {
    final lines = widget.controller.text.split('\n');
    int charIndex = 0;
    for (int i = 0; i < lineIndex && i < lines.length; i++) {
      charIndex += lines[i].length + 1;
    }
    final clampedOffset = charIndex.clamp(0, widget.controller.text.length);
    widget.controller.textController.selection = TextSelection.collapsed(offset: clampedOffset);
    widget.controller.setActiveLine(lineIndex);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final lines = widget.controller.text.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;
    
    //НЕ РАБОТАЕТ
    /*
    final painter = TextPainter(
      text: TextSpan(text: 'Hg', style: widget.textStyle),
      textDirection: TextDirection.ltr,
    )..layout();
    final lineHeight = widget.textStyle.height == null ? painter.height * 1.5 : painter.height * widget.textStyle.height!;
    */

    double maxLineWidth = 0;
    for (final line in lines) {
      final linePainter = TextPainter(
        text: TextSpan(text: line.isEmpty ? ' ' : line, style: widget.textStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      if (linePainter.width > maxLineWidth) {
        maxLineWidth = linePainter.width;
      }
    }

    return Localizations(
      locale: const Locale('en', 'US'),
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: Material(
        color: Colors.transparent,
        child: Container(
          color: Colors.transparent,
          alignment: Alignment.topCenter,
          child: LayoutBuilder(
            builder: (context, con) {
              final editorWidth = maxLineWidth < con.maxWidth - 12 
                  ? con.maxWidth - 12 
                  : maxLineWidth + 50;

              return SizedBox(
                width: con.maxWidth,
                child: InteractiveViewer(
                  maxScale: 1,
                  minScale: 1,
                  boundaryMargin: EdgeInsets.zero,
                  constrained: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [ 
                      SizedBox(
                        width: 35,
                        child: Column(
                          children: [
                            for (int i = 0; i < lineCount; i++) 
                              Text(
                                '${i + 1}', 
                                style: widget.textStyle.copyWith(color: widget.lineNumberColor),
                              ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: editorWidth,
                        child: Stack(
                          alignment: .topLeft,
                          fit: .loose,
                          children: [
                            Positioned(
                              child: ValueListenableBuilder(
                                valueListenable: splitText, 
                                builder: (context, value, child) {
                                  return RichText(
                                    text: TextSpan(
                                      children: [
                                        for (TextSpan i in value) i
                                      ]
                                    )
                                  );
                                }
                              )
                            ),
                            Positioned(
                              child: TextField(
                              controller: widget.controller.textController,
                              focusNode: _focusNode,
                              maxLines: null,
                              style: widget.textStyle.copyWith(color: Colors.transparent, letterSpacing: 0.5),
                              cursorColor: widget.textColor,
                              onChanged: (value) {  
                                widget.controller.text = value;
                              },
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            )
                          ],
                        )
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}