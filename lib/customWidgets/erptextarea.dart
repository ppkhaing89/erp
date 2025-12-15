import 'package:flutter/cupertino.dart';
import 'package:styled_text/styled_text.dart';

class ERPTextArea extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool disabled;
  final int maxlines;
  final bool isRequired;

  final dynamic labelwidget;
  const ERPTextArea(
      {super.key,
      required this.label,
      required this.controller,
      required this.disabled,
      required this.maxlines,
      this.isRequired = false, this.labelwidget});

  @override
  State<ERPTextArea> createState() => _ERPTextAreaState();
}

class _ERPTextAreaState extends State<ERPTextArea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            StyledText(
              text: widget.isRequired
                  ? '<bold>${widget.label}<red> *</red></bold>'
                  : '<bold>${widget.label}<bold>',
              tags: {
                'red': StyledTextTag(
                    style: const TextStyle(color: CupertinoColors.systemRed)),
                'bold': StyledTextTag(
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
              },
            )
          ],
        ),
        const SizedBox(height: 3.0), // Add spacing between row and text field
        CupertinoTextField(
          controller: widget.controller,
          enabled: !widget.disabled,
          maxLines: widget.maxlines,
          padding: const EdgeInsets.symmetric(
              vertical: 8.0, horizontal: 16.0), // Adjust padding
          style: const TextStyle(
            fontSize: 14.0,
          ), // Adjust font size
          decoration: BoxDecoration(
             color: widget.disabled ? CupertinoColors.systemGrey5 : CupertinoColors.white,
             border: Border.all(color: CupertinoColors.systemGrey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0), // Increase border radius  
          ), 
          placeholder: 'Enter text', // Provide a placeholder for better context
          placeholderStyle: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
