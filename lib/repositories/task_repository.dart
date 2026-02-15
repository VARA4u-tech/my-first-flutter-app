import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskRepository {
  late Box<Task> _box;
  final NotificationService _notificationService = NotificationService();

  Future<void> init() async {
    // Initialize notifications
    await _notificationService.init();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapterWrapper());
    }
    _box = await Hive.openBox<Task>('tasks');
  }

  List<Task> getTasks() {
    return _box.values.toList();
  }

  Future<void> addTask(Task task) async {
    // 1. Save to Hive (Local)
    await _box.put(task.id, task);

    // 2. Schedule Notification (Non-blocking)
    if (task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      _notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: task.dueDate!,
      );
    }
  }

  Future<void> updateTask(Task task) async {
    // 1. Update Hive
    await _box.put(task.id, task);

    // 2. Update Notification (Non-blocking)
    // Cancel existing notification first
    _notificationService.cancelNotification(task.id.hashCode);
    
    // Schedule new if needed
    if (!task.isCompleted && task.dueDate != null && task.dueDate!.isAfter(DateTime.now())) {
      _notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: 'Task Reminder',
        body: task.title,
        scheduledDate: task.dueDate!,
      );
    }
  }

  Future<void> deleteTask(String id) async {
    // 1. Delete from Hive
    await _box.delete(id);

    // 2. Cancel Notification (Non-blocking)
    _notificationService.cancelNotification(id.hashCode);
  }
}

class TaskAdapterWrapper extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final fieldsCount = reader.readByte(); // Number of fields
    String id = '';
    String title = '';
    bool isCompleted = false;
    int priorityIndex = 1;
    int energyLevel = 2;
    int createdAtMs = DateTime.now().millisecondsSinceEpoch;
    String category = 'General';
    DateTime? dueDate;

    for (int i = 0; i < fieldsCount; i++) {
      final fieldId = reader.readByte();
      switch (fieldId) {
        case 0:
          id = reader.readString();
          break;
        case 1:
          title = reader.readString();
          break;
        case 2:
          isCompleted = reader.readBool();
          break;
        case 3:
          priorityIndex = reader.readInt();
          break;
        case 4:
          energyLevel = reader.readInt();
          break;
        case 5:
          createdAtMs = reader.readInt();
          break;
        case 6:
          category = reader.readString();
          break;
        case 7:
          final hasDueDate = reader.readBool();
          if (hasDueDate) {
            dueDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
          }
          break;
      }
    }

    return Task(
      id: id,
      title: title,
      isCompleted: isCompleted,
      priority: TaskPriority.values[priorityIndex],
      energyLevel: energyLevel,
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMs),
      category: category,
      dueDate: dueDate,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeByte(8); // Number of fields
    writer.writeByte(0);
    writer.writeString(obj.id);
    writer.writeByte(1);
    writer.writeString(obj.title);
    writer.writeByte(2);
    writer.writeBool(obj.isCompleted);
    writer.writeByte(3);
    writer.writeInt(obj.priority.index);
    writer.writeByte(4);
    writer.writeInt(obj.energyLevel);
    writer.writeByte(5);
    writer.writeInt(obj.createdAt.millisecondsSinceEpoch);
    writer.writeByte(6);
    writer.writeString(obj.category);
    writer.writeByte(7);
    if (obj.dueDate != null) {
      writer.writeBool(true);
      writer.writeInt(obj.dueDate!.millisecondsSinceEpoch);
    } else {
      writer.writeBool(false);
    }
  }
}
