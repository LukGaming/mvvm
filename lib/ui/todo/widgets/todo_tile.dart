import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mvvm/routing/routes.dart';
import 'package:mvvm/utils/typedefs/todos.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';

class TodoTile extends StatelessWidget {
  final OnDeleteTodo onDeleteTodo;
  final TodoViewmodel todoViewmodel;
  final Todo todo;
  const TodoTile({
    super.key,
    required this.todo,
    required this.todoViewmodel,
    required this.onDeleteTodo,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.todoDetails(todo.id)),
      child: Card(
        child: ListTile(
          leading: Text(todo.id),
          title: Text(todo.name),
          trailing: IconButton(
            onPressed: () {
              todoViewmodel.deleteTodo.execute(todo);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
