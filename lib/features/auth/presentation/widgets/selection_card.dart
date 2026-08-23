import 'package:flutter/material.dart';

class SelectionCard extends StatelessWidget {
  final String titlePrimary;
  final String titleSecondary;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectionCard({
    super.key,
    required this.titlePrimary,
    required this.titleSecondary,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected
            ? Theme.of(context).colorScheme.primaryContainer
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.grey[700],
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titlePrimary,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '($titleSecondary)',
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 32,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
