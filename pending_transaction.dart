import 'package:ascendant_reach/models/transaction.dart';
import 'package:ascendant_reach/models/member.dart';

enum PendingTransactionType { deposit, transfer, withdrawal, investment }

class PendingTransaction {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final PendingTransactionType type;
  final double amount;
  final String currency;
  final PaymentMethod? paymentMethod;
  final String description;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;
  final ApprovalStatus status;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String? rejectionReason;

  PendingTransaction({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.type,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    required this.description,
    required this.createdAt,
    this.metadata,
    required this.status,
    this.approvalDate,
    this.approvedBy,
    this.rejectionReason,
  });

  factory PendingTransaction.fromJson(Map<String, dynamic> json) => PendingTransaction(
    id: json['id'],
    memberId: json['memberId'],
    memberName: json['memberName'],
    memberEmail: json['memberEmail'],
    type: PendingTransactionType.values[json['type']],
    amount: json['amount'].toDouble(),
    currency: json['currency'],
    paymentMethod: json['paymentMethod'] != null 
        ? PaymentMethod.values[json['paymentMethod']]
        : null,
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    metadata: json['metadata'],
    status: ApprovalStatus.values[json['status']],
    approvalDate: json['approvalDate'] != null 
        ? DateTime.parse(json['approvalDate'])
        : null,
    approvedBy: json['approvedBy'],
    rejectionReason: json['rejectionReason'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'memberName': memberName,
    'memberEmail': memberEmail,
    'type': type.index,
    'amount': amount,
    'currency': currency,
    'paymentMethod': paymentMethod?.index,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'metadata': metadata,
    'status': status.index,
    'approvalDate': approvalDate?.toIso8601String(),
    'approvedBy': approvedBy,
    'rejectionReason': rejectionReason,
  };

  PendingTransaction copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberEmail,
    PendingTransactionType? type,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    String? description,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
    ApprovalStatus? status,
    DateTime? approvalDate,
    String? approvedBy,
    String? rejectionReason,
  }) => PendingTransaction(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberEmail: memberEmail ?? this.memberEmail,
    type: type ?? this.type,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    description: description ?? this.description,
    createdAt: createdAt ?? this.createdAt,
    metadata: metadata ?? this.metadata,
    status: status ?? this.status,
    approvalDate: approvalDate ?? this.approvalDate,
    approvedBy: approvedBy ?? this.approvedBy,
    rejectionReason: rejectionReason ?? this.rejectionReason,
  );
}