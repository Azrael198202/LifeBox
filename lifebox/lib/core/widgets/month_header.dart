import 'package:flutter/material.dart';

class MonthHeader extends StatelessWidget {
  const MonthHeader({
    super.key,
    required this.month,
    required this.onPrev,
    required this.onNext,
    required this.onPick,
  });

  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final Future<void> Function() onPick;

  @override
  Widget build(BuildContext context) {
    final title = '${month.year} / ${month.month.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
      child: Row(
        children: [
          IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
          Expanded(
            child: Center(
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onPick(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.expand_more,
                          size: 18, color: Colors.black.withOpacity(0.55)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}