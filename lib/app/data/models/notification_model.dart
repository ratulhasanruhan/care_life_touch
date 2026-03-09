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
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      date: DateTime.parse(json['date']),
      isRead: json['isRead'] ?? false,
      icon: json['icon'],
    );
  }
}

