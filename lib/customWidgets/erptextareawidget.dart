import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ERPTextAreaWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool disabled;
  final int maxlines;
  final bool isRequired;

  final dynamic labelwidget;

  const ERPTextAreaWidget(
      {super.key,
      required this.label,
      required this.controller,
      required this.disabled,
      required this.maxlines,
      this.isRequired = false,
      this.labelwidget});

  @override
  State<ERPTextAreaWidget> createState() => _ERPTextAreaState();
}

class _ERPTextAreaState extends State<ERPTextAreaWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(8.0),
              ),
              width: 32, // Set a fixed width
              height: 32, // Set a fixed height
              child: const Center(
                child: Icon(
                  CupertinoIcons.chat_bubble,
                  color: Colors.white,
                  size: 20, // Optional: control icon size
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.label,
              style:
                  const TextStyle(fontSize: 14.0),
            ),
          ],
        ),

        const SizedBox(height: 10.0), // Add spacing between row and text field
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
            color: widget.disabled
                ? CupertinoColors.systemGrey5
                : CupertinoColors.white,
            border: Border.all(color: const Color.fromARGB(255, 188, 186, 186), width: 1.0),
            borderRadius: BorderRadius.circular(8.0), // Increase border radius
          ),
          placeholder: '', // Provide a placeholder for better context
          placeholderStyle: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14.0,
          ),
        ),
      ],
    );
  }
}
