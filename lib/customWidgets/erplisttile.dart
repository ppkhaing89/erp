import 'package:flutter/cupertino.dart';

class ERPListTile extends StatelessWidget {
  final Widget? leading; // Added leading parameter
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final Widget row1;
  final Widget? row2;
  final Widget? row3;
  final VoidCallback? onTap;

  const ERPListTile({
    super.key,
    this.leading,
    required this.title,
    required this.row1,
    this.row2,
    this.row3,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            if (leading != null) leading!, // Show leading if provided
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultTextStyle(
                    style: const TextStyle(
                      color: CupertinoColors.black,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
                    child: title,
                  ),
                  const SizedBox(height: 2.0),
                  if (subtitle != null) // Check if subtitle is not null
                    DefaultTextStyle(
                      style: const TextStyle(
                        color: CupertinoColors.systemGrey,
                        fontSize: 14.0,
                      ),
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            row1,
            if (row2 != null) row2!,
            if (row3 != null) row3!,
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
