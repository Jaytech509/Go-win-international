class BoardPosition {
  final int position;
  final String? memberId;
  final String? memberName;

  BoardPosition({
    required this.position,
    this.memberId,
    this.memberName,
  });

  factory BoardPosition.fromJson(Map<String, dynamic> json) => BoardPosition(
    position: json['position'],
    memberId: json['memberId'],
    memberName: json['memberName'],
  );

  Map<String, dynamic> toJson() => {
    'position': position,
    'memberId': memberId,
    'memberName': memberName,
  };
}

class MLMBoard {
  final String id;
  final int level;
  final List<BoardPosition> positions;
  final bool isComplete;
  final DateTime createdAt;
  final String? legendMemberId;

  MLMBoard({
    required this.id,
    required this.level,
    required this.positions,
    required this.isComplete,
    required this.createdAt,
    this.legendMemberId,
  });

  factory MLMBoard.empty(String id, int level) => MLMBoard(
    id: id,
    level: level,
    positions: List.generate(14, (index) => BoardPosition(position: index)),
    isComplete: false,
    createdAt: DateTime.now(),
  );

  factory MLMBoard.fromJson(Map<String, dynamic> json) => MLMBoard(
    id: json['id'],
    level: json['level'],
    positions: (json['positions'] as List)
        .map((pos) => BoardPosition.fromJson(pos))
        .toList(),
    isComplete: json['isComplete'],
    createdAt: DateTime.parse(json['createdAt']),
    legendMemberId: json['legendMemberId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'level': level,
    'positions': positions.map((pos) => pos.toJson()).toList(),
    'isComplete': isComplete,
    'createdAt': createdAt.toIso8601String(),
    'legendMemberId': legendMemberId,
  };

  int get filledPositions => positions.where((pos) => pos.memberId != null).length;
  
  bool get canComplete => filledPositions == 14;

  MLMBoard copyWith({
    String? id,
    int? level,
    List<BoardPosition>? positions,
    bool? isComplete,
    DateTime? createdAt,
    String? legendMemberId,
  }) => MLMBoard(
    id: id ?? this.id,
    level: level ?? this.level,
    positions: positions ?? this.positions,
    isComplete: isComplete ?? this.isComplete,
    createdAt: createdAt ?? this.createdAt,
    legendMemberId: legendMemberId ?? this.legendMemberId,
  );
}