import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:styled_text/styled_text.dart';

class ERPDatetimepicker extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final bool isRequired;

  const ERPDatetimepicker(
      {super.key,
      required this.label,
      required this.controller,
      this.isRequired = false});

  @override
  State<ERPDatetimepicker> createState() => _ERPDatetimepickerState();
}

class _ERPDatetimepickerState extends State<ERPDatetimepicker> {
  DateTime selectedDateTime =
      DateTime.now(); // Initialize with current date and time

// Function to show the date and time picker
  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 300.0,
          color: CupertinoColors.white,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: selectedDateTime,
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                selectedDateTime = newDateTime;
                final formattedDateTime =
                    DateFormat('dd MMM yyyy hh:mm a').format(newDateTime);
                widget.controller.text = formattedDateTime;
              });
            },
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
          readOnly: true,
          onTap: () {
            _showDatePicker();
          },
          padding: const EdgeInsets.symmetric(
              vertical: 8.0, horizontal: 16.0), // Adjust padding
          style: const TextStyle(fontSize: 14.0), // Adjust font size
          decoration: BoxDecoration(
            border: Border.all(color: CupertinoColors.systemGrey, width: 1.0),
            borderRadius: BorderRadius.circular(8.0), // Increase border radius
          ),
          placeholder:
              'Select Date', // Provide a placeholder for better context
          placeholderStyle: const TextStyle(
            color: CupertinoColors.systemGrey,
            fontSize: 14.0,
          ),
          suffix: const Padding(
            padding: EdgeInsets.only(right: 8.0),
            child: Icon(
              CupertinoIcons.calendar,
              color: CupertinoColors.systemBlue,
              size: 24.0,
            ),
          ),
        ),
      ],
    );
  }
}
