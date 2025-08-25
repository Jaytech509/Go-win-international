enum TransactionType { deposit, withdrawal, commission, purchase, referralBonus, referralProfit, levelUpgrade, transfer, investment, investmentProfit, subscriptionFee, productCommission, fee, referralCommission, levelBonus, boardCompletion, storeReferral }
enum PaymentMethod { moncash, natcash, creditCard, paypal, wise, cryptocurrency, creditLivegood, wireBank, stripeLink, cash, other }
enum TransactionStatus { pending, completed, failed, cancelled }

class Transaction {
  final String id;
  final String memberId;
  final TransactionType type;
  final double amount;
  final String currency;
  final PaymentMethod? paymentMethod;
  final TransactionStatus status;
  final String description;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.memberId,
    required this.type,
    required this.amount,
    required this.currency,
    this.paymentMethod,
    required this.status,
    required this.description,
    required this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'],
    memberId: json['memberId'],
    type: TransactionType.values[json['type']],
    amount: json['amount'].toDouble(),
    currency: json['currency'],
    paymentMethod: json['paymentMethod'] != null 
        ? PaymentMethod.values[json['paymentMethod']]
        : null,
    status: TransactionStatus.values[json['status']],
    description: json['description'],
    createdAt: DateTime.parse(json['createdAt']),
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'])
        : null,
    metadata: json['metadata'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'memberId': memberId,
    'type': type.index,
    'amount': amount,
    'currency': currency,
    'paymentMethod': paymentMethod?.index,
    'status': status.index,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'metadata': metadata,
  };
}