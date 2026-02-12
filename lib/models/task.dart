import 'package:uuid/uuid.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final TaskPriority priority;
  final int energyLevel; // 1-3 (Low, Medium, High energy required)
  final String category;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.energyLevel = 2,
    this.category = 'General',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    bool? isCompleted,
    TaskPriority? priority,
    int? energyLevel,
    String? category,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      energyLevel: energyLevel ?? this.energyLevel,
      category: category ?? this.category,
      createdAt: createdAt,
    );
  }
}

// Available categories
class TaskCategories {
  static const List<String> all = [
    'General',
    'Work',
    'Personal',
    'Study',
    'Health',
    'Shopping',
  ];

  static const Map<String, String> icons = {
    'General': '📋',
    'Work': '💼',
    'Personal': '🏠',
    'Study': '📚',
    'Health': '💪',
    'Shopping': '🛒',
  };

  static const Map<String, int> colors = {
    'General': 0xFF78909C,
    'Work': 0xFF5C6BC0,
    'Personal': 0xFFAB47BC,
    'Study': 0xFF29B6F6,
    'Health': 0xFF66BB6A,
    'Shopping': 0xFFFF7043,
  };
}
