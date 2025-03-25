import 'package:flutter/material.dart';
import 'package:mvvm/data/repositories/todos/todos_repository_dev.dart';
import 'package:mvvm/domain/use_cases/todo_update_use_case.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    final todosRepository = TodosRepositoryDev();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
      ),
      home: TodoScreen(
        todoViewmodel: TodoViewmodel(
          todoUpdateUseCase:
              TodoUpdateUseCase(todosRepository: todosRepository),
          todosRepository: todosRepository,
        ),
      ),
    );
  }
}
