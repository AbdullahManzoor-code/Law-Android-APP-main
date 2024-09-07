import 'package:flutter/material.dart';
import 'package:law_app/components/Email/send_email_emailjs.dart';
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
    _webViewController = WebViewController();
     
  }

  @override
  Widget build(BuildContext context) {
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onUrlChange: (change) {
            if (change.url == "https://zcal.co/i/7HMuXETO/done") {
                                                        showToast(message: "Event sucessfully added ");

              Navigator.pop(context);
            }
          },
          onPageStarted: (String url) {
            
          },
          onPageFinished: (String url) {},
          onHttpError: (HttpResponseError error) {
            showToast(message: error.toString());
          },
          onWebResourceError: (WebResourceError error) {
            showToast(message: "${error.toString()}");
          },
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
