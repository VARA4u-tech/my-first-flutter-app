import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class TaskRepository {
  late Box<Task> _box;

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapterWrapper());
    }
    _box = await Hive.openBox<Task>('tasks');
  }

  List<Task> getTasks() {
    return _box.values.toList();
  }

  Future<void> addTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await _box.put(task.id, task);
  }

  Future<void> deleteTask(String id) async {
    await _box.delete(id);
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
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer.writeByte(7); // Number of fields
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
  }
}
