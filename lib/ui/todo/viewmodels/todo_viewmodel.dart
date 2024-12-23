import 'package:flutter/material.dart';
import 'package:mvvm/core/commands/commands.dart';
import 'package:mvvm/core/result/result.dart';
import 'package:mvvm/domain/models/todo.dart';

class TodoViewmodel extends ChangeNotifier {
  TodoViewmodel() {
    load = Commmand0(_load)..execute();
    addTodo = Command1(_addTodo);
    deleteTodo = Command1(_deleteTodo);
  }

  late Commmand0 load;

  late Command1<Todo, String> addTodo;

  late Command1<String, Todo> deleteTodo;

  List<Todo> _todos = [];

  List<Todo> get todos => _todos;

  Future<Result> _load() async {
    await Future.delayed(const Duration(seconds: 2));
    final List<Todo> todos = [];

    _todos = todos;

    notifyListeners();

    return Result.ok(todos);
  }

  Future<Result<Todo>> _addTodo(String name) async {
    final lastTodoIndex = _todos.length;
    await Future.delayed(const Duration(seconds: 1));
    final createdTodo = Todo(id: lastTodoIndex + 1, name: name);
    _todos.add(createdTodo);
    notifyListeners();
    return Result.ok(createdTodo);
  }

  Future<Result<String>> _deleteTodo(Todo todo) async {
    await Future.delayed(const Duration(seconds: 1));
    _todos.remove(todo);
    notifyListeners();
    return Result.ok("Removido com sucesso.");
  }
}
