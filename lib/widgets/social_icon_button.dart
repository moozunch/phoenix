import 'package:flutter/material.dart';

class SocialIconButton extends StatelessWidget {
  const SocialIconButton({super.key, this.onPressed, required this.child});

  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onPressed,
      child: Container(
        height: 40,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black26),
          color: Colors.white,
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
          child: child,
        ),
      ),
    );
  }
}
