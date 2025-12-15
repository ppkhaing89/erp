import 'package:flutter/cupertino.dart';

class ERPSelectBox extends StatefulWidget {
  final String label;
  final String title;
  final TextEditingController controller;
  final dynamic options;
  final String value;

  const ERPSelectBox({
    super.key,
    required this.label,
    required this.title,
    required this.controller,
    required this.options,
    required this.value, // Add this parameter
  });

  @override
  State<ERPSelectBox> createState() => _ERPSelectBoxState();
}

class _ERPSelectBoxState extends State<ERPSelectBox> {
  void _showOptionsSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: Text(widget.title),
          actions: widget.options.map<Widget>((option) {
            return CupertinoActionSheetAction(
              onPressed: () {
                setState(() {
                  widget.controller.text =
                      option[widget.value]; // Update the text field value
                });
                Navigator.pop(context);
              },
              child: Text(
                option[widget.value],
              ),
            );
          }).toList(),
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Cancel', // Adjust the font size as needed
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.0),
        CupertinoTextField(
          controller: widget.controller,
          readOnly: true,
          onTap: () {
            _showOptionsSheet(context);
          },
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          style: const TextStyle(fontSize: 14.0),
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          placeholder: 'Select',
          placeholderStyle: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14.0,
          ),
          suffix: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(
              CupertinoIcons.arrowtriangle_down_circle,
              color: CupertinoColors.systemBlue,
              size: 24.0,
            ),
          ),
        ),
      ],
    );
  }
}
