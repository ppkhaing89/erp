import 'package:flutter/material.dart';

Widget erpBGIcon({
  required Widget icon,
  required Color backgroundcolor,
}) {
  return Container(
    decoration: BoxDecoration(
      color: backgroundcolor,
      borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
    ),
    width: double.infinity,
    height: double.infinity,
    child: Center(child: icon),
  );
}
