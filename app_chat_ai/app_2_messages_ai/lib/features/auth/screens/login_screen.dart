import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.chat_bubble_outline,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Iniciar Sesión',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Botón de login con Auth0
                ElevatedButton.icon(
                  onPressed: authProvider.isLoading 
                    ? null 
                    : () async {
                        final success = await authProvider.login();
                        if (success && context.mounted) {
                          Navigator.of(context).pushReplacementNamed(AppRoutes.chatList);
                        }
                      },
                  icon: const Icon(Icons.login),
                  label: authProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Continuar con Auth0'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                if (authProvider.isLoading)
                  const Center(
                    child: Text('Iniciando sesión...'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}