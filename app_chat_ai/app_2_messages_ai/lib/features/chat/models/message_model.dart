class Message {
  final String id;
  final String content;
  final String senderId;
  final bool isAI;
  final DateTime timestamp;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.isAI,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      senderId: json['senderId'],
      isAI: json['isAI'] ?? false,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'senderId': senderId,
      'isAI': isAI,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}