import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget getTextTheme(
    BuildContext context,
    String text,
    int position,
    double height,
    String fontFamily,
    Color fontColor,
    double fontSize,
    bool isSharingText,
    FontWeight fontWeight) {
  switch (position) {
    case 30:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /7 : height / 5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 29:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /3.5 : height / 2.5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 2:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /3.5 : height / 2.5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 3:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 3,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 4:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 3,
        right: 10.0,
        child: Text(text,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 5:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /3.5 : height / 2.5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 6:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 :  height / 2.7,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 7:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /5.3 : height / 4.5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 9:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 2.9,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 10:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /6.5 : height / 5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 11:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 12:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /8 : height / 7,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.start,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 13:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4.3 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 15:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /3.7 : height / 2.5,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 16:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /5.5 : height / 4,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 18:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /7 : height / 5,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 19:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4.5 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 20:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4.5 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 21:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 2.6,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 22:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /6.5 : height / 5,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 23:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /7.5 : height / 6,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 24:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4.6 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 25:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4.5 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: fontColor)),
      );
    case 26:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /8.5 : height / 7,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 27:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 2.5,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: fontColor)),
      );
    case 28:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 2.5,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 1:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4.5 : height / 3,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
    case 0:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /4 : height / 2.5,
        right: 20.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: fontColor)),
      );
    default:
      return Positioned(
        left: 20.0,
        top: isSharingText ? height /6.5 : height / 5,
        right: 10.0,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: GoogleFonts.getFont(fontFamily).fontFamily,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: fontColor)),
      );
  }
}
