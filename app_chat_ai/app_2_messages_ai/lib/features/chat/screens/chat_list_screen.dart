import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../routes.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar conversaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis conversaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
      ),
      body: chatProvider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : chatProvider.conversations.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      'No tienes conversaciones aún. Inicia una nueva conversación con el botón de abajo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: chatProvider.conversations.length,
                  itemBuilder: (context, index) {
                    final conversation = chatProvider.conversations[index];
                    final lastMessage = conversation.messages.isNotEmpty 
                        ? conversation.messages.last 
                        : null;
                    
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.chat, color: Colors.white),
                      ),
                      title: Text(conversation.title),
                      subtitle: lastMessage != null 
                          ? Text(
                              lastMessage.content,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )
                          : const Text('Sin mensajes'),
                      trailing: Text(
                        _formatDate(conversation.updatedAt),
                        style: const TextStyle(color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          AppRoutes.chatDetail,
                          arguments: {'chatId': conversation.id},
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final newConversation = await chatProvider.createConversation();
            if (mounted) {
              Navigator.of(context).pushNamed(
                AppRoutes.chatDetail,
                arguments: {'chatId': newConversation.id},
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${e.toString()}')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }
}