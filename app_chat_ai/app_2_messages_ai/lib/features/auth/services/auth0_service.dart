import 'dart:convert';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class Auth0Service {
  final FlutterAppAuth appAuth = FlutterAppAuth();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  // Configura con tus variables de Auth0
  final String domain = 'dev-glnk8ysvcyu72ce1.us.auth0.com';
  final String clientId = 'zC5kiRumoTrC2rJ68i2V1KyPFqNAjwfT';
  final String redirectUrl = 'com.example.app://login-callback';
  final String audience = 'https://dev-glnk8ysvcyu72ce1.us.auth0.com/api/v2/';
  final String backendUrl = 'http://10.0.2.2:3000'; // Para emulador Android usa 10.0.2.2 en lugar de localhost

  // Keys para almacenamiento seguro
  final String accessTokenKey = 'access_token';
  final String refreshTokenKey = 'refresh_token';
  final String idTokenKey = 'id_token';
  final String expiresAtKey = 'expires_at';

  // Registro con Auth0 (usa la Database connection de Auth0)
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Método 1: Usando Auth0 Management API a través de tu backend
      final response = await http.post(
        Uri.parse('$backendUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Registro exitoso
        return true;
      }
      
      // Si el backend falla, podemos intentar el método 2
      throw Exception('Error en registro: ${response.body}');
      
      // Método 2: Redirigir a la página de registro de Auth0
      // Este enfoque requiere que implementes el endpoint de signup en tu backend
      // que redirija al usuario a Auth0 con screen_hint=signup
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  // Login con Auth0
  Future<bool> login() async {
    try {
      final AuthorizationTokenResponse result = await appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          clientId,
          redirectUrl,
          issuer: 'https://$domain',
          scopes: ['openid', 'profile', 'email', 'offline_access'],
          promptValues: ['login'],
          additionalParameters: {'audience': audience},
        ),
      );
  
      await _saveTokens(result);
      return true;
    } catch (e, s) {
      print('Error en login: $e - $s');
      return false;
    }
  }

  // Guardar tokens
  Future<void> _saveTokens(AuthorizationTokenResponse response) async {
    await secureStorage.write(key: accessTokenKey, value: response.accessToken);
    await secureStorage.write(key: idTokenKey, value: response.idToken);
    await secureStorage.write(key: refreshTokenKey, value: response.refreshToken);
    
    // Calcular expiración
    final expiresAt = DateTime.now().add(Duration(seconds: response.accessTokenExpirationDateTime!.difference(DateTime.now()).inSeconds)).millisecondsSinceEpoch;
    await secureStorage.write(key: expiresAtKey, value: expiresAt.toString());
  }

  // Obtener token para peticiones API
  Future<String?> getAccessToken() async {
    final accessToken = await secureStorage.read(key: accessTokenKey);
    final expiresAt = await secureStorage.read(key: expiresAtKey);
    
    if (accessToken == null || expiresAt == null) {
      return null;
    }
    
    // Verificar si el token está próximo a expirar (10 minutos)
    final expirationTime = int.parse(expiresAt);
    if (DateTime.now().millisecondsSinceEpoch + 600000 > expirationTime) {
      // Necesitamos refrescar el token
      return refreshToken();
    }
    
    return accessToken;
  }

  // Refrescar token
  Future<String?> refreshToken() async {
    final refreshToken = await secureStorage.read(key: refreshTokenKey);
    
    if (refreshToken == null) {
      return null;
    }
    
    try {
      final response = await http.post(
        Uri.parse('$backendUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final tokens = jsonDecode(response.body);
        await secureStorage.write(key: accessTokenKey, value: tokens['access_token']);
        
        if (tokens['refresh_token'] != null) {
          await secureStorage.write(key: refreshTokenKey, value: tokens['refresh_token']);
        }
        
        final expiresAt = DateTime.now().add(Duration(seconds: tokens['expires_in'])).millisecondsSinceEpoch;
        await secureStorage.write(key: expiresAtKey, value: expiresAt.toString());
        
        return tokens['access_token'];
      }
      return null;
    } catch (e) {
      print('Error en refreshToken: $e');
      return null;
    }
  }

  // Logout
  Future<bool> logout() async {
    try {
      final idToken = await secureStorage.read(key: idTokenKey);
      
      // Limpiar tokens almacenados
      await secureStorage.deleteAll();
      
      // Llamar al endpoint de logout de Auth0
      if (idToken != null) {
        // Utilizar Auth0 para cerrar sesión
        final url = Uri.parse(
          'https://$domain/v2/logout?client_id=$clientId&returnTo=com.example.app://&id_token_hint=$idToken'
        );
        
        await http.get(url);
      }
      
      return true;
    } catch (e) {
      print('Error en logout: $e');
      return false;
    }
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  // Obtener el perfil del usuario
  Future<Map<String, dynamic>?> getUserProfile() async {
    final accessToken = await getAccessToken();
    
    if (accessToken == null) {
      return null;
    }
    
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
      print('Error obteniendo perfil: $e');
      return null;
    }
  }
}