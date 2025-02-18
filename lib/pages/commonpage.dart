import 'dart:developer';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:yourappname/utils/color.dart';

class Commonpage extends StatefulWidget {
  final String url, title;
  final bool multilanguage;
  const Commonpage({
    super.key,
    required this.url,
    required this.title,
    required this.multilanguage,
  });

  @override
  State<Commonpage> createState() => CommonpageState();
}

class CommonpageState extends State<Commonpage> {
  final GlobalKey webViewKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    log("URL===> ${widget.url}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar:
          Utils().otherPageAppBar(context, widget.title, widget.multilanguage),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              onLoadStart: (controller, url) {},
              onLoadStop: (controller, url) {},
              key: webViewKey,
              initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
            ),
          ),
        ],
      ),
    );
  }
}
