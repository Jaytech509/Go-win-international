enum MemberRank { starter, bronze, silver, legend }

enum ApprovalStatus { pending, approved, rejected }

class Member {
  final String id;
  final String name;
  final String email;
  final String phoneNumber; // Added phone number field
  final String referralCode;
  final String? referredBy;
  final String? profilePicture;
  final MemberRank rank;
  final int level;
  final int boardPosition;
  final String? boardId;
  final List<String> directReferrals;
  final int points;
  final double walletBalance;
  final double earningWallet; // Separate earning wallet for referral profits
  final double investmentWallet; // Investment wallet for INVEST FOR EARNINGS
  final double walletCommissionProducts; // Wallet Commissions Products sell by Referral link in store
  final List<Map<String, dynamic>> activeInvestments; // Track active investments
  final DateTime joinDate;
  final bool isActive;
  final ApprovalStatus? boardJoinStatus;
  final DateTime? approvalDate;
  final String? paymentProof;
  final double depositAmount;
  final bool hasMinimumDeposit;
  final bool isAdmin;
  final bool hasNextLevelPayment; // Track if next level is paid
  final int stars; // Star progression based on level
  final bool hasProductSharingSubscription; // Track $10 subscription for product sharing
  final DateTime? subscriptionExpiryDate; // When subscription expires

  Member({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.referralCode,
    this.referredBy,
    this.profilePicture,
    required this.rank,
    required this.level,
    required this.boardPosition,
    this.boardId,
    required this.directReferrals,
    required this.points,
    required this.walletBalance,
    this.earningWallet = 0.0,
    this.investmentWallet = 0.0,
    this.walletCommissionProducts = 0.0,
    this.activeInvestments = const [],
    required this.joinDate,
    required this.isActive,
    this.boardJoinStatus,
    this.approvalDate,
    this.paymentProof,
    this.depositAmount = 0.0,
    this.hasMinimumDeposit = false,
    this.isAdmin = false,
    this.hasNextLevelPayment = false,
    this.stars = 1, // Default 1 star for level 1
    this.hasProductSharingSubscription = false,
    this.subscriptionExpiryDate,
  });

  // Empty constructor for default member
  Member.empty()
      : id = '',
        name = '',
        email = '',
        phoneNumber = '',
        referralCode = '',
        referredBy = null,
        profilePicture = null,
        rank = MemberRank.starter,
        level = 1,
        boardPosition = -1,
        boardId = null,
        directReferrals = [],
        points = 0,
        walletBalance = 0.0,
        earningWallet = 0.0,
        investmentWallet = 0.0,
        walletCommissionProducts = 0.0,
        activeInvestments = const [],
        joinDate = DateTime.now(),
        isActive = false,
        boardJoinStatus = null,
        approvalDate = null,
        paymentProof = null,
        depositAmount = 0.0,
        hasMinimumDeposit = false,
        isAdmin = false,
        hasNextLevelPayment = false,
        stars = 1,
        hasProductSharingSubscription = false,
        subscriptionExpiryDate = null;

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phoneNumber: json['phoneNumber'] ?? '',
    referralCode: json['referralCode'],
    referredBy: json['referredBy'],
    profilePicture: json['profilePicture'],
    rank: MemberRank.values[json['rank']],
    level: json['level'],
    boardPosition: json['boardPosition'],
    boardId: json['boardId'],
    directReferrals: List<String>.from(json['directReferrals']),
    points: json['points'],
    walletBalance: json['walletBalance'].toDouble(),
    earningWallet: (json['earningWallet'] ?? 0.0).toDouble(),
    investmentWallet: (json['investmentWallet'] ?? 0.0).toDouble(),
    walletCommissionProducts: (json['walletCommissionProducts'] ?? 0.0).toDouble(),
    activeInvestments: json['activeInvestments'] != null ? List<Map<String, dynamic>>.from(json['activeInvestments']) : [],
    joinDate: DateTime.parse(json['joinDate']),
    isActive: json['isActive'],
    boardJoinStatus: json['boardJoinStatus'] != null ? ApprovalStatus.values[json['boardJoinStatus']] : null,
    approvalDate: json['approvalDate'] != null ? DateTime.parse(json['approvalDate']) : null,
    paymentProof: json['paymentProof'],
    depositAmount: (json['depositAmount'] ?? 0.0).toDouble(),
    hasMinimumDeposit: json['hasMinimumDeposit'] ?? false,
    isAdmin: json['isAdmin'] ?? false,
    hasNextLevelPayment: json['hasNextLevelPayment'] ?? false,
    stars: json['stars'] ?? 1,
    hasProductSharingSubscription: json['hasProductSharingSubscription'] ?? false,
    subscriptionExpiryDate: json['subscriptionExpiryDate'] != null ? DateTime.parse(json['subscriptionExpiryDate']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phoneNumber': phoneNumber,
    'referralCode': referralCode,
    'referredBy': referredBy,
    'profilePicture': profilePicture,
    'rank': rank.index,
    'level': level,
    'boardPosition': boardPosition,
    'boardId': boardId,
    'directReferrals': directReferrals,
    'points': points,
    'walletBalance': walletBalance,
    'earningWallet': earningWallet,
    'investmentWallet': investmentWallet,
    'walletCommissionProducts': walletCommissionProducts,
    'activeInvestments': activeInvestments,
    'joinDate': joinDate.toIso8601String(),
    'isActive': isActive,
    'boardJoinStatus': boardJoinStatus?.index,
    'approvalDate': approvalDate?.toIso8601String(),
    'paymentProof': paymentProof,
    'depositAmount': depositAmount,
    'hasMinimumDeposit': hasMinimumDeposit,
    'isAdmin': isAdmin,
    'hasNextLevelPayment': hasNextLevelPayment,
    'stars': stars,
    'hasProductSharingSubscription': hasProductSharingSubscription,
    'subscriptionExpiryDate': subscriptionExpiryDate?.toIso8601String(),
  };

  Member copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? referralCode,
    String? referredBy,
    String? profilePicture,
    MemberRank? rank,
    int? level,
    int? boardPosition,
    String? boardId,
    List<String>? directReferrals,
    int? points,
    double? walletBalance,
    double? earningWallet,
    double? investmentWallet,
    double? walletCommissionProducts,
    List<Map<String, dynamic>>? activeInvestments,
    DateTime? joinDate,
    bool? isActive,
    ApprovalStatus? boardJoinStatus,
    DateTime? approvalDate,
    String? paymentProof,
    double? depositAmount,
    bool? hasMinimumDeposit,
    bool? isAdmin,
    bool? hasNextLevelPayment,
    int? stars,
    bool? hasProductSharingSubscription,
    DateTime? subscriptionExpiryDate,
  }) => Member(
    id: id ?? this.id,
    name: name ?? this.name,
    email: email ?? this.email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    referralCode: referralCode ?? this.referralCode,
    referredBy: referredBy ?? this.referredBy,
    profilePicture: profilePicture ?? this.profilePicture,
    rank: rank ?? this.rank,
    level: level ?? this.level,
    boardPosition: boardPosition ?? this.boardPosition,
    boardId: boardId ?? this.boardId,
    directReferrals: directReferrals ?? this.directReferrals,
    points: points ?? this.points,
    walletBalance: walletBalance ?? this.walletBalance,
    earningWallet: earningWallet ?? this.earningWallet,
    investmentWallet: investmentWallet ?? this.investmentWallet,
    walletCommissionProducts: walletCommissionProducts ?? this.walletCommissionProducts,
    activeInvestments: activeInvestments ?? this.activeInvestments,
    joinDate: joinDate ?? this.joinDate,
    isActive: isActive ?? this.isActive,
    boardJoinStatus: boardJoinStatus ?? this.boardJoinStatus,
    approvalDate: approvalDate ?? this.approvalDate,
    paymentProof: paymentProof ?? this.paymentProof,
    depositAmount: depositAmount ?? this.depositAmount,
    hasMinimumDeposit: hasMinimumDeposit ?? this.hasMinimumDeposit,
    isAdmin: isAdmin ?? this.isAdmin,
    hasNextLevelPayment: hasNextLevelPayment ?? this.hasNextLevelPayment,
    stars: stars ?? this.stars,
    hasProductSharingSubscription: hasProductSharingSubscription ?? this.hasProductSharingSubscription,
    subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
  );
}