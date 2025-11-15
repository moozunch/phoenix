import 'package:flutter/material.dart';

class LinedLabel extends StatelessWidget {
  const LinedLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context)
        .textTheme
        .labelMedium
        ?.copyWith(color: Colors.black54);
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(label, style: style),
        ),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}
