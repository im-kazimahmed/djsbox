// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:google_fonts/google_fonts.dart';

// ignore: must_be_immutable
class MyText extends StatelessWidget {
  String text;
  double? fontsizeNormal, fontsizeWeb;
  var maxline, fontstyle, fontwaight, textalign;
  bool? inter, multilanguage;

  Color? color;
  var overflow;

  MyText(
      {Key? key,
      this.color,
      this.inter,
      required this.text,
      this.multilanguage,
      this.fontsizeNormal,
      this.fontsizeWeb,
      this.maxline,
      this.overflow,
      this.textalign,
      this.fontwaight,
      this.fontstyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return multilanguage == false
        ? Text(
            text,
            textAlign: textalign,
            overflow: TextOverflow.ellipsis,
            maxLines: maxline,
            style: inter == false
                ? GoogleFonts.roboto(
                    fontSize: (kIsWeb) ? fontsizeWeb : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontwaight)
                : GoogleFonts.inter(
                    fontSize: (kIsWeb) ? fontsizeWeb : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontwaight),
          )
        : LocaleText(
            text,
            textAlign: textalign,
            overflow: TextOverflow.ellipsis,
            maxLines: maxline,
            style: inter == false
                ? GoogleFonts.roboto(
                    fontSize: (kIsWeb) ? fontsizeWeb : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontwaight)
                : GoogleFonts.inter(
                    fontSize: (kIsWeb) ? fontsizeWeb : fontsizeNormal,
                    fontStyle: fontstyle,
                    color: color,
                    fontWeight: fontwaight),
          );
  }
}
