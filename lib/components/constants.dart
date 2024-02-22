import 'package:flutter/material.dart';

const letterColors = Colors.black;
const mainColor = Color.fromARGB(244, 138, 118, 198);
const secondaryColor = Colors.indigo;

// ? Colors end ==========================================

const hintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

const labelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

var boxDecorationStyle = BoxDecoration(
  color: const Color(0xFF6CA8F1),
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: const [
    BoxShadow(
      color: Colors.black12,
      blurRadius: 6.0,
      offset: Offset(0, 2),
    ),
  ],
);

// * LoginPage Start ==========================================

var errortxtstyle = const TextStyle(
  fontWeight: FontWeight.bold,
  color: Colors.red,
  letterSpacing: 1,
  fontSize: 18,
);
var txtstyle = const TextStyle(
  fontWeight: FontWeight.bold,
  letterSpacing: 2,
  fontSize: 38,
);

// ? LoginPage End ============================================

// * PostList Start ===========================================

var nameTxtStyle = const TextStyle(
  fontWeight: FontWeight.bold,
  fontSize: 16,
);

// ? PostLIst end =============================================
