import 'package:flutter/material.dart';
import '../models/lesson.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final bool completed;
  final VoidCallback onTap;
  const LessonCard({super.key, required this.lesson, required this.completed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: completed ? Colors.green.shade100 : Colors.grey.shade200,
          child: Icon(completed ? Icons.check : Icons.menu_book,
              color: completed ? Colors.green.shade700 : Colors.grey.shade600),
        ),
        title: Text(lesson.title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(lesson.module ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}