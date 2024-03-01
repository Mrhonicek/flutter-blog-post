import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData icon;
  final ValueChanged<String>? onChanged; // Callback for onChanged
  final Widget? suffixIcon;
  FocusNode? focusNode;

  //colors
  Color? borderSideColor;
  Color? focusedBorderColor;
  Color? hintTextColor;
  Color? iconColor;
  Color? cursorColor;
  Color? textColor;

  int? borderRadiusPixel;

  MyTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    this.focusNode,
    this.borderSideColor,
    this.focusedBorderColor,
    this.hintTextColor,
    this.iconColor,
    this.cursorColor,
    this.textColor,
    this.borderRadiusPixel,
    this.onChanged,
    this.suffixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: (borderSideColor != null)
                ? borderSideColor!
                : Theme.of(context).colorScheme.tertiary,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: (focusedBorderColor != null)
                ? focusedBorderColor!
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
        labelText: hintText,
        labelStyle: TextStyle(
          color: (hintTextColor != null)
              ? hintTextColor!
              : Theme.of(context).colorScheme.secondary,
        ),
        prefixIcon: Icon(
          icon,
          color: (iconColor != null)
              ? iconColor!
              : Theme.of(context).colorScheme.secondary,
        ),
      ),
      cursorColor: (cursorColor != null)
          ? cursorColor!
          : Theme.of(context).colorScheme.secondary,
      style: TextStyle(
        color: (textColor != null)
            ? textColor!
            : Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
