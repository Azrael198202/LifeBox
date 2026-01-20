import 'package:flutter/material.dart';

class InviteMethodIcon extends StatelessWidget {
  const InviteMethodIcon({
    super.key,
    this.icon,
    this.leading,
    required this.label,
    required this.onTap,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.black12.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: leading ?? Icon(icon, size: 28),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
