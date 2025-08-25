import 'package:ascendant_reach/models/member.dart';

class BoardJoinRequest {
  final String id;
  final String memberId;
  final String memberName;
  final String memberEmail;
  final String memberPhone;
  final int requestedLevel;
  final double paymentAmount;
  final String paymentMethod;
  final String? paymentProof;
  final String accountId;
  final String accountName;
  final ApprovalStatus status;
  final DateTime requestDate;
  final DateTime? approvalDate;
  final String? approvedBy;
  final String? rejectionReason;

  const BoardJoinRequest({
    required this.id,
    required this.memberId,
    required this.memberName,
    required this.memberEmail,
    required this.memberPhone,
    required this.requestedLevel,
    required this.paymentAmount,
    required this.paymentMethod,
    this.paymentProof,
    required this.accountId,
    required this.accountName,
    required this.status,
    required this.requestDate,
    this.approvalDate,
    this.approvedBy,
    this.rejectionReason,
  });

  factory BoardJoinRequest.fromJson(Map<String, dynamic> json) => BoardJoinRequest(
    id: json['id'],
    memberId: json['memberId'],
    memberName: json['memberName'],
    memberEmail: json['memberEmail'],
    memberPhone: json['memberPhone'] ?? '',
    requestedLevel: json['requestedLevel'],
    paymentAmount: json['paymentAmount'].toDouble(),
    paymentMethod: json['paymentMethod'],
    paymentProof: json['paymentProof'],
    accountId: json['accountId'] ?? '',
    accountName: json['accountName'] ?? '',
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
    'requestedLevel': requestedLevel,
    'paymentAmount': paymentAmount,
    'paymentMethod': paymentMethod,
    'paymentProof': paymentProof,
    'accountId': accountId,
    'accountName': accountName,
    'status': status.index,
    'requestDate': requestDate.toIso8601String(),
    'approvalDate': approvalDate?.toIso8601String(),
    'approvedBy': approvedBy,
    'rejectionReason': rejectionReason,
  };

  BoardJoinRequest copyWith({
    String? id,
    String? memberId,
    String? memberName,
    String? memberEmail,
    String? memberPhone,
    int? requestedLevel,
    double? paymentAmount,
    String? paymentMethod,
    String? paymentProof,
    String? accountId,
    String? accountName,
    ApprovalStatus? status,
    DateTime? requestDate,
    DateTime? approvalDate,
    String? approvedBy,
    String? rejectionReason,
  }) => BoardJoinRequest(
    id: id ?? this.id,
    memberId: memberId ?? this.memberId,
    memberName: memberName ?? this.memberName,
    memberEmail: memberEmail ?? this.memberEmail,
    memberPhone: memberPhone ?? this.memberPhone,
    requestedLevel: requestedLevel ?? this.requestedLevel,
    paymentAmount: paymentAmount ?? this.paymentAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    paymentProof: paymentProof ?? this.paymentProof,
    accountId: accountId ?? this.accountId,
    accountName: accountName ?? this.accountName,
    status: status ?? this.status,
    requestDate: requestDate ?? this.requestDate,
    approvalDate: approvalDate ?? this.approvalDate,
    approvedBy: approvedBy ?? this.approvedBy,
    rejectionReason: rejectionReason ?? this.rejectionReason,
  );

  static double getLevelFee(int level) {
    switch (level) {
      case 1: return 50.0;
      case 2: return 100.0;
      case 3: return 200.0;
      case 4: return 500.0;
      case 5: return 1000.0;
      case 6: return 2000.0;
      case 7: return 5000.0;
      default: return 0.0;
    }
  }
}