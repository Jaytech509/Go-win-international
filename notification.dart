class Notification {
  final String id;
  final String memberId;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? data;

  Notification({
    required this.id,
    required this.memberId,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
    this.data,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'],
      memberId: json['memberId'],
      title: json['title'],
      message: json['message'],
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.general,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      isRead: json['isRead'] ?? false,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberId': memberId,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  Notification copyWith({
    String? id,
    String? memberId,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return Notification(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}

enum NotificationType {
  general,
  boardApproval,
  boardRejection,
  withdrawalApproval,
  withdrawalRejection,
  levelUp,
  referralBonus,
  systemUpdate,
  welcome,
}

extension NotificationTypeExtension on NotificationType {
  String get displayName {
    switch (this) {
      case NotificationType.general:
        return 'General';
      case NotificationType.boardApproval:
        return 'Board Approval';
      case NotificationType.boardRejection:
        return 'Board Rejection';
      case NotificationType.withdrawalApproval:
        return 'Withdrawal Approved';
      case NotificationType.withdrawalRejection:
        return 'Withdrawal Rejected';
      case NotificationType.levelUp:
        return 'Level Up';
      case NotificationType.referralBonus:
        return 'Referral Bonus';
      case NotificationType.systemUpdate:
        return 'System Update';
      case NotificationType.welcome:
        return 'Welcome';
    }
  }

  String get iconName {
    switch (this) {
      case NotificationType.general:
        return 'info';
      case NotificationType.boardApproval:
        return 'check_circle';
      case NotificationType.boardRejection:
        return 'cancel';
      case NotificationType.withdrawalApproval:
        return 'account_balance_wallet';
      case NotificationType.withdrawalRejection:
        return 'money_off';
      case NotificationType.levelUp:
        return 'trending_up';
      case NotificationType.referralBonus:
        return 'people';
      case NotificationType.systemUpdate:
        return 'system_update';
      case NotificationType.welcome:
        return 'waving_hand';
    }
  }
}