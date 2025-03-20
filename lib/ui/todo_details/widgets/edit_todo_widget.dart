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
                if (_formKey.currentState?.validate() == true) {}
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
    super.dispose();
  }
}
