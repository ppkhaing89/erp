import 'package:flutter/cupertino.dart';
import 'package:styled_text/tags/styled_text_tag.dart';
import 'package:styled_text/widgets/styled_text.dart';

class ERPSearchBox extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;
  final Function onTap;

  const ERPSearchBox({
    super.key,
    required this.label,
    required this.controller,
    this.isRequired = false,
    required this.onTap, // Add this parameter
  });

  @override
  State<ERPSearchBox> createState() => _ERPSearchBoxState();
}

class _ERPSearchBoxState extends State<ERPSearchBox> {
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
        const SizedBox(height: 3.0),
        CupertinoTextField(
          controller: widget.controller,
          readOnly: true,
          onTap: () {
            widget.onTap();
          },
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          style: const TextStyle(fontSize: 14.0),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          placeholder: 'Browse',
          placeholderStyle: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14.0,
          ),
          suffix: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(
              CupertinoIcons.arrow_right_circle,
              color: CupertinoColors.systemBlue,
              size: 24.0,
            ),
          ),
        ),
      ],
    );
  }
}
