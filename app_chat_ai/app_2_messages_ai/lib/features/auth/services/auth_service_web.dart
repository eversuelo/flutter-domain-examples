import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import '../../../utils/storage_utils.dart';
import 'auth_service_interface.dart';

class AuthServiceWeb implements AuthServiceInterface {
  // Auth0 configuration
  final String domain = 'dev-glnk8ysvcyu72ce1.us.auth0.com';
  final String clientId = 'zC5kiRumoTrC2rJ68i2V1KyPFqNAjwfT';
  final String audience = 'https://dev-glnk8ysvcyu72ce1.us.auth0.com/api/v2/';
  final String backendUrl = 'http://localhost:3000';

  // Storage keys
  final String accessTokenKey = 'access_token';
  final String refreshTokenKey = 'refresh_token';
  final String idTokenKey = 'id_token';
  final String expiresAtKey = 'expires_at';

  // Login with Auth0 for web - using direct window.location approach
  @override
  Future<bool> login() async {
    try {
      // Get the current origin (host + port) dynamically
      final currentOrigin = html.window.location.origin;
      final redirectUri = '$currentOrigin/auth-callback';
      
      print('Using redirect URI: $redirectUri');
      
      final state = _generateRandomString(32);
      final authUrl = Uri.parse(
        'https://$domain/authorize?'
        'response_type=code'
        '&client_id=$clientId'
        '&redirect_uri=$redirectUri'
        '&scope=openid%20profile%20email%20offline_access'
        '&audience=$audience'
        '&state=$state'
      );

      // Store state to verify when callback happens
      await StorageUtils.saveItem('auth_state', state);
      
      // Store the redirect URI so we can use it again during token exchange
      await StorageUtils.saveItem('auth_redirect_uri', redirectUri);
      
      // Use direct window navigation instead of url_launcher
      html.window.location.href = authUrl.toString();
      
      // This doesn't actually return because the page will redirect
      return true;
    } catch (e) {
      print('Error in web login: $e');
      return false;
    }
  }

  // For web we need to handle the callback in a separate file
  // This would be called by your auth-callback page
  Future<bool> handleAuthCallback(Uri uri) async {
    final code = uri.queryParameters['code'];
    final state = uri.queryParameters['state'];
    final savedState = await StorageUtils.getItem('auth_state');
    
    print('Handling auth callback:');
    print('- Received state: $state');
    print('- Saved state: $savedState');
    
    if (code != null && state == savedState) {
      try {
        // Get the same redirect URI we used during login
        final redirectUri = await StorageUtils.getItem('auth_redirect_uri') ?? 
                          '${html.window.location.origin}/auth-callback';
        
        print('Using callback URI for token exchange: $redirectUri');
        
        final response = await http.post(
          Uri.parse('https://$domain/oauth/token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'grant_type': 'authorization_code',
            'client_id': clientId,
            'code': code,
            'redirect_uri': redirectUri,
          }),
        );
        
        print('Token exchange response status: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('Received token data: ${data.keys.toList()}');
          await _saveTokens(data);
          
          // Test retrieving the stored token
          final storedToken = await StorageUtils.getItem(accessTokenKey);
          print('Stored token exists: ${storedToken != null}');
          
          return true;
        } else {
          print('Token exchange failed: ${response.statusCode}');
          print('Response body: ${response.body}');
          return false;
        }
      } catch (e, stack) {
        print('Error exchanging code for token: $e');
        print('Stack trace: $stack');
        return false;
      }
    } else {
      if (code == null) {
        print('Code parameter is missing');
      }
      if (state != savedState) {
        print('State mismatch: Received=$state, Saved=$savedState');
      }
      return false;
    }
  }

  // Web implementation of other methods
  @override
  Future<bool> register({required String email, required String password, required String name}) async {
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error in register: $e');
      return false;
    }
  }

  @override
  Future<bool> logout() async {
    try {
      final idToken = await StorageUtils.getItem(idTokenKey);
      await StorageUtils.clearAll();
      
      final returnTo = html.window.location.origin;
      final logoutUrl = Uri.parse(
        'https://$domain/v2/logout?'
        'client_id=$clientId'
        '&returnTo=$returnTo'
        '${idToken != null ? '&id_token_hint=$idToken' : ''}'
      ).toString();
      
      // Use direct window navigation instead of url_launcher
      html.window.location.href = logoutUrl;
      
      return true;
    } catch (e) {
      print('Error in logout: $e');
      return false;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final accessToken = await StorageUtils.getItem(accessTokenKey);
      final expiresAtStr = await StorageUtils.getItem(expiresAtKey);
      
      if (accessToken == null || expiresAtStr == null) {
        return null;
      }
      
      final expiresAt = int.parse(expiresAtStr);
      final now = DateTime.now().millisecondsSinceEpoch;
      
      if (now >= expiresAt) {
        return await _refreshToken();
      }
      
      return accessToken;
    } catch (e) {
      print('Error getting access token: $e');
      return null;
    }
  }

  Future<String?> _refreshToken() async {
    final refreshToken = await StorageUtils.getItem(refreshTokenKey);
    if (refreshToken == null) return null;
    
    try {
      final response = await http.post(
        Uri.parse('https://$domain/oauth/token'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'grant_type': 'refresh_token',
          'client_id': clientId,
          'refresh_token': refreshToken,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveTokens(data);
        return data['access_token'];
      }
      return null;
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile() async {
    final accessToken = await getAccessToken();
    if (accessToken == null) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/auth/profile'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> _saveTokens(Map<String, dynamic> data) async {
    await StorageUtils.saveItem(accessTokenKey, data['access_token']);
    
    if (data.containsKey('id_token')) {
      await StorageUtils.saveItem(idTokenKey, data['id_token']);
    }
    
    if (data.containsKey('refresh_token')) {
      await StorageUtils.saveItem(refreshTokenKey, data['refresh_token']);
    }
    
    final expiresIn = data['expires_in'] as int;
    final expiresAt = DateTime.now()
        .add(Duration(seconds: expiresIn))
        .millisecondsSinceEpoch;
    await StorageUtils.saveItem(expiresAtKey, expiresAt.toString());
  }

  // Helper to generate random state parameter
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final buffer = StringBuffer();
    final random = (html.window.crypto?.getRandomValues(Uint8List(length)) as Uint8List?) ?? 
        Uint8List.fromList(List.generate(length, (_) => DateTime.now().millisecondsSinceEpoch % 256));
    for (var i = 0; i < length; i++) {
      buffer.write(chars[random[i] % chars.length]);
    }
    return buffer.toString();
  }
}