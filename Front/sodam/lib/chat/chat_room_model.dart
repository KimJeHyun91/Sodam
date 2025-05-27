class ChatRoomModel {
  final String title;
  final List<String> participants;
  final bool isSecret;
  final String? password;

  ChatRoomModel({
    required this.title,
    required this.participants,
    required this.isSecret,
    this.password,
  });
}
