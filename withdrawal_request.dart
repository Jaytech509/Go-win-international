import 'package:ascendant_reach/models/member.dart';

class WithdrawalRequest {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String memberPhone;
  final double amount;
  final String paymentMethod;
  final String accountId;
  final String accountName;
  final ApprovalStatus status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String? rejectionReason;

  const WithdrawalRequest({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.memberPhone,
    required this.amount,
    required this.paymentMethod,
    required this.accountId,
    required this.accountName,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.approvedBy,
    this.rejectionReason,
  });

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) => WithdrawalRequest(
    id: json['id'],
    memberId: json['memberId'],
    memberName: json['memberName'],
    memberEmail: json['memberEmail'],
    memberPhone: json['memberPhone'] ?? '',
    amount: json['amount'].toDouble(),
    paymentMethod: json['paymentMethod'],
    accountId: json['accountId'],
    accountName: json['accountName'],
    status: ApprovalStatus.values[json['status']],
    requestDate: DateTime.parse(json['requestDate']),
    approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
    approvedBy: json['approvedBy'],
    rejectionReason: json['rejectionReason'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'memberName': memberName,
    'memberEmail': memberEmail,
    'memberPhone': memberPhone,
    'amount': amount,
    'paymentMethod': paymentMethod,
    'accountId': accountId,
    'accountName': accountName,
    'status': status.index,
    'requestDate': requestDate.toIso8601String(),
    'approvalDate': approvalDate?.toIso8601String(),
    'approvedBy': approvedBy,
    'rejectionReason': rejectionReason,
  };

  WithdrawalRequest copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberEmail,
    String? memberPhone,
    double? amount,
    String? paymentMethod,
    String? accountId,
    String? accountName,
    ApprovalStatus? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    String? approvedBy,
    String? rejectionReason,
  }) => WithdrawalRequest(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberEmail: memberEmail ?? this.memberEmail,
    memberPhone: memberPhone ?? this.memberPhone,
    amount: amount ?? this.amount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    accountId: accountId ?? this.accountId,
    accountName: accountName ?? this.accountName,
    status: status ?? this.status,
    requestDate: requestDate ?? this.requestDate,
    approvalDate: approvalDate ?? this.approvalDate,
    approvedBy: approvedBy ?? this.approvedBy,
    rejectionReason: rejectionReason ?? this.rejectionReason,
  );
}