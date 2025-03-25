import 'package:flutter/material.dart';
import 'package:mvvm/domain/models/todo.dart';
import 'package:mvvm/ui/todo_details/viewmodels/todo_details_viewmodel.dart';

class EditTodoWidget extends StatefulWidget {
  final Todo todo;
  final TodoDetailsViewModel todoDetailsViewModel;
  const EditTodoWidget({
    super.key,
    required this.todo,
    required this.todoDetailsViewModel,
  });

  @override
  State<EditTodoWidget> createState() => _EditTodoWidgetState();
}

class _EditTodoWidgetState extends State<EditTodoWidget> {
  late final TextEditingController _nameController = TextEditingController(
    text: widget.todo.name,
  );

  late final TextEditingController _descriptionController =
      TextEditingController(
    text: widget.todo.description,
  );

  final _verticalGap = const SizedBox(height: 16);

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    widget.todoDetailsViewModel.updateTodo.addListener(_onUpdateTodo);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text("Editando Todo"),
            _verticalGap,
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: "Nome",
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == "") {
                  return "Preencha o campo de nome";
                }
                return null;
              },
            ),
            _verticalGap,
            TextFormField(
              minLines: 3,
              maxLines: null,
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: "Descrição",
                border: OutlineInputBorder(),
              ),
            ),
            _verticalGap,
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() == true) {
                  widget.todoDetailsViewModel.updateTodo.execute(
                    widget.todo.copyWith(
                      name: _nameController.text,
                      description: _descriptionController.text,
                    ),
                  );
                }
              },
              child: const Text("Salvar"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    widget.todoDetailsViewModel.updateTodo.removeListener(_onUpdateTodo);
    super.dispose();
  }

  void _onUpdateTodo() {
    final command = widget.todoDetailsViewModel.updateTodo;
    if (command.running) {
      showDialog(
        context: context,
        barrierDismissible: false,
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
      if (command.completed) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text("Todo editado com sucesso!"),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Ocorreu um erro ao editar Todo!"),
          ),
        );
      }
    }
  }
}
