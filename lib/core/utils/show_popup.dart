import 'package:flutter/material.dart';

void showPopup(BuildContext context, String content) {
  showDialog(
    //TODO: make more beautiful
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Notification'),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
