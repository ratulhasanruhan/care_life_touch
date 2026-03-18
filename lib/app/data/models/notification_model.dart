class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'order', 'promotion', 'stock', 'general'
  final DateTime date;
  final bool isRead;
  final String? icon;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.date,
    this.isRead = false,
    this.icon,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    DateTime? date,
    bool? isRead,
    String? icon,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
      icon: icon ?? this.icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'date': date.toIso8601String(),
      'isRead': isRead,
      'icon': icon,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is DateTime) {
        return value;
      }
      if (value is String) {
        final parsed = DateTime.tryParse(value);
        if (parsed != null) {
          return parsed;
        }
      }
      return DateTime.now();
    }

    bool parseIsRead(dynamic value) {
      if (value is bool) {
        return value;
      }
      if (value is num) {
        return value != 0;
      }
      if (value is String) {
        final normalized = value.trim().toLowerCase();
        return normalized == 'true' || normalized == '1' || normalized == 'read';
      }
      return false;
    }

    return NotificationModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? json['name'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['description'] ?? '').toString(),
      type: (json['type'] ?? json['category'] ?? 'general').toString(),
      date: parseDate(json['createdAt'] ?? json['date'] ?? json['updatedAt']),
      isRead: parseIsRead(json['isRead'] ?? json['read'] ?? json['seen']),
      icon: json['icon']?.toString(),
    );
  }
}

