import 'dart:convert';
import 'package:http/http.dart' as http;
import '../features/auth/providers/auth_provider.dart';

class ApiService {
  final String baseUrl = 'http://localhost:3000';
  final AuthProvider authProvider;

  ApiService(this.authProvider);

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await authProvider.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener datos: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/$endpoint'),
      headers: headers,
      body: jsonEncode(data),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al enviar datos: ${response.statusCode}');
    }
  }

  // Agrega más métodos HTTP según necesites
}