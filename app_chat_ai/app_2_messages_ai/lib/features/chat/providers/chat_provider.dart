import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  Conversation? _activeConversation;
  bool _isLoading = false;
  String? _error;
  final _uuid = const Uuid();

  List<Conversation> get conversations => _conversations;
  Conversation? get activeConversation => _activeConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Simular obtención de conversaciones
  Future<void> fetchConversations() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simular retraso en la API
      await Future.delayed(const Duration(seconds: 1));
      
      // Datos de ejemplo
      _conversations = [
        Conversation(
          id: '1',
          title: 'Mi primera conversación',
          messages: [
            Message(
              id: '1',
              content: 'Hola, ¿cómo puedo ayudarte?',
              senderId: 'ai',
              isAI: true,
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            ),
          ],
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ];
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar conversaciones: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Crear una nueva conversación
  Future<Conversation> createConversation() async {
    _isLoading = true;
    notifyListeners();

    try {
      final newConversation = Conversation(
        id: _uuid.v4(),
        title: 'Nueva conversación',
        messages: [
          Message(
            id: _uuid.v4(),
            content: 'Hola, ¿en qué puedo ayudarte hoy?',
            senderId: 'ai',
            isAI: true,
            timestamp: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _conversations.add(newConversation);
      _activeConversation = newConversation;
      _isLoading = false;
      notifyListeners();
      return newConversation;
    } catch (e) {
      _error = 'Error al crear conversación: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      throw Exception(_error);
    }
  }

  // Cargar una conversación específica
  Future<void> loadConversation(String conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final conversation = _conversations.firstWhere(
        (c) => c.id == conversationId,
        orElse: () => throw Exception('Conversación no encontrada'),
      );
      
      _activeConversation = conversation;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar conversación: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Enviar un mensaje y obtener respuesta
  Future<void> sendMessage(String content, String userId) async {
    if (_activeConversation == null) {
      throw Exception('No hay una conversación activa');
    }

    // Mensaje del usuario
    final userMessage = Message(
      id: _uuid.v4(),
      content: content,
      senderId: userId,
      isAI: false,
      timestamp: DateTime.now(),
    );

    // Añadir a la conversación activa
    final updatedMessages = [..._activeConversation!.messages, userMessage];
    _activeConversation = Conversation(
      id: _activeConversation!.id,
      title: _activeConversation!.title,
      messages: updatedMessages,
      createdAt: _activeConversation!.createdAt,
      updatedAt: DateTime.now(),
    );
    
    // Actualizar la lista de conversaciones
    _updateConversationInList(_activeConversation!);
    notifyListeners();

    // Simular respuesta de la IA
    _isLoading = true;
    notifyListeners();

    try {
      // Simular retraso en respuesta
      await Future.delayed(const Duration(seconds: 1));
      
      // Respuesta de la IA
      final aiResponse = Message(
        id: _uuid.v4(),
        content: _generateAIResponse(content),
        senderId: 'ai',
        isAI: true,
        timestamp: DateTime.now(),
      );

      // Añadir respuesta a la conversación
      final messagesWithResponse = [..._activeConversation!.messages, aiResponse];
      _activeConversation = Conversation(
        id: _activeConversation!.id,
        title: _activeConversation!.title,
        messages: messagesWithResponse,
        createdAt: _activeConversation!.createdAt,
        updatedAt: DateTime.now(),
      );
      
      // Actualizar la lista de conversaciones
      _updateConversationInList(_activeConversation!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al obtener respuesta: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método auxiliar para actualizar una conversación en la lista
  void _updateConversationInList(Conversation conversation) {
    final index = _conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      _conversations[index] = conversation;
    }
  }

  // Método simple para generar respuestas de IA (simulado)
  String _generateAIResponse(String userMessage) {
    final userMessageLower = userMessage.toLowerCase();
    
    if (userMessageLower.contains('hola') || userMessageLower.contains('saludos')) {
      return '¡Hola! ¿Cómo puedo ayudarte hoy?';
    } else if (userMessageLower.contains('nombre')) {
      return 'Soy un asistente AI diseñado para ayudarte con tus preguntas.';
    } else if (userMessageLower.contains('gracias')) {
      return '¡De nada! Estoy aquí para lo que necesites.';
    } else if (userMessageLower.contains('?')) {
      return 'Esa es una buena pregunta. Déjame pensar... En este momento, mi capacidad para responder está limitada a este ejemplo básico.';
    } else {
      return 'Entiendo lo que dices. ¿Hay algo específico en lo que pueda ayudarte?';
    }
  }
}