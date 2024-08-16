import 'package:flutter/material.dart';

import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter SQLite CRUD',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

// const MyHomePage({super.key, required this.title});
class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
    State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    _refreshTodoList();
  }

  Future<void> _refreshTodoList() async {
    final data = await DatabaseHelper.instance.readAllTodos();
    setState(() {
      todos = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo List')),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(todos[index].title),
            subtitle: Text(todos[index].description),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await DatabaseHelper.instance.deleteTodo(todos[index].id!);
                _refreshTodoList();
              },
            ),
            onTap: () {
              _showForm(todo: todos[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(),
      ),
    );
  }

  void _showForm({Todo? todo}) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    if (todo != null) {
      titleController.text = todo.title;
      descriptionController.text = todo.description;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                if (todo == null) {
                  await DatabaseHelper.instance.createTodo(
                    Todo(
                      title: titleController.text,
                      description: descriptionController.text,
                    ),
                  );
                } else {
                  await DatabaseHelper.instance.updateTodo(
                    Todo(
                      id: todo.id,
                      title: titleController.text,
                      description: descriptionController.text,
                    ),
                  );
                }
                _refreshTodoList();
                Navigator.of(context).pop();
              },
              child: Text(todo == null ? 'Create New' : 'Update'),
            )
          ],
        ),
      ),
    );
  }
}
