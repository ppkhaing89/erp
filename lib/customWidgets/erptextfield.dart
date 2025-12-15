import 'package:flutter/cupertino.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

class ERPTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool disabled;
  final bool isRequired;
  const ERPTextField(
      {super.key,
      required this.label,
      required this.controller,
      required this.disabled,
      this.isRequired = false});

  @override
  State<ERPTextField> createState() => _ERPTextFieldState();
}

class _ERPTextFieldState extends State<ERPTextField> {
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
          padding: const EdgeInsets.symmetric(
              vertical: 8.0, horizontal: 16.0), // Adjust padding
          style: const TextStyle(fontSize: 14.0), // Adjust font size
          decoration: BoxDecoration(
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
