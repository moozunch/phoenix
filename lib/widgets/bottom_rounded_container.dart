import 'package:flutter/material.dart';

class BottomRoundedContainer extends StatelessWidget {
  final Widget child;
  final double? height;
  final EdgeInsetsGeometry padding;

  const BottomRoundedContainer({
    super.key,
    required this.child,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
  });

  @override
  Widget build(BuildContext context) {
    // final double computedHeight = height ?? MediaQuery.of(context).size.height * 0.55;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
