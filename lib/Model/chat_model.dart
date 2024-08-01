class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final DateTime timestamp;
  final List<String> readBy;

  ChatMessage({
    this.id = '',
    required this.text,
    required this.senderId,
    required this.timestamp,
    this.readBy = const [],
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] ?? '',
        text: json['text'],
        senderId: json['senderId'],
        timestamp: json['timestamp'],
        readBy: json['readBy'] ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'senderId': senderId,
        'timestamp': timestamp,
        'readBy': readBy,
      };
}
