import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String titlePrimary;
  final String titleSecondary;
  final VoidCallback onPressed;
  final bool isEnabled;

  const PrimaryButton({
    super.key,
    required this.titlePrimary,
    required this.titleSecondary,
    required this.onPressed,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(titlePrimary, style: const TextStyle(fontSize: 22)),
          Text(
            '($titleSecondary)',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }
}
