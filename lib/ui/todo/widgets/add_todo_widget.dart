import 'package:flutter/material.dart';
import 'package:mvvm/ui/todo/viewmodels/todo_viewmodel.dart';

class AddTodoWidget extends StatefulWidget {
  final TodoViewmodel todoViewmodel;
  const AddTodoWidget({
    super.key,
    required this.todoViewmodel,
  });

  @override
  State<AddTodoWidget> createState() => _AddTodoWidgetState();
}

class _AddTodoWidgetState extends State<AddTodoWidget> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController = TextEditingController();
  final vertigalGap = const SizedBox(
    height: 16,
  );

  @override
  void initState() {
    widget.todoViewmodel.addTodo.addListener(_onResult);
    super.initState();
  }

  void _onResult() {
    if (widget.todoViewmodel.addTodo.running) {
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
      Navigator.of(context).pop();
      if (widget.todoViewmodel.addTodo.completed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "Todo criado com sucesso!",
            ),
          ),
        );
      }
      if (widget.todoViewmodel.addTodo.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.red,
            content: Text("Ocorreu um erro ao criar todo."),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    widget.todoViewmodel.addTodo.removeListener(_onResult);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: IntrinsicHeight(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Row(
                children: [Text("Adicione novos todos")],
              ),
              vertigalGap,
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Nome ",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim() == "") {
                    return "Por favor preencha o campo de nome";
                  }
                  return null;
                },
              ),
              vertigalGap,
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() == true) {
                    widget.todoViewmodel.addTodo.execute(
                      (nameController.text, "", false),
                    );
                  }
                },
                child: const Text("Salvar"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
