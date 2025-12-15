import 'package:flutter/cupertino.dart';

class Message {
  void showErrorDialog(context, message) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.of(context).pop(); // close the dialog safely
            },
            child: const DefaultTextStyle(
              style: TextStyle(
                color: Color(0xFF00A8A8), // ← change this to any color you want
                fontWeight: FontWeight.bold,
              ),
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void showMessageDialog(context, message) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Message'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const DefaultTextStyle(
              style: TextStyle(
                color: Color(0xFF00A8A8), // ← change this to any color you want
                fontWeight: FontWeight.bold,
              ),
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void showSuccessDialog(context, message) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const DefaultTextStyle(
              style: TextStyle(
                color: Color(0xFF00A8A8), // ← change this to any color you want
                fontWeight: FontWeight.bold,
              ),
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void showSuccessDialogWithFunction(context, message, Function fnc) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => {Navigator.pop(context), fnc()},
            child: const DefaultTextStyle(
              style: TextStyle(
                color: Color(0xFF00A8A8), // ← change this to any color you want
                fontWeight: FontWeight.bold,
              ),
              child: Text('OK'),
            ),
          ),
        ],
      ),
    );
  }

  void showConfirmDialog(BuildContext context, String message, Function callback) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Confirm'),
        content: Text(message),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              //callback(context, 0); // Pass the callback to handle the action
            },
            child: const DefaultTextStyle(
              style: TextStyle(
                color: Color(0xFF00A8A8), // ← change this to any color you want
                fontWeight: FontWeight.bold,
              ),
              child: Text('Cancel'),
            ),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
              callback(); // Pass the callback to handle the action
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
