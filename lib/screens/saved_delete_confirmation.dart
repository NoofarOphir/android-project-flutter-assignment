import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(BuildContext context, pair) {
  return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Suggestion'),
          content: Text('Are you sure you want to delete ' + pair + ' from saved suggestions?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              style: TextButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: Text(
                'No',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimary
                ),
              ),
            ),
          ],
        );
      }
  );
}