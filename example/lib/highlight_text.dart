import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  final String text;
  final String term;
  final TextStyle textStyle;
  final TextStyle textStyleHighlight;

  HighlightText(
    this.text, {
    this.term = '',
    this.textStyle = const TextStyle(
      color: Colors.black,
    ),
    this.textStyleHighlight = const TextStyle(
      backgroundColor: Colors.indigo,
    ),
  });

  @override
  Widget build(BuildContext context) {
    if (term?.isEmpty ?? true) {
      return Text(text, style: textStyle);
    } else {
      String termLC = term.toLowerCase();

      List<InlineSpan> children = [];
      List<String> spanList = text.toLowerCase().split(termLC);
      int i = 0;
      for (var v in spanList) {
        if (v.isNotEmpty) {
          children.add(
            TextSpan(text: text.substring(i, i + v.length), style: textStyle),
          );
          i += v.length;
        }
        if (i < text.length) {
          children.add(
            TextSpan(
                text: text.substring(i, i + term.length),
                style: textStyleHighlight),
          );
          i += term.length;
        }
      }
      return RichText(text: TextSpan(children: children));
    }
  }
}
