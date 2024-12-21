import 'package:flutter/material.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todos_list.dart';

class TodoScreen extends StatelessWidget {
  final TodoViewmodel todoViewmodel;
  const TodoScreen({
    super.key,
    required this.todoViewmodel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos screen"),
      ),
      body: ListenableBuilder(
        listenable: todoViewmodel.load,
        builder: (context, child) {
          if (todoViewmodel.load.running) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (todoViewmodel.load.error) {
            return const Center(
              child: Text("Ocorreu um erro ao carregar todos..."),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: todoViewmodel,
          builder: (context, child) {
            return TodosList(todos: todoViewmodel.todos);
          },
        ),
      ),
    );
  }
}
