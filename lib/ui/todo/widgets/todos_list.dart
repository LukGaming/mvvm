import 'package:flutter/material.dart';
import 'package:mvvm/utils/typedefs/todos.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/todo_tile.dart';

class TodosList extends StatelessWidget {
  final OnDeleteTodo onDeleteTodo;
  final TodoViewmodel todoViewmodel;
  final List<Todo> todos;
  const TodosList({
    super.key,
    required this.todos,
    required this.todoViewmodel,
    required this.onDeleteTodo,
  });

  @override
  Widget build(BuildContext context) {
    if (todos.isEmpty) {
      return const Center(
        child: Text("Nenhuma tarefa por enquanto..."),
      );
    }
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return TodoTile(
          onDeleteTodo: onDeleteTodo,
          todo: todos[index],
          todoViewmodel: todoViewmodel,
        );
      },
    );
  }
}
