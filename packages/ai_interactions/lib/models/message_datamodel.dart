enum MessageRole { user, assistant, system }

class MessageDataModel {
  final MessageRole role;
  String? content;

  MessageDataModel({
    required this.role,
    required this.content,
  });

  factory MessageDataModel.fromJson(Map<String, dynamic> json) {
    return MessageDataModel(
      role: MessageRole.values.byName(json['role']),
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role.name,
      'content': content,
    };
  }
}
