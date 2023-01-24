class ChatMessage {
  ChatMessage({required this.text, required this.type, required this.user});

  String? text;
  String? type;
  String? user;

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        text: json["text"] as String,
        type: json["type"] as String,
        user: json["user"] as String,
      );

  Map<String, dynamic> toJson() => {
        'text': text,
        'type': type,
        'user': user,
      };
}

class ChatList {
  String? libelle;
  ChatStream? chatStream;

  ChatList({required this.libelle, required this.chatStream});
}

class ChatStream {
  String? type;
  String? user;
  String? text;

  ChatStream({required this.text, required this.user, required this.type});
}
