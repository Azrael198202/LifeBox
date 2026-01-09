import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cb = (enabled && !loading) ? onPressed : null;

    return FilledButton(
      onPressed: cb,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Icon(icon, size: 18),
            ),
          Text(label),
        ],
      ),
    );
  }
}
