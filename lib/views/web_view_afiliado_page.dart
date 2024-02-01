import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:receitas_de_pao/models/my_app/direct_link.dart';
import 'package:receitas_de_pao/models/produto_afiliado.dart';
import 'package:receitas_de_pao/routes/app_routes.dart';
import 'package:receitas_de_pao/services/share_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewAfiliadoPage extends StatefulWidget {
  DirectLink directLink;

  WebViewAfiliadoPage({this.directLink});
  @override
  State<WebViewAfiliadoPage> createState() => _WebViewAfiliadoPageState();
}

class _WebViewAfiliadoPageState extends State<WebViewAfiliadoPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  DirectLink get directLink => widget.directLink;
  ProdAfiliado get produto => directLink.produto;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.pink[700],
        title: Text(produto.descricao),
        actions: <Widget>[
          NavigationControls(
            webViewControllerFuture: _controller.future,
            directLink: directLink,
          ),
          GestureDetector(
            child: Icon(Icons.share),
            onTap: () {
              ShareReceitaService().shareProdutoAfiliado(produto);
            },
          ),
          SizedBox(width: 10)
        ],
      ),
      body: WebView(
        initialUrl: widget.directLink.url,
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          _controller.complete(webViewController);
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
      ),
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

class NavigationControls extends StatelessWidget {
  DirectLink directLink;
  final Future<WebViewController> webViewControllerFuture;
  NavigationControls({this.webViewControllerFuture, this.directLink})
      : assert(webViewControllerFuture != null);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: webViewControllerFuture,
      builder:
          (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady =
            snapshot.connectionState == ConnectionState.done;
        final WebViewController controller = snapshot.data;
        return Row(
          children: <Widget>[
            Container(
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: !webViewReady
                    ? null
                    : () async {
                        if (await controller.canGoBack()) {
                          await controller.goBack();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Não há páginas anteriores...')),
                          );
                          return;
                        }
                      },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller.canGoForward()) {
                        await controller.goForward();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Não há páginas posteriores...')),
                        );
                        return;
                      }
                    },
            ),
            IconButton(
              icon: Icon(Icons.help_outline_rounded),
              onPressed: !webViewReady
                  ? null
                  : () {
                      _showDialogHelp(context);
                    },
            ),
          ],
        );
      },
    );
  }

  _showDialogHelp(BuildContext context) {
    var dialog = AlertDialog(
      title: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(8),
                child: Text(
                  'Problemas ao acessar a página?',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.pink[900],
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: Container(
                height: 30,
                width: 30,
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                decoration: BoxDecoration(
                    color: Colors.pink[800],
                    borderRadius: BorderRadius.circular(50)),
              ),
            ),
          ],
        ),
      ),
      content: Row(
        children: [
          Flexible(
            child: Text(
              'Tente acessar pelo navegador:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context, rootNavigator: true).pop();
              launchUrl(Uri.parse(directLink.url),
                  mode: LaunchMode.externalApplication);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.login,
                  color: Colors.purple[900],
                  size: 35,
                ),
                Text(
                  'Acessar',
                  style: TextStyle(color: Colors.purple[900]),
                )
              ],
            ),
          )
        ],
      ),
    );
    showDialog(
        context: context, barrierDismissible: false, builder: (_) => dialog);
    return dialog;
  }
}
