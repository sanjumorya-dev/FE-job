class ChatConversation {
  final String id;
  final String participantId;
  final String participantName;
  final String? participantImage;
  final String jobTitle;
  final String requirementId;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final bool isOnline;

  ChatConversation({
    required this.id,
    required this.participantId,
    required this.participantName,
    this.participantImage,
    required this.jobTitle,
    required this.requirementId,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.isOnline,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      participantId: (json['participantId'] ?? json['ParticipantId'] ?? '').toString(),
      participantName: (json['participantName'] ?? json['ParticipantName'] ?? '').toString(),
      participantImage: json['participantImage'] ?? json['ParticipantImage'],
      jobTitle: (json['jobTitle'] ?? json['JobTitle'] ?? '').toString(),
      requirementId: (json['requirementId'] ?? json['RequirementId'] ?? '').toString(),
      lastMessage: (json['lastMessage'] ?? json['LastMessage'] ?? '').toString(),
      lastMessageTime: json['lastMessageTime'] != null
          ? DateTime.tryParse(json['lastMessageTime'].toString()) ?? DateTime.now()
          : json['lastMessageTime'] != null
              ? DateTime.tryParse(json['lastMessageTime'].toString()) ?? DateTime.now()
              : DateTime.now(),
      unreadCount: (json['unreadCount'] ?? json['UnreadCount'] ?? 0).toInt(),
      isOnline: json['isOnline'] ?? json['IsOnline'] ?? false,
    );
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final String status; // "sent", "delivered", "read"

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
    required this.status,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      senderId: (json['senderId'] ?? json['SenderId'] ?? '').toString(),
      text: (json['text'] ?? json['Text'] ?? '').toString(),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : json['Timestamp'] != null
              ? DateTime.tryParse(json['Timestamp'].toString()) ?? DateTime.now()
              : DateTime.now(),
      status: (json['status'] ?? json['Status'] ?? 'sent').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toUtc().toIso8601String(),
      'status': status,
    };
  }
}
