import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:org_kata_notasv4/models/task.dart';

part 'home_screen.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  TaskModel({required this.title, this.isCompleted = false});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<TaskModel> taskBox;

  @override
  void initState() {
    super.initState();
    Hive.registerAdapter(TaskModelAdapter());
    Hive.initFlutter();
    taskBox = Hive.openBox<TaskModel>('tasks');
  }

  @override
  void dispose() {
    Hive.close();
    super.dispose();
  }

  void addTask(String title) {
    final task = TaskModel(title: title);
    taskBox.add(task);
    setState(() {});
  }

  void toggleTaskCompletion(int id) {
    final task = taskBox.get(id);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      task.save();
      setState(() {});
    }
  }

  void deleteTask(int id) {
    final task = taskBox.get(id);
    if (task != null) {
      task.delete();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas V4'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: taskBox.length,
        itemBuilder: (context, index) {
          final task = taskBox.getAt(index);
          return ListTile(
            title: Text(
              task!.title,
              style: TextStyle(
                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            leading: Checkbox(
              value: task.isCompleted,
              onChanged: (value) {
                toggleTaskCompletion(task.id);
              },
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                deleteTask(task.id);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController controller = TextEditingController();
              return AlertDialog(
                title: const Text('Nova Tarefa'),
                content: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Digite a tarefa'),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.isNotEmpty) {
                        addTask(controller.text);
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}