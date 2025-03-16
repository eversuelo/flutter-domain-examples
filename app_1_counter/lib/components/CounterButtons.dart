

// ignore_for_file: file_names

import 'package:flutter/material.dart';
class CounterButton extends FloatingActionButton {
  @override
  final VoidCallback onPressed;
  final IconData iconData;
  CounterButton({super.key, required this.onPressed, required this.iconData}) : super(onPressed: onPressed, child: Icon(iconData));
}
class Buttons extends Column{ 
  @override
  final MainAxisAlignment mainAxisAlignment;
  @override
  final List<Widget> children;  

  const Buttons({required this.mainAxisAlignment, required this.children, super.key}) : super(mainAxisAlignment: mainAxisAlignment, children: children,spacing: 10);
}