import 'package:flutter/cupertino.dart';

class ERPButton extends StatefulWidget {
  final String text;
  final IconData icon;
  final Function()? onPressed;
  final Color color;

  const ERPButton({
    super.key,
    required this.text,
    required this.icon,
    this.onPressed,
    required this.color, // Add this parameter
  });

  @override
  State<ERPButton> createState() => _ERPButtonState();
}

class _ERPButtonState extends State<ERPButton> {
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: widget.onPressed,
      color: widget.color,
      disabledColor: CupertinoColors.systemGrey,
      padding: const EdgeInsets.symmetric(
          vertical: 8.0, horizontal: 12.0), minimumSize: const Size(0, 0), // Reduce the minimum button size
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon),
          const SizedBox(width: 4.0), // Reduce the space between icon and text
          Text(
            widget.text,
            style: const TextStyle(fontSize: 14), // Adjust the font size
          ),
        ],
      ),
    );
  }
}
