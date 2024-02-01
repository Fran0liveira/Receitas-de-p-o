import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:receitas_de_pao/models/my_app/direct_link.dart';
import 'package:receitas_de_pao/models/my_app/direct_link.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewAfiliadoLayout extends StatefulWidget {
  DirectLink directLink;
  Completer<WebViewController> controller;
  WebViewAfiliadoLayout({this.directLink, this.controller});

  @override
  State<WebViewAfiliadoLayout> createState() => _WebViewAfiliadoLayoutState();
}

class _WebViewAfiliadoLayoutState extends State<WebViewAfiliadoLayout> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.directLink.url,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        widget.controller.complete(webViewController);
      },
      onProgress: (int progress) {
        print('WebView is loading (progress : $progress%)');
      },
      javascriptChannels: <JavascriptChannel>{
        _toasterJavascriptChannel(context),
      },
      navigationDelegate: (NavigationRequest request) {
        if (request.url.startsWith('https://www.youtube.com/')) {
          print('blocking navigation to $request}');
          return NavigationDecision.prevent;
        }
        print('allowing navigation to $request');
        return NavigationDecision.navigate;
      },
      onPageStarted: (String url) {
        print('Page started loading: $url');
      },
      onPageFinished: (String url) {
        print('Page finished loading: $url');
      },
      gestureNavigationEnabled: true,
      backgroundColor: const Color(0x00000000),
    );
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}
