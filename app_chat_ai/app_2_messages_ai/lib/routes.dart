import 'package:flutter/material.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/auth/screens/auth_callback_screen.dart';
import 'features/chat/screens/chat_list_screen.dart';
import 'features/chat/screens/chat_detail_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String authCallback = '/auth-callback';
  static const String chatList = '/chats';
  static const String chatDetail = '/chat';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => const LoginScreen(),
      register: (context) => const RegisterScreen(),
      authCallback: (context) => const AuthCallbackScreen(),
      chatList: (context) => const ChatListScreen(),
      chatDetail: (context) => (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['chatId'] != null
          ? ChatDetailScreen(chatId: (ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>)['chatId'] as String)
          : const ChatListScreen(),
    };
  }

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name;
    final routes = getRoutes();
    final builder = routes[routeName];
    
    if (builder != null) {
      return MaterialPageRoute(
        settings: settings,
        builder: builder,
      );
    }
    
    return MaterialPageRoute(
      settings: settings,
      builder: (context) => const LoginScreen(),
    );
  }
}

final routes = {
  '/auth-callback': (context) => const AuthCallbackScreen(),
  // other routes...
};