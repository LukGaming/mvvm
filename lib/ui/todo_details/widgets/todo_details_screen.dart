import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/ui/todo_details/viewmodels/todo_details_viewmodel.dart';
import 'package:mvvm/ui/todo_details/widgets/todo_name_widget.dart';

class TodoDetailsScreen extends StatefulWidget {
  final TodoDetailsViewModel todoDetailsViewModel;
  const TodoDetailsScreen({
    super.key,
    required this.todoDetailsViewModel,
  });

  @override
  State<TodoDetailsScreen> createState() => _TodoDetailsScreenState();
}

class _TodoDetailsScreenState extends State<TodoDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listando detalhe do Todo"),
      ),
      body: ListenableBuilder(
        listenable: widget.todoDetailsViewModel.load,
        builder: (context, child) {
          if (widget.todoDetailsViewModel.load.running) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (widget.todoDetailsViewModel.load.error) {
            return const Center(
              child: Text("Ocorreu um erro ao carregar detalhes do"),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.todoDetailsViewModel,
          builder: (context, child) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: TodoName(
                todo: widget.todoDetailsViewModel.todo,
              ),
            );
          },
        ),
      ),
    );
  }
}
