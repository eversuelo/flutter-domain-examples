import 'dart:async';

abstract class AuthServiceInterface {
  Future<bool> login();
  Future<bool> register({required String email, required String password, required String name});
  Future<bool> logout();
  Future<bool> isAuthenticated();
  Future<String?> getAccessToken();
  Future<Map<String, dynamic>?> getUserProfile();
}