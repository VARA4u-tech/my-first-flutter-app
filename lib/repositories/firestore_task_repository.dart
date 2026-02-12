import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

/// Firestore repository for syncing tasks to Firebase in production mode.
/// Structure: /users/{userId}/tasks/{taskId}
class FirestoreTaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a reference to the current user's tasks collection
  CollectionReference<Map<String, dynamic>> _tasksCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');
    return _firestore.collection('users').doc(user.uid).collection('tasks');
  }

  /// Convert Task to Firestore map
  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'isCompleted': task.isCompleted,
      'priority': task.priority.index,
      'energyLevel': task.energyLevel,
      'category': task.category,
      'createdAt': Timestamp.fromDate(task.createdAt),
    };
  }

  /// Convert Firestore map to Task
  Task _mapToTask(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as String,
      title: map['title'] as String,
      isCompleted: map['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[map['priority'] as int? ?? 1],
      energyLevel: map['energyLevel'] as int? ?? 2,
      category: map['category'] as String? ?? 'General',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Get all tasks (one-time read)
  Future<List<Task>> getTasks() async {
    final snapshot = await _tasksCollection()
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => _mapToTask(doc.data())).toList();
  }

  /// Real-time stream of tasks
  Stream<List<Task>> watchTasks() {
    return _tasksCollection()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => _mapToTask(doc.data())).toList());
  }

  /// Add a new task
  Future<void> addTask(Task task) async {
    await _tasksCollection().doc(task.id).set(_taskToMap(task));
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    await _tasksCollection().doc(task.id).update(_taskToMap(task));
  }

  /// Delete a task
  Future<void> deleteTask(String id) async {
    await _tasksCollection().doc(id).delete();
  }

  /// Sync all local tasks to Firestore (for migration from Hive)
  Future<void> syncFromLocal(List<Task> localTasks) async {
    final batch = _firestore.batch();
    for (final task in localTasks) {
      batch.set(_tasksCollection().doc(task.id), _taskToMap(task));
    }
    await batch.commit();
  }
}
