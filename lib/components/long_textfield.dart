import 'package:flutter/material.dart';

class MyLongTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final IconData icon;

  //colors
  Color? borderSideColor;
  Color? focusedBorderColor;
  Color? hintTextColor;
  Color? iconColor;
  Color? cursorColor;

  int? borderRadiusPixel;

  MyLongTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.icon,
    this.borderSideColor,
    this.focusedBorderColor,
    this.hintTextColor,
    this.iconColor,
    this.cursorColor,
    this.borderRadiusPixel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      // * the only difference between a normal textfield.
      // ! caution: may cause overflow errors
      maxLines: null,
      decoration: InputDecoration(
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
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
