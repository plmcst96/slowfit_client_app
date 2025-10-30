import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class DeleteConfirmationDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onConfirm;

  const DeleteConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: Column(
        children: [
          Image.asset(
            'assets/loghi/logo1.3.png',
            width: 150,
          ),
          SizedBox(
            height: 15,
          ),
          Text(
            title,
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            AppLocalizations.of(context)!.cancel,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Color(0XFFC4B7E1)),
          onPressed: () {
            onConfirm();
            Navigator.of(context).pop();
          },
          child: Text(
            AppLocalizations.of(context)!.confirm,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
