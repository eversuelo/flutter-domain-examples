import 'package:flutter/material.dart';
import '../services/auth_service_factory.dart';
import '../services/auth_service_interface.dart';

class AuthProvider extends ChangeNotifier {
  final AuthServiceInterface _authService = AuthServiceFactory.create() as AuthServiceInterface;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _userProfile;
  String? _error;

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get userProfile => _userProfile;
  String? get error => _error;
  
  // Add this getter for chat_detail_screen.dart
  Map<String, dynamic>? get currentUser => _userProfile;

  AuthProvider() {
    _checkAuthStatus();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      _isAuthenticated = await _authService.isAuthenticated();
      
      if (_isAuthenticated) {
        _userProfile = await _authService.getUserProfile();
      }
    } catch (e) {
      _error = "Error al verificar el estado de autenticación: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> login() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final success = await _authService.login();
      
      if (success) {
        _isAuthenticated = true;
        _userProfile = await _authService.getUserProfile();
      }
      
      return success;
    } catch (e) {
      _error = "Error al iniciar sesión: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fix the register method signature to use named parameters
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final success = await _authService.register(
        email: email,
        password: password,
        name: name,
      );
      
      if (success) {
        return await login();
      }
      
      return success;
    } catch (e) {
      _error = "Error al registrar: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> logout() async {
    _isLoading = true;
    _clearError();
    notifyListeners();

    try {
      final success = await _authService.logout();
      
      if (success) {
        _isAuthenticated = false;
        _userProfile = null;
      }
      
      return success;
    } catch (e) {
      _error = "Error al cerrar sesión: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _authService.getAccessToken();
    } catch (e) {
      _error = "Error al obtener token: $e";
      return null;
    }
  }
}