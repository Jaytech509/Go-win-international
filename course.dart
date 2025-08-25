class Course {
  final String id;
  final String title;
  final String description;
  final int requiredLevel;
  final int requiredPoints;
  final int duration;
  final List<String> topics;
  final String imageUrl;
  final bool isUnlocked;
  final double progress;
  final DateTime? completedAt;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.requiredLevel,
    required this.requiredPoints,
    required this.duration,
    required this.topics,
    required this.imageUrl,
    required this.isUnlocked,
    required this.progress,
    this.completedAt,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    requiredLevel: json['requiredLevel'],
    requiredPoints: json['requiredPoints'] ?? 0,
    duration: json['duration'],
    topics: List<String>.from(json['topics']),
    imageUrl: json['imageUrl'],
    isUnlocked: json['isUnlocked'],
    progress: json['progress'].toDouble(),
    completedAt: json['completedAt'] != null 
        ? DateTime.parse(json['completedAt'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'requiredLevel': requiredLevel,
    'requiredPoints': requiredPoints,
    'duration': duration,
    'topics': topics,
    'imageUrl': imageUrl,
    'isUnlocked': isUnlocked,
    'progress': progress,
    'completedAt': completedAt?.toIso8601String(),
  };

  bool get isCompleted => progress >= 1.0;
}