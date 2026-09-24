class Completion {
  final String id;
  final String userId;
  final String lessonId;
  final DateTime completedAt;
  final DateTime clientUpdatedAt;
  bool synced;

  Completion({
    required this.id,
    required this.userId,
    required this.lessonId,
    required this.completedAt,
    required this.clientUpdatedAt,
    this.synced = false,
  });

  factory Completion.fromMap(Map<String, dynamic> map) => Completion(
        id: map['id'],
        userId: map['user_id'],
        lessonId: map['lesson_id'],
        completedAt: DateTime.parse(map['completed_at']),
        clientUpdatedAt: DateTime.parse(map['client_updated_at']),
        synced: (map['synced'] ?? 0) == 1,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'user_id': userId,
        'lesson_id': lessonId,
        'completed_at': completedAt.toIso8601String(),
        'client_updated_at': clientUpdatedAt.toIso8601String(),
        'synced': synced ? 1 : 0,
      };
}