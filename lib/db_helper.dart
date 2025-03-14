import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';


class DBHelper {
  static const String todoBoxName = 'todos';

  // Initialize Hive
  static Future<void> initialize() async {
    if (kIsWeb) {
      // Web-specific initialization
      await Hive.initFlutter();
    } else {
      // Platform-specific initialization
      if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
        final directory = await getApplicationDocumentsDirectory();
        Hive.init(directory.path);
      } else {
        await Hive.initFlutter();
      }
    }

    if (!Hive.isBoxOpen(todoBoxName)) {
      await Hive.openBox<Map<dynamic, dynamic>>(todoBoxName);
    }
  }


  // Insert a new todo
  Future<void> insertTodo(Map<String, dynamic> todo) async {
    final box = Hive.box<Map<dynamic, dynamic>>(todoBoxName);
    final formattedTodo = {
      'task': todo['task'] ?? '',
      'isCompleted': todo['isCompleted'] ?? false,
    };
    await box.add(formattedTodo);

    // Debugging log
    print('Inserted Todo: ${box.toMap()}');
  }

  // Fetch all todos
  List<Map<String, dynamic>> getTodos() {
    final box = Hive.box<Map<dynamic, dynamic>>(todoBoxName);
    return List.generate(box.length, (index) {
      final todo = box.getAt(index);
      if (todo != null && todo is Map<dynamic, dynamic>) {
        return {
          'id': index,
          'task': todo['task'] as String? ?? '',
          'isCompleted': todo['isCompleted'] as bool? ?? false,
        };
      } else {
        return {'id': index, 'task': '', 'isCompleted': false};
      }
    });
  }

  // Update a todo
  Future<void> updateTodo(int id, Map<String, dynamic> todo) async {
    final box = Hive.box<Map<dynamic, dynamic>>(todoBoxName);
    await box.putAt(id, todo);

    // Debugging log: Show all data in the Hive box
    print('Updated Todo: ${box.toMap()}');
  }

  // Delete a todo
  Future<void> deleteTodoById(int id) async {
    final box = Hive.box<Map<dynamic, dynamic>>(todoBoxName);
    await box.deleteAt(id);

    // Debugging log: Show all data in the Hive box
    print('Deleted Todo: ${box.toMap()}');
  }
}
