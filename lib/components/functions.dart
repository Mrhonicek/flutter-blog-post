import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

goToPage(context, page) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => page,
    ),
  );
}

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  String formattedDate = "${dateTime.day.toString().padLeft(2, '0')}/"
      "${dateTime.month.toString().padLeft(2, '0')}/"
      "${dateTime.year}";

  String period = (dateTime.hour >= 12) ? 'PM' : 'AM';
  int hour = (dateTime.hour % 12 == 0) ? 12 : dateTime.hour % 12;
  String formattedTime = "${hour.toString().padLeft(2, '0')}:"
      "${dateTime.minute.toString().padLeft(2, '0')} $period";

  return "$formattedDate at $formattedTime";
}

String formatSimpleTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  String day = DateFormat('EEE').format(dateTime);
  String time = DateFormat('h:mm a').format(dateTime);
  return '$day at $time';
}

String formatChatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();

  String formattedDate = _getFormattedDate(dateTime);

  String formattedTime = _getFormattedTime(dateTime);

  return "$formattedDate at $formattedTime";
}

String _getFormattedDate(DateTime dateTime) {
  String month = _getMonthName(dateTime.month);
  String day = dateTime.day.toString();

  return "$month $day, ${dateTime.year}";
}

String _getMonthName(int month) {
  const monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  return monthNames[month - 1];
}

String _getFormattedTime(DateTime dateTime) {
  String period = (dateTime.hour >= 12) ? 'pm' : 'am';
  int hour = (dateTime.hour > 12) ? dateTime.hour - 12 : dateTime.hour;
  String formattedTime = "${hour.toString().padLeft(2, '0')}:"
      "${dateTime.minute.toString().padLeft(2, '0')} $period";

  return formattedTime;
}

// Function to format timestamp as "MM/dd/yyyy at hh:mm a"
String formatTimestampWithTimerDisplayDelay(
    DateTime timestamp, int delayInSeconds) {
  int secondsDifference = DateTime.now().difference(timestamp).inSeconds;

  if (secondsDifference > delayInSeconds) {
    String day = DateFormat('EEE').format(timestamp);
    String time = DateFormat('h:mm a').format(timestamp);
    return '$day at $time';
  } else {
    return '';
  }
}

String formatCommentTimestamp(Timestamp timestamp) {
  DateTime commentTime = timestamp.toDate();
  DateTime now = DateTime.now();
  Duration difference = now.difference(commentTime);

  if (difference.inSeconds < 60) {
    return 'Just Now';
  } else if (difference.inMinutes == 1) {
    return '1 min ago';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} mins ago';
  } else if (difference.inHours == 1) {
    return '1 hour ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays == 1) {
    return '1 day ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 14) {
    return '1 week ago';
  } else if (difference.inDays < 30) {
    int weeks = (difference.inDays / 7).floor();
    return '$weeks weeks ago';
  } else if (difference.inDays < 60) {
    return '1 month ago';
  } else if (difference.inDays < 365) {
    int months = (difference.inDays / 30).floor();
    return '$months months ago';
  } else if (difference.inDays < 730) {
    return '1 year ago';
  } else {
    int years = (difference.inDays / 365).floor();
    return '$years years ago';
  }
}

String generateRandomImageName(int length) {
  var r = Random();
  const _chars =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  return List.generate(length, (index) => _chars[r.nextInt(_chars.length)])
      .join();
}
