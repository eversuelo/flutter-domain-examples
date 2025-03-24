import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import '../../../routes.dart';
import '../services/auth_service_web.dart';
import '../../../utils/platform_utils.dart';

class AuthCallbackScreen extends StatefulWidget {
  const AuthCallbackScreen({super.key});

  @override
  State<AuthCallbackScreen> createState() => _AuthCallbackScreenState();
}

class _AuthCallbackScreenState extends State<AuthCallbackScreen> {
  bool _isProcessing = true;
  String? _error;
  String? _debugInfo;

  @override
  void initState() {
    super.initState();
    print('AuthCallbackScreen initialized');
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    if (!PlatformUtils.isWeb) {
      setState(() {
        _error = 'This screen is only for web platform';
        _isProcessing = false;
      });
      return;
    }

    try {
      // Get full URL including query parameters
      final currentUrl = html.window.location.href;
      print('Auth callback URL: $currentUrl');
      
      // Parse the URL to extract code and state
      final uri = Uri.parse(currentUrl);
      final code = uri.queryParameters['code'];
      final state = uri.queryParameters['state'];
      
      print('Code present: ${code != null}, State present: ${state != null}');
      
      if (code == null || state == null) {
        setState(() {
          _error = 'Missing required Auth0 parameters';
          _debugInfo = 'URL: $currentUrl\nCode: ${code != null ? 'Present' : 'Missing'}\nState: ${state != null ? 'Present' : 'Missing'}';
          _isProcessing = false;
        });
        return;
      }

      final authService = AuthServiceWeb();
      final success = await authService.handleAuthCallback(uri);
      
      print('Auth callback processing result: $success');
      
      if (success && mounted) {
        print('Authentication successful, navigating to chat list');
        Navigator.of(context).pushReplacementNamed(AppRoutes.chatList);
      } else if (mounted) {
        setState(() {
          _error = 'Authentication failed';
          _isProcessing = false;
        });
      }
    } catch (e, stack) {
      print('Error in auth callback: $e');
      print('Stack trace: $stack');
      
      if (mounted) {
        setState(() {
          _error = 'Error: $e';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Authentication')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _isProcessing
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text('Processing Authentication...'),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    if (_debugInfo != null)
                      Container(
                        margin: const EdgeInsets.only(top: 20),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _debugInfo!,
                          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.login),
                      child: const Text('Go to Login'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}