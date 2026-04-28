enum NotificationType {
  applicationAccepted,
  applicationRejected,
  newApplicant,
  newJob,
  requirementCompleted,
  ratingReceived,
  system,
  unknown,
}

class Notification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;
  final String? referenceId;

  Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.referenceId,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    final dynamic rawType = json['type'] ?? json['Type'];
    NotificationType parsedType = NotificationType.unknown;
    if (rawType is int) {
      parsedType = switch (rawType) {
        0 => NotificationType.applicationAccepted,
        1 => NotificationType.applicationRejected,
        2 => NotificationType.newApplicant,
        3 => NotificationType.newJob,
        4 => NotificationType.requirementCompleted,
        5 => NotificationType.ratingReceived,
        6 => NotificationType.system,
        _ => NotificationType.unknown,
      };
    } else {
      final typeString = (rawType ?? '').toString().toLowerCase();
      switch (typeString) {
        case 'application_accepted':
        case 'application accepted':
          parsedType = NotificationType.applicationAccepted;
          break;
        case 'application_rejected':
        case 'application rejected':
          parsedType = NotificationType.applicationRejected;
          break;
        case 'new_applicant':
        case 'new applicant':
          parsedType = NotificationType.newApplicant;
          break;
        case 'new_job':
        case 'new job':
          parsedType = NotificationType.newJob;
          break;
        case 'requirement_completed':
        case 'requirement completed':
          parsedType = NotificationType.requirementCompleted;
          break;
        case 'rating_received':
        case 'rating received':
          parsedType = NotificationType.ratingReceived;
          break;
        case 'system':
          parsedType = NotificationType.system;
          break;
        default:
          parsedType = NotificationType.unknown;
      }
    }

    return Notification(
      id: (json['id'] ?? json['Id'] ?? '').toString(),
      title: (json['title'] ?? json['Title'] ?? '').toString(),
      body: (json['body'] ?? json['Body'] ?? '').toString(),
      type: parsedType,
      isRead: json['isRead'] ?? json['IsRead'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : json['CreatedAt'] != null
              ? DateTime.tryParse(json['CreatedAt'].toString()) ?? DateTime.now()
              : DateTime.now(),
      referenceId: (json['referenceId'] ?? json['ReferenceId'])?.toString(),
    );
  }
}
