import 'package:flutter/material.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';
import 'package:mvvm/ui/todo/widgets/add_todo_widget.dart';
import 'package:mvvm/ui/todo/widgets/todos_list.dart';

class TodoScreen extends StatefulWidget {
  final TodoViewmodel todoViewmodel;
  const TodoScreen({
    super.key,
    required this.todoViewmodel,
  });

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  @override
  void initState() {
    widget.todoViewmodel.deleteTodo.addListener(_onResult);
    super.initState();
  }

  void _onResult() {
    if (widget.todoViewmodel.deleteTodo.running) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: IntrinsicHeight(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      );
    } else {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      if (widget.todoViewmodel.deleteTodo.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Todo removido com sucesso!"),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Ocorreu um erro ao deletar todo!"),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    widget.todoViewmodel.deleteTodo.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos screen"),
      ),
      body: ListenableBuilder(
        listenable: widget.todoViewmodel.load,
        builder: (context, child) {
          if (widget.todoViewmodel.load.running) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (widget.todoViewmodel.load.error) {
            return const Center(
              child: Text("Ocorreu um erro ao carregar todos..."),
            );
          }
          return child!;
        },
        child: ListenableBuilder(
          listenable: widget.todoViewmodel,
          builder: (context, child) {
            return TodosList(
              onDeleteTodo: (todo) {},
              todos: widget.todoViewmodel.todos,
              todoViewmodel: widget.todoViewmodel,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AddTodoWidget(
                todoViewmodel: widget.todoViewmodel,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
