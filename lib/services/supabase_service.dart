import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson.dart';
import '../models/completion.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  Future<List<Lesson>> fetchLessons() async {
    final data = await _client.from('lessons').select().order('order_index');
    return (data as List).map((e) => Lesson.fromMap(e)).toList();
  }

  /// Push one completion. If a row already exists for this user+lesson,
  /// resolve using last-write-wins on client_updated_at (see sync_service).
  Future<void> upsertCompletion(Completion c) async {
    await _client.from('completions').upsert({
      'id': c.id,
      'user_id': c.userId,
      'lesson_id': c.lessonId,
      'completed_at': c.completedAt.toIso8601String(),
      'client_updated_at': c.clientUpdatedAt.toIso8601String(),
    }, onConflict: 'user_id,lesson_id');
  }

  Future<List<Completion>> fetchRemoteCompletions(String userId) async {
    final data = await _client
        .from('completions')
        .select()
        .eq('user_id', userId);
    return (data as List).map((e) => Completion.fromMap(e)).toList();
  }
}