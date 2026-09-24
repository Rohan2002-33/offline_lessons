import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/lesson.dart';
import '../services/local_db_service.dart';
import '../services/sync_service.dart';
import '../services/connectivity_service.dart';
import '../widgets/sync_status_banner.dart';
import '../widgets/lesson_card.dart';
import 'lesson_detail_screen.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});
  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  final _localDb = LocalDbService.instance;
  final _sync = SyncService();
  final _connectivity = ConnectivityService();
  List<Lesson> _lessons = [];
  Set<String> _completedIds = {};
  bool _isOnline = true;
  int _pendingCount = 0;
  StreamSubscription<bool>? _connSub;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _isOnline = await _connectivity.isOnline();
    _connSub = _connectivity.onStatusChange.listen((online) async {
      setState(() => _isOnline = online);
      if (online) await _trySync();
    });
    await _loadFromCache();
    if (_isOnline) {
      await _sync.refreshLessonCache();
      await _trySync();
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    final lessons = await _localDb.getCachedLessons();
    final completed = await _localDb.getCompletedLessonIds();
    final pending = await _localDb.getUnsyncedCompletions();
    setState(() {
      _lessons = lessons;
      _completedIds = completed;
      _pendingCount = pending.length;
    });
  }

  Future<void> _trySync() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    await _sync.syncPendingCompletions(userId);
    await _loadFromCache();
  }

  @override
  void dispose() {
    _connSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lessons')),
      body: Column(
        children: [
          SyncStatusBanner(isOnline: _isOnline, pendingCount: _pendingCount),
          Expanded(
            child: _lessons.isEmpty
                ? const Center(child: Text('No cached lessons yet. Connect once to download.'))
                : RefreshIndicator(
                    onRefresh: () async {
                      if (_isOnline) await _sync.refreshLessonCache();
                      await _loadFromCache();
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _lessons.length,
                      itemBuilder: (context, i) {
                        final lesson = _lessons[i];
                        return LessonCard(
                          lesson: lesson,
                          completed: _completedIds.contains(lesson.id),
                          onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (_) => LessonDetailScreen(lesson: lesson, completed: _completedIds.contains(lesson.id)),
                            ));
                            await _loadFromCache();
                            if (_isOnline) await _trySync();
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}