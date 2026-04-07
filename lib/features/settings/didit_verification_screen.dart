import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:greyfundr/components/custom_app_bar.dart';
import 'package:greyfundr/core/providers/user_provider.dart';
import 'package:http/http.dart' as http; 
import 'package:provider/provider.dart';

class DiditVerificationScreen extends StatefulWidget {
  
  final String sessionUrl;
  const DiditVerificationScreen({
    super.key,
    required this.sessionUrl,
  });

  @override
  State<DiditVerificationScreen> createState() =>
      _DiditVerificationScreenState();
}

class _DiditVerificationScreenState extends State<DiditVerificationScreen> {
  final GlobalKey webViewKey = GlobalKey();
  InAppWebViewController? webViewController;
  UserProvider? userProvider;

  InAppWebViewSettings settings = InAppWebViewSettings(
    userAgent:
        "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36",
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      userProvider = Provider.of<UserProvider>(context, listen: false);

     });
  }
 

  void handleTransactionCheck(String url) {
    setState(() {});
    if (url.contains("didit/session/success")) {
      Get.close(1);
      
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Identity Verification"),
      body: Stack(
        children: [
          if (widget.sessionUrl.isNotEmpty)
            InAppWebView(
              key: webViewKey,
              initialUrlRequest: URLRequest(url: WebUri(widget.sessionUrl)),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onPermissionRequest: (controller, request) async {
                log('Permission requested: ${request.resources}');
                return PermissionResponse(
                  resources: request.resources,
                  action: PermissionResponseAction.GRANT,
                );
              },
              onLoadStop: (controller, url) {
                log('Page loaded: $url');
                handleTransactionCheck(url?.toString() ?? '');
              },
              onUpdateVisitedHistory: (controller, url, isReload) {
                log('Visited history updated: $url');
                handleTransactionCheck(url.toString());
              },
              onLoadError: (controller, url, code, message) {
                log('Load error: $code - $message');
              },
            ),
          // if (_isLoading)
          //   const Center(
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         CircularProgressIndicator(),
          //         SizedBox(height: 16),
          //         Text('Preparing verification session...'),
          //       ],
          //     ),
          //   ),
        ],
      ),
    );
  }
}
