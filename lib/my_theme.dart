import 'package:flutter/material.dart';

class MyTheme{
  /*configurable colors stars*/
  static Color accent_color = Color(0xff670099);
  static Color accent_color_shadow = Color.fromRGBO(229, 0, 13 , .15); // this color is a dropshadow of
  static Color soft_accent_color = Color(0xffca76ff).withOpacity(.2);
  static Color secondary_color = Color(0xfff9d802).withOpacity(.9);
  static Color splash_screen_color = Color(0xff670099); // if not sure , use the same color as accent color
  /*configurable colors ends*/
  static Color danger = Colors.redAccent;

  /*If you are not a developer, do not change the bottom colors*/
  static Color white = Color.fromRGBO(255,255,255, 1);
  static Color noColor = Color.fromRGBO(255,255,255, 0);
  static Color light_grey = Color.fromRGBO(239,239,239, 1);
  static Color light_bg = Color(0xfff4f3fa);
  static Color dark_grey = Color.fromRGBO(107,115,119, 1);
  static Color medium_grey = Color.fromRGBO(167,175,179, 1);
  static Color medium_grey_50 = Color.fromRGBO(167,175,179, .5);
  static Color grey_153 = Color.fromRGBO(153,153,153, 1);
  static Color dark_font_grey = Color.fromRGBO(62,68,71, 1);
  static Color font_grey = Color.fromRGBO(107,115,119, 1);
  static Color textfield_grey = Color.fromRGBO(209,209,209, 1);
  static Color golden = Color.fromRGBO(255, 168, 0, 1);
  static Color amber = Color.fromRGBO(254, 234, 209, 1);
  static Color golden_shadow = Color.fromRGBO(255, 168, 0, .4);
  static Color shimmer_base = Colors.grey.shade50;
  static Color shimmer_highlighted = Colors.grey.shade200;


  //testing shimmer
  /*static Color shimmer_base = Colors.redAccent;
  static Color shimmer_highlighted = Colors.yellow;*/



}