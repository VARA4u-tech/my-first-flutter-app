import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../repositories/firestore_task_repository.dart';

// ── Repositories ──
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final firestoreTaskRepositoryProvider = Provider<FirestoreTaskRepository>((ref) {
  return FirestoreTaskRepository();
});

// ── Auth State ──
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── Task List Provider ──
final taskListProvider = NotifierProvider<TaskNotifier, List<Task>>(TaskNotifier.new);

// ── Mood Provider ──
enum DuckMood { cool, sleepy, party, neutral }

final duckMoodProvider = Provider<DuckMood>((ref) {
  final tasks = ref.watch(taskListProvider);
  if (tasks.isEmpty) return DuckMood.sleepy;

  final completedCount = tasks.where((t) => t.isCompleted).length;
  final totalCount = tasks.length;
  final completionRate = completedCount / totalCount;

  if (completionRate == 1.0) return DuckMood.party;
  if (completionRate > 0.6) return DuckMood.cool;
  if (completionRate < 0.3) return DuckMood.sleepy;

  return DuckMood.neutral;
});

// ── Progress Provider (0.0 to 1.0) ──
final taskProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(taskListProvider);
  if (tasks.isEmpty) return 0.0;
  return tasks.where((t) => t.isCompleted).length / tasks.length;
});

// ── All-done flag for confetti ──
final allTasksDoneProvider = Provider<bool>((ref) {
  final tasks = ref.watch(taskListProvider);
  return tasks.isNotEmpty && tasks.every((t) => t.isCompleted);
});

// ── Streak Provider ──
final streakProvider = Provider<int>((ref) {
  final tasks = ref.watch(taskListProvider);
  if (tasks.isEmpty) return 0;

  final completedToday = tasks.where((t) => t.isCompleted).length;
  if (completedToday == tasks.length && tasks.isNotEmpty) return 3;
  if (completedToday > 0) return 1;
  return 0;
});

// ── Task Notifier (Hive local + Firestore cloud sync) ──
class TaskNotifier extends Notifier<List<Task>> {
  late final TaskRepository _localRepo;
  late final FirestoreTaskRepository _cloudRepo;

  @override
  List<Task> build() {
    _localRepo = ref.watch(taskRepositoryProvider);
    _cloudRepo = ref.watch(firestoreTaskRepositoryProvider);

    // If user is logged in, start listening to Firestore
    final authState = ref.watch(authStateProvider);
    authState.whenData((user) {
      if (user != null) {
        _syncFromCloud();
      }
    });

    return _loadLocalTasks();
  }

  List<Task> _loadLocalTasks() {
    final tasks = _localRepo.getTasks();
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return tasks;
  }

  List<Task> _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return tasks;
  }

  /// Pull tasks from Firestore and merge with local
  Future<void> _syncFromCloud() async {
    try {
      final cloudTasks = await _cloudRepo.getTasks();
      if (cloudTasks.isNotEmpty) {
        // Store cloud tasks locally
        for (final task in cloudTasks) {
          await _localRepo.addTask(task);
        }
        state = _sortTasks(_localRepo.getTasks());
      } else {
        // First time: push local tasks to cloud
        final localTasks = _localRepo.getTasks();
        if (localTasks.isNotEmpty) {
          await _cloudRepo.syncFromLocal(localTasks);
        }
      }
    } catch (e) {
      // Offline or error — just use local data
      print('Cloud sync failed: $e');
    }
  }

  Future<void> addTask(String title, TaskPriority priority, int energy,
      {String category = 'General'}) async {
    final task = Task(
      title: title,
      priority: priority,
      energyLevel: energy,
      category: category,
    );

    // Save locally first (offline-first)
    await _localRepo.addTask(task);
    state = _sortTasks(_localRepo.getTasks());

    // Then sync to cloud
    _syncToCloud(() => _cloudRepo.addTask(task));
  }

  Future<void> toggleTask(String id) async {
    final taskIndex = state.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = state[taskIndex];
      final updatedTask = task.copyWith(isCompleted: !task.isCompleted);

      // Save locally first
      await _localRepo.updateTask(updatedTask);
      state = _sortTasks(_localRepo.getTasks());

      // Sync to cloud
      _syncToCloud(() => _cloudRepo.updateTask(updatedTask));
    }
  }

  Future<void> deleteTask(String id) async {
    // Delete locally first
    await _localRepo.deleteTask(id);
    state = _sortTasks(_localRepo.getTasks());

    // Sync to cloud
    _syncToCloud(() => _cloudRepo.deleteTask(id));
  }

  /// Fire-and-forget cloud sync (non-blocking)
  void _syncToCloud(Future<void> Function() action) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await action();
      }
    } catch (e) {
      print('Cloud sync error: $e');
      // Silently fail — local data is already saved
    }
  }
}
