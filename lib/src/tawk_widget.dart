import 'dart:io';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'tawk_visitor.dart';

/// [Tawk] Widget.
class Tawk extends StatefulWidget {
  /// Tawk direct chat link.
  final String directChatLink;

  /// Object used to set the visitor name and email.
  final TawkVisitor? visitor;

  /// Called right after the widget is rendered.
  final Function? onLoad;

  /// Called when a link pressed.
  final Function(String)? onLinkTap;

  /// Render your own loading widget.
  final Widget? placeholder;

  /// Defines the delay in milliseconds before setting the visitor details.
  ///
  /// This property is used as a workaround to address a timing issue with the
  /// Tawk.to API where immediate setting of visitor details might not work as expected.
  /// Assigning a delay ensures that the visitor details are set only after the specified
  /// duration, allowing for any necessary initializations to complete.
  final int visitorDetailsDelayMs;

  const Tawk({
    Key? key,
    required this.directChatLink,
    this.visitor,
    this.onLoad,
    this.onLinkTap,
    this.placeholder,
    this.visitorDetailsDelayMs = 100,
  }) : super(key: key);

  @override
  _TawkState createState() => _TawkState();
}

class _TawkState extends State<Tawk> {
  late InAppWebViewController _controller;
  bool _isLoading = true;

  void _setUser(TawkVisitor visitor) {
    final json = jsonEncode(visitor.toJson());
    final String javascriptString;

    /// Tawk_API.onLoad unfortunately does not really work
    if (Platform.isIOS) {
      javascriptString = '''
        setTimeout(function() {
          Tawk_API = Tawk_API || {};
          Tawk_API.visitor = $json;
          console.log('hello');
          try {
              Tawk_API.setAttributes($json, (error) => {
              if (error) {
               console.log(error);
              }
            });
            } catch(e) {
              console.log(e);
          }
        }, ${widget.visitorDetailsDelayMs});
         
      ''';
    } else {
      javascriptString = '''
        Tawk_API = Tawk_API || {};
        Tawk_API.onLoad = async function() {
        setTimeout(function() {
          try {
            Tawk_API.setAttributes($json, (error) => {
            if (error) {
               console.log(error);
            }
          });
          } catch(e) {
            console.log(e);
          }
        }, ${widget.visitorDetailsDelayMs});
          
        };
      ''';
    }

    // if (Platform.isIOS) {
    //   javascriptString = '''
    //     Tawk_API = Tawk_API || {};
    //     Tawk_API.setAttributes($json, function(error) {
    //       console.log(error);
    //     });
    //   ''';
    // } else {
    //   javascriptString = '''
    //     Tawk_API = Tawk_API || {};
    //     Tawk_API.onLoad = async function() {
    //     setTimeout(function() {
    //       try {
    //         Tawk_API.setAttributes($json, (error) => {
    //         if (error) {
    //            console.log(error);
    //         }
    //       });
    //       } catch(e) {
    //         console.log(e);
    //       }
    //     }, ${widget.visitorDetailsDelayMs});
    //
    //     };
    //   ''';
    // }

    _controller.evaluateJavascript(source: javascriptString);
  }

  @override
  void initState() {
    super.initState();
  }

  void init() async {
    if (Platform.isAndroid) {
      await InAppWebViewController.setWebContentsDebuggingEnabled(false);

      var swAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_BASIC_USAGE);
      var swInterceptAvailable = await WebViewFeature.isFeatureSupported(
          WebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

      if (swAvailable && swInterceptAvailable) {
        ServiceWorkerController serviceWorkerController =
            ServiceWorkerController.instance();

        await serviceWorkerController
            .setServiceWorkerClient(ServiceWorkerClient(
          shouldInterceptRequest: (request) async {
            return null;
          },
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          gestureRecognizers: {}..add(Factory<VerticalDragGestureRecognizer>(
              () => VerticalDragGestureRecognizer())),
          initialUrlRequest:
              URLRequest(url: WebUri.uri(Uri.parse(widget.directChatLink))),
          onWebViewCreated: (webViewController) {
            setState(() {
              _controller = webViewController;
            });
          },
          onConsoleMessage: (controller, consoleMessage) {
            print("Tawk: ${consoleMessage.message}");
          },
          onLoadStop: (_, __) {
            init();
            if (widget.visitor != null) {
              _setUser(widget.visitor!);
            }

            if (widget.onLoad != null) {
              widget.onLoad!();
            }

            setState(() {
              _isLoading = false;
            });
          },
        ),
        _isLoading
            ? widget.placeholder ??
                const Center(
                  child: CircularProgressIndicator(),
                )
            : Container(),
      ],
    );
  }
}
