class Lesson {
  final String id;
  final String title;
  final String content;
  final String? module;
  final int orderIndex;
  final DateTime updatedAt;

  Lesson({
    required this.id,
    required this.title,
    required this.content,
    this.module,
    required this.orderIndex,
    required this.updatedAt,
  });

  factory Lesson.fromMap(Map<String, dynamic> map) => Lesson(
        id: map['id'],
        title: map['title'],
        content: map['content'],
        module: map['module'],
        orderIndex: map['order_index'] ?? 0,
        updatedAt: DateTime.parse(map['updated_at']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'content': content,
        'module': module,
        'order_index': orderIndex,
        'updated_at': updatedAt.toIso8601String(),
      };
}