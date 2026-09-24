import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson.dart';
import '../models/completion.dart';
import '../services/local_db_service.dart';

class LessonDetailScreen extends StatefulWidget {
  final Lesson lesson;
  final bool completed;
  const LessonDetailScreen({super.key, required this.lesson, required this.completed});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
  late bool _completed;

  @override
  void initState() {
    super.initState();
    _completed = widget.completed;
  }

  Future<void> _markComplete() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    final now = DateTime.now();
    final completion = Completion(
      id: const Uuid().v4(),
      userId: userId,
      lessonId: widget.lesson.id,
      completedAt: now,
      clientUpdatedAt: now,
      synced: false,
    );
    await LocalDbService.instance.queueCompletion(completion);
    setState(() => _completed = true);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked complete — will sync when online')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.lesson.title)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.lesson.module != null)
              Chip(label: Text(widget.lesson.module!)),
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Text(widget.lesson.content, style: const TextStyle(fontSize: 16, height: 1.5)))),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: _completed ? null : _markComplete,
                icon: Icon(_completed ? Icons.check_circle : Icons.check),
                label: Text(_completed ? 'Completed' : 'Mark as complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}