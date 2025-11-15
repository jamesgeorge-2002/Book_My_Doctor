import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book My Doctor',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const WebViewScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) async {
            final uri = Uri.parse(request.url);

            // Handle WhatsApp
            if (request.url.contains("wa.me") ||
                request.url.startsWith("whatsapp://")) {
              if (mounted) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
              return NavigationDecision.prevent;
            }

            // Handle phone dialer, email, external links
            if (uri.scheme == "tel" ||
                uri.scheme == "mailto" ||
                uri.scheme == "intent") {
              if (mounted) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }

            // Handle intent:// links
            if (request.url.startsWith("intent://")) {
              final fallbackUrl = request.url.split("S.browser_fallback_url=")[1]
                  .split(";")[0];

              final decodedUrl = Uri.decodeComponent(fallbackUrl);

              if (mounted) {
                await launchUrl(
                  Uri.parse(decodedUrl),
                  mode: LaunchMode.externalApplication,
                );
              }
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://pulmomedicalcentre.com/booking_doctor.php'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book My Doctor'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}