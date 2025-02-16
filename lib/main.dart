import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_remote.dart';
import 'package:mvvm/data/services/api/api_client.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: TodoScreen(
        todoViewmodel: TodoViewmodel(
          todosRepository: TodosRepositoryRemote(
            apiClient: ApiClient(
              host: "192.168.1.105",
            ),
          ),
        ),
      ),
    );
  }
}
