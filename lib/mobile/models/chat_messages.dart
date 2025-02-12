class ChatMessage {
  final String role;
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, String> toMap() => {'role': role, 'content': content};

  factory ChatMessage.fromMap(Map<String, String> map) {
    return ChatMessage(
      role: map['role'] ?? '',
      content: map['content'] ?? '',
    );
  }
}
