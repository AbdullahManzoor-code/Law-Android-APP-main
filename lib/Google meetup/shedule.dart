import 'package:flutter/material.dart';
import 'package:law_app/components/common/timer.dart';
import 'package:law_app/components/toaster.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SchedulMeeting extends StatefulWidget {
  @override
  State<SchedulMeeting> createState() => _SchedulMeetingState();
}

class _SchedulMeetingState extends State<SchedulMeeting> {
  String webUrl = "https://zcal.co/i/7HMuXETO";
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url == "https://zcal.co/i/7HMuXETO/done") {
              Navigator.pop(context);

            }
          },
          onUrlChange: (change) {
            if (change == "https://zcal.co/i/7HMuXETO/done") {
                            showToast(message: "Event sucessfully added ");

              Navigator.pop(context);
            }
          },
          onPageFinished: (String url) {
            // Check the URL and navigate back if it matches
            if (url == "https://zcal.co/i/7HMuXETO/done") {
              Navigator.pop(context);
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url == "https://zcal.co/i/7HMuXETO/done") {
              Navigator.pop(context);
              return NavigationDecision.prevent; // Prevent further navigation
            }
            if (request == "https://zcal.co/i/7HMuXETO/done") {
              Navigator.pop(context);
            }
            return NavigationDecision.navigate; // Allow the navigation
          },
        ),
      )
      ..loadRequest(Uri.parse(webUrl));
  }

  @override
  Widget build(BuildContext context) {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onUrlChange: (change) {
            if (change.url == "https://zcal.co/i/7HMuXETO/done") {
              Navigator.pop(context);
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {},
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(webUrl));
    return SafeArea(
      child: IdleTimeoutWrapper(
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Schedule Meeting'),
          ),
          body: WebViewWidget(
            controller: _webViewController,
          ),
        ),
      ),
    );
  }
}
