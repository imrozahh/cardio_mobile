class ChatEntity {
  final int id;
  final int userId;
  final String message;
  final String response;
  final DateTime createdAt;

  const ChatEntity({
    required this.id,
    required this.userId,
    required this.message,
    required this.response,
    required this.createdAt,
  });
}
