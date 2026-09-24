import 'local_db_service.dart';
import 'supabase_service.dart';
import '../models/completion.dart';

class SyncService {
  final LocalDbService localDb = LocalDbService.instance;
  final SupabaseService remote = SupabaseService();

  Future<void> syncPendingCompletions(String userId) async {
    final pending = await localDb.getUnsyncedCompletions();
    final remoteCompletions = await remote.fetchRemoteCompletions(userId);
    final remoteByLesson = {for (var c in remoteCompletions) c.lessonId: c};

    for (final local in pending) {
      final remoteMatch = remoteByLesson[local.lessonId];
      if (remoteMatch == null ||
          local.clientUpdatedAt.isAfter(remoteMatch.clientUpdatedAt) ||
          local.clientUpdatedAt.isAtSameMomentAs(remoteMatch.clientUpdatedAt)) {
        // local wins or no conflict — push it
        await remote.upsertCompletion(local);
        await localDb.markSynced(local.id);
      } else {
        // remote wins — mark local synced but adopt remote data
        await localDb.queueCompletion(remoteMatch..synced = true);
      }
    }
  }

  Future<void> refreshLessonCache() async {
    final lessons = await remote.fetchLessons();
    await localDb.upsertLessons(lessons);
  }
}